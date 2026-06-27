import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/functions/show_image_picker.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/seller/inventory_data.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class SellerInventoryController extends GetxController {
  MyServices myServices = Get.find();
  InventoryData inventoryData = InventoryData(Get.find());

  String get sellerType =>
      myServices.sharedPreferences.getString('seller_type') ?? 'wholesale';
  bool get isWholesale => sellerType == 'wholesale';
  String get _token => myServices.sharedPreferences.getString('token') ?? '';

  StatusRequest statusRequest = StatusRequest.none;
  StatusRequest formStatusRequest = StatusRequest.none;

  List<ProductModel> _allProducts = [];
  List<ProductModel> displayedProducts = [];
  List<CategoryModel> categoryTree = [];
  List<WarehouseModel> warehouses = [];

  // ─── Search ────────────────────────────────────────────────────────────────

  final searchCtrl = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  void onSearchChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchQuery = q.trim();
      _applyFilters();
    });
  }

  void clearSearch() {
    searchCtrl.clear();
    _searchQuery = '';
    _applyFilters();
  }

  // ─── View Mode ─────────────────────────────────────────────────────────────

  bool isGridView = true;
  void toggleViewMode() {
    isGridView = !isGridView;
    update();
  }

  // ─── Filters ───────────────────────────────────────────────────────────────

  ProductFilter _filter = const ProductFilter();
  ProductFilter get filter => _filter;

  void applyFilter(ProductFilter f) {
    _filter = f;
    _applyFilters();
  }

  void resetFilter() {
    _filter = const ProductFilter();
    _applyFilters();
  }

  int selectedTabIndex = 0;

  void changeTab(int i) {
    selectedTabIndex = i;
    _applyFilters();
    update();
  }

  void _applyFilters() {
    var list = List<ProductModel>.from(_allProducts);

    // Tab filter
    switch (selectedTabIndex) {
      case 1:
        list = list.where((p) => p.status == 'active').toList();
        break;
      case 2:
        list = list.where((p) => p.isLowStock || p.isOutOfStock).toList();
        break;
      case 3:
        list = list.where((p) => p.status == 'draft').toList();
        break;
    }

    // Category filter (includes descendants)
    if (_filter.categoryId != null) {
      final ids = _collectDescendantIds(_filter.categoryId!, categoryTree);
      list = list.where((p) => ids.contains(p.categoryId)).toList();
    }

    // Status filter
    if (_filter.status != null) {
      list = list.where((p) => p.status == _filter.status).toList();
    }

    // Stock filter
    if (_filter.stock == 'low') {
      list = list.where((p) => p.isLowStock).toList();
    } else if (_filter.stock == 'out') {
      list = list.where((p) => p.isOutOfStock).toList();
    }

    // Search filter (local)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q))
          .toList();
    }

    // Sort
    switch (_filter.sort) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        list.sort((a, b) => b.id.compareTo(a.id));
    }

    displayedProducts = list;
    update();
  }

  List<int> _collectDescendantIds(int id, List<CategoryModel> cats) {
    final found = _findInTree(id, cats);
    if (found == null) return [id];
    final ids = <int>[];
    void collect(CategoryModel c) {
      ids.add(c.id);
      for (final child in c.children) collect(child);
    }
    collect(found);
    return ids;
  }

  CategoryModel? _findInTree(int id, List<CategoryModel> cats) {
    for (final cat in cats) {
      if (cat.id == id) return cat;
      final found = _findInTree(id, cat.children);
      if (found != null) return found;
    }
    return null;
  }

  String? getCategoryName(int? id) {
    if (id == null) return null;
    return _findInTree(id, categoryTree)?.name;
  }

  // ─── Counts (derived from loaded data) ────────────────────────────────────

  int get allCount => _allProducts.length;
  int get activeCount =>
      _allProducts.where((p) => p.status == 'active').length;
  int get lowStockCount =>
      _allProducts.where((p) => p.isLowStock || p.isOutOfStock).length;
  int get draftCount => _allProducts.where((p) => p.status == 'draft').length;

  // ─── Data Loading (Real API) ───────────────────────────────────────────────

  Future<void> loadProducts() async {
    statusRequest = StatusRequest.loading;
    update();

    // 1. Load categories first (needed for name enrichment)
    await _loadCategories();

    // 2. Load products from server
    final result = await inventoryData.getProducts(_token);
    result.fold(
      (failure) {
        statusRequest = failure;
        update();
      },
      (response) {
        if (response['success'] == true) {
          final rawData = response['data'];
          // Handle both paginated ({ data: [...] }) and direct list responses
          final List rawList = rawData is Map
              ? ((rawData['data'] as List?) ?? [])
              : ((rawData as List?) ?? []);

          _allProducts =
              rawList.map((p) => ProductModel.fromJson(p as Map)).toList();

          // Enrich with category names from local tree
          _enrichProductsWithCategoryNames();

          // Load warehouses locally (no dedicated backend endpoint yet)
          if (isWholesale) _loadWarehousesLocal();

          _applyFilters();
          statusRequest = StatusRequest.success;
        } else {
          statusRequest = StatusRequest.none;
        }
        update();
      },
    );
  }

  /// Fetches categories from the backend and builds the local tree.
  Future<void> _loadCategories() async {
    final result = await inventoryData.getCategories(_token);
    result.fold(
      (failure) {}, // Silently fail; category tree remains empty
      (response) {
        if (response['success'] == true) {
          final rawList = (response['data'] as List?) ?? [];
          final flat = rawList
              .map((c) => CategoryModel.fromJson(c as Map))
              .toList();
          categoryTree = _buildCategoryTree(flat);
        }
      },
    );
  }

  /// Builds a tree from a flat list (with parentId) or a pre-nested list
  /// (with children). Handles both response formats from the backend.
  List<CategoryModel> _buildCategoryTree(List<CategoryModel> flat) {
    // If server already returned a nested structure
    if (flat.any((c) => c.hasChildren)) {
      return flat.where((c) => c.isRoot).toList();
    }

    // Build tree from flat list using parentId
    final childrenMap = <int, List<CategoryModel>>{};
    for (final cat in flat) {
      if (cat.parentId != null) {
        childrenMap.putIfAbsent(cat.parentId!, () => []).add(cat);
      }
    }

    CategoryModel addChildren(CategoryModel cat) {
      final children = childrenMap[cat.id] ?? [];
      return CategoryModel(
        id: cat.id,
        name: cat.name,
        parentId: cat.parentId,
        productCount: cat.productCount,
        children: children.map(addChildren).toList(),
      );
    }

    return flat.where((c) => c.isRoot).map(addChildren).toList();
  }

  /// Replaces each product's empty `category` field with the name looked up
  /// from the local category tree.
  void _enrichProductsWithCategoryNames() {
    for (int i = 0; i < _allProducts.length; i++) {
      final catName = getCategoryName(_allProducts[i].categoryId);
      if (catName != null) {
        _allProducts[i] = _allProducts[i].copyWith(category: catName);
      }
    }
  }

  /// Loads warehouse list locally (static mock) until a backend endpoint
  /// for warehouses is implemented.
  void _loadWarehousesLocal() {
    warehouses = WarehouseModel.mockList();
    for (final w in warehouses) {
      formData.warehouseQty.putIfAbsent(w.id, () => '');
    }
  }

  Future<void> refreshProducts() => loadProducts();

  // ─── Product Actions (Real API) ────────────────────────────────────────────

  Future<void> toggleProductStatus(ProductModel p) async {
    final newStatus = p.status == 'active' ? 'hidden' : 'active';
    final action = newStatus == 'active' ? 'activate' : 'hide';

    // Optimistic UI update
    final idx = _allProducts.indexWhere((x) => x.id == p.id);
    if (idx != -1) {
      _allProducts[idx] = p.copyWith(status: newStatus);
      _applyFilters();
    }

    final result = await inventoryData.bulkAction(_token, [p.id], action);
    result.fold(
      (failure) {
        // Revert on network failure
        if (idx != -1) _allProducts[idx] = p;
        _applyFilters();
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (response) {
        if (response['success'] == true) {
          customSnackbar(
            'warning'.tr,
            newStatus == 'active'
                ? 'product_activated'.tr
                : 'product_hidden_msg'.tr,
            isError: false,
          );
        } else {
          // Revert on server error
          if (idx != -1) _allProducts[idx] = p;
          _applyFilters();
          customSnackbar(
              'warning'.tr, (response['message'] ?? '').toString());
        }
      },
    );
  }

  Future<void> deleteProduct(ProductModel p) async {
    // Optimistic removal
    final idx = _allProducts.indexWhere((x) => x.id == p.id);
    _allProducts.removeWhere((x) => x.id == p.id);
    _applyFilters();

    final result = await inventoryData.deleteProduct(_token, p.id);
    result.fold(
      (failure) {
        // Revert
        if (idx != -1) _allProducts.insert(idx, p);
        else _allProducts.add(p);
        _applyFilters();
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (response) {
        if (response['success'] == true) {
          customSnackbar(
              'delete_success_title'.tr, 'delete_success_msg'.tr,
              isError: false);
        } else {
          // Revert
          if (idx != -1) _allProducts.insert(idx, p);
          else _allProducts.add(p);
          _applyFilters();
          customSnackbar(
              'warning'.tr, (response['message'] ?? '').toString());
        }
      },
    );
  }

  // ─── Category Actions (local-only — backend requires super_admin) ──────────

  List<CategoryModel> _insertChild(
      List<CategoryModel> cats, int parentId, CategoryModel newCat) {
    return cats.map((cat) {
      if (cat.id == parentId) {
        return CategoryModel(
          id: cat.id,
          name: cat.name,
          parentId: cat.parentId,
          productCount: cat.productCount,
          children: [...cat.children, newCat],
        );
      }
      if (cat.hasChildren) {
        return CategoryModel(
          id: cat.id,
          name: cat.name,
          parentId: cat.parentId,
          productCount: cat.productCount,
          children: _insertChild(cat.children, parentId, newCat),
        );
      }
      return cat;
    }).toList();
  }

  List<CategoryModel> _updateName(
      List<CategoryModel> cats, int id, String name) {
    return cats.map((cat) {
      if (cat.id == id) return cat.copyWithName(name);
      if (cat.hasChildren) {
        return CategoryModel(
          id: cat.id,
          name: cat.name,
          parentId: cat.parentId,
          productCount: cat.productCount,
          children: _updateName(cat.children, id, name),
        );
      }
      return cat;
    }).toList();
  }

  List<CategoryModel> _deleteNode(List<CategoryModel> cats, int id) {
    return cats
        .where((c) => c.id != id)
        .map((c) => CategoryModel(
              id: c.id,
              name: c.name,
              parentId: c.parentId,
              productCount: c.productCount,
              children: _deleteNode(c.children, id),
            ))
        .toList();
  }

  Future<void> addCategory(String name, int? parentId) async {
    // NOTE: Category creation requires super_admin on the backend.
    // This update is reflected locally in the UI only.
    final newCat = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      parentId: parentId,
      productCount: 0,
    );
    if (parentId == null) {
      categoryTree = [...categoryTree, newCat];
    } else {
      categoryTree = _insertChild(categoryTree, parentId, newCat);
    }
    update();
    customSnackbar('success'.tr, 'category_added'.tr, isError: false);
  }

  Future<void> updateCategory(int id, String newName) async {
    // NOTE: Category update requires super_admin on the backend.
    categoryTree = _updateName(categoryTree, id, newName);
    update();
    customSnackbar('success'.tr, 'category_updated'.tr, isError: false);
  }

  void deleteCategory(CategoryModel cat) {
    // NOTE: Category deletion requires super_admin on the backend.
    if (cat.productCount > 0) {
      customSnackbar('warning'.tr, 'cannot_delete_with_products'.tr);
      return;
    }
    categoryTree = _deleteNode(categoryTree, cat.id);
    update();
    customSnackbar('delete_success_title'.tr, 'category_deleted'.tr,
        isError: false);
  }

  void reorderRootCategories(int oldIndex, int newIndex) {
    final roots = List<CategoryModel>.from(categoryTree);
    if (newIndex > oldIndex) newIndex--;
    final item = roots.removeAt(oldIndex);
    roots.insert(newIndex, item);
    categoryTree = roots;
    update();
  }

  Future<void> refreshCategories() async {
    await _loadCategories();
    update();
  }

  // ─── Form State ────────────────────────────────────────────────────────────

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final salePriceCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final alertCtrl = TextEditingController(text: '5');
  final weightCtrl = TextEditingController();
  final wsPrice = TextEditingController();
  final wsMinQty = TextEditingController();

  int? formCategoryId;
  String formStatus = 'active';
  bool formFreeShipping = false;
  bool formWholesale = false;
  String? formSaleEndsAt;
  final List<File> productImages = [];
  ProductModel? _editingProduct;
  bool get isEditing => _editingProduct != null;
  final formData = ProductFormData();

  bool get formVariantsEnabled => formData.variantsEnabled;
  List<VariantAttributeType> get formAttributeTypes => formData.attributeTypes;
  List<ProductVariantModel> get formVariants => formData.variants;

  Map<String, TextEditingController> variantStockCtrls = {};
  Map<String, TextEditingController> variantPriceCtrls = {};

  void setFormCategory(int? id) {
    formCategoryId = id;
    update();
  }

  void setFormStatus(String s) {
    formStatus = s;
    update();
  }

  void toggleFreeShipping() {
    formFreeShipping = !formFreeShipping;
    update();
  }

  void toggleWholesale() {
    formWholesale = !formWholesale;
    update();
  }

  void setSaleEndsAt(String? d) {
    formSaleEndsAt = d;
    update();
  }

  void setWarehouseQty(int warehouseId, String qty) {
    formData.warehouseQty[warehouseId] = qty;
    if (isWholesale) {
      final total = formData.totalWarehouseQty;
      stockCtrl.text = total > 0 ? total.toString() : '';
    }
    update();
  }

  void toggleVariants(bool value) {
    formData.variantsEnabled = value;
    if (!value) {
      formData.attributeTypes.clear();
      formData.variants.clear();
      _disposeVariantCtrls();
    }
    update();
  }

  void addAttributeType() {
    formData.attributeTypes.add(VariantAttributeType.create());
    update();
  }

  void removeAttributeType(String uid) {
    formData.attributeTypes.removeWhere((a) => a.uid == uid);
    formData.variants.clear();
    _disposeVariantCtrls();
    update();
  }

  void updateAttributeName(String uid, String name) {
    final idx = formData.attributeTypes.indexWhere((a) => a.uid == uid);
    if (idx != -1) formData.attributeTypes[idx].name = name;
  }

  void addAttributeValue(String uid, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final idx = formData.attributeTypes.indexWhere((a) => a.uid == uid);
    if (idx == -1) return;
    if (formData.attributeTypes[idx].values.contains(trimmed)) {
      customSnackbar('warning'.tr, 'attribute_value_exists'.tr);
      return;
    }
    formData.attributeTypes[idx].values.add(trimmed);
    update();
  }

  void removeAttributeValue(String uid, String value) {
    final idx = formData.attributeTypes.indexWhere((a) => a.uid == uid);
    if (idx != -1) {
      formData.attributeTypes[idx].values.remove(value);
      update();
    }
  }

  void generateVariants() {
    for (final attr in formData.attributeTypes) {
      if (!attr.isValid) {
        customSnackbar('warning'.tr, 'attribute_type_incomplete'.tr);
        return;
      }
    }
    if (formData.attributeTypes.isEmpty) {
      customSnackbar('warning'.tr, 'no_attribute_types'.tr);
      return;
    }

    final valueLists = formData.attributeTypes.map((a) => a.values).toList();
    final attrNames = formData.attributeTypes.map((a) => a.name).toList();
    final combinations = _cartesian(valueLists);

    final Map<String, String> oldStockValues = {};
    final Map<String, String> oldPriceValues = {};
    variantStockCtrls.forEach((key, ctrl) => oldStockValues[key] = ctrl.text);
    variantPriceCtrls.forEach((key, ctrl) => oldPriceValues[key] = ctrl.text);

    variantStockCtrls.clear();
    variantPriceCtrls.clear();

    formData.variants = combinations.map((combo) {
      final key = combo.join(' / ');
      final attrs = Map<String, String>.fromIterables(attrNames, combo);
      variantStockCtrls[key] =
          TextEditingController(text: oldStockValues[key] ?? '');
      variantPriceCtrls[key] =
          TextEditingController(text: oldPriceValues[key] ?? '');
      return ProductVariantModel(
        combinationKey: key,
        attributes: attrs,
        stock: int.tryParse(oldStockValues[key] ?? '0') ?? 0,
      );
    }).toList();

    update();
  }

  List<List<T>> _cartesian<T>(List<List<T>> lists) {
    List<List<T>> result = [[]];
    for (final list in lists) {
      result = [
        for (final existing in result)
          for (final value in list) [...existing, value]
      ];
    }
    return result;
  }

  void _initVariantControllers(
    List<ProductVariantModel> variants,
    Map<String, TextEditingController> oldStock,
    Map<String, TextEditingController> oldPrice,
  ) {
    for (final v in variants) {
      variantStockCtrls[v.combinationKey] = TextEditingController(
        text: oldStock[v.combinationKey]?.text ??
            (v.stock > 0 ? v.stock.toString() : ''),
      );
      variantPriceCtrls[v.combinationKey] = TextEditingController(
        text: oldPrice[v.combinationKey]?.text ??
            (v.price != null ? v.price.toString() : ''),
      );
    }
  }

  void _disposeVariantCtrls() {
    for (final c in variantStockCtrls.values) c.dispose();
    for (final c in variantPriceCtrls.values) c.dispose();
    variantStockCtrls.clear();
    variantPriceCtrls.clear();
  }

  void syncVariantsFromCtrls() {
    for (int i = 0; i < formData.variants.length; i++) {
      final key = formData.variants[i].combinationKey;
      formData.variants[i] = formData.variants[i].copyWith(
        stock: int.tryParse(variantStockCtrls[key]?.text ?? '') ?? 0,
        price: variantPriceCtrls[key]?.text.isNotEmpty == true
            ? int.tryParse(variantPriceCtrls[key]!.text)
            : null,
      );
    }
  }

  Future<void> pickVariantImage(String combinationKey) async {
    final src = await showImagePickerBottomSheet();
    if (src == null) return;
    final f = await ImagePicker().pickImage(source: src, imageQuality: 80);
    if (f == null) return;
    final idx =
        formData.variants.indexWhere((v) => v.combinationKey == combinationKey);
    if (idx != -1) {
      formData.variants[idx] =
          formData.variants[idx].copyWith(localImage: File(f.path));
      update();
    }
  }

  Future<void> pickProductImages() async {
    if (productImages.length >= 10) {
      customSnackbar('warning'.tr, 'images_max_reached'.tr);
      return;
    }
    final source = await showImagePickerBottomSheet();
    if (source == null) return;
    if (source == ImageSource.camera) {
      final f =
          await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (f != null) {
        productImages.add(File(f.path));
        update();
      }
    } else {
      final images = await ImagePicker().pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) {
        final slots = 10 - productImages.length;
        productImages.addAll(images.take(slots).map((x) => File(x.path)));
        update();
      }
    }
  }

  void removeImage(int i) {
    productImages.removeAt(i);
    update();
  }

  void prepareAddForm() {
    _editingProduct = null;
    _clearForm();
    if (isWholesale) {
      formData.warehouseQty = {for (final w in warehouses) w.id: ''};
    }
  }

  void prepareEditForm(ProductModel p) {
    _editingProduct = p;
    nameCtrl.text = p.name;
    descCtrl.text = p.description;
    priceCtrl.text = p.price.toString();
    if (p.salePrice != null) salePriceCtrl.text = p.salePrice.toString();
    skuCtrl.text = p.sku;
    stockCtrl.text = p.stock.toString();
    alertCtrl.text = p.lowStockAlert.toString();
    weightCtrl.text = p.weightGrams.toString();
    formCategoryId = p.categoryId;
    formStatus = p.status;
    formFreeShipping = p.isFreeShipping;
    formWholesale = p.wholesaleEnabled;
    formData.variantsEnabled = p.hasVariants;
    if (p.hasVariants && p.variants.isNotEmpty) {
      formData.variants = List.from(p.variants);
      _initVariantControllers(formData.variants, {}, {});
    }
    if (isWholesale) {
      formData.warehouseQty = {for (final w in warehouses) w.id: ''};
      for (final ws in p.warehouseStock) {
        formData.warehouseQty[ws.warehouseId] = ws.qty.toString();
      }
    }
    update();
  }

  void _clearForm() {
    for (final c in [
      nameCtrl, descCtrl, priceCtrl, salePriceCtrl,
      skuCtrl, stockCtrl, wsPrice, wsMinQty, weightCtrl
    ]) {
      c.clear();
    }
    alertCtrl.text = '5';
    formCategoryId = null;
    formStatus = 'active';
    formFreeShipping = false;
    formWholesale = false;
    formSaleEndsAt = null;
    productImages.clear();
    formData.warehouseQty.clear();
    formData.variantsEnabled = false;
    formData.attributeTypes.clear();
    formData.variants.clear();
    _disposeVariantCtrls();
  }

  // ─── Form Submission (Real API) ────────────────────────────────────────────

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    if (formCategoryId == null) {
      customSnackbar('warning'.tr, 'category_required_msg'.tr);
      return;
    }
    if (productImages.isEmpty && !isEditing) {
      customSnackbar('warning'.tr, 'product_image_required'.tr);
      return;
    }
    if (formData.variantsEnabled) {
      if (formData.variants.isEmpty) {
        customSnackbar('warning'.tr, 'no_attribute_types'.tr);
        return;
      }
      syncVariantsFromCtrls();
      if (formData.variants.any((v) => v.stock <= 0)) {
        customSnackbar('warning'.tr, 'variant_stock_required_msg'.tr);
        return;
      }
    }
    if (isWholesale &&
        warehouses.isNotEmpty &&
        formData.totalWarehouseQty == 0) {
      customSnackbar('warning'.tr, 'warehouse_qty_required'.tr);
      return;
    }

    formStatusRequest = StatusRequest.loading;
    update();

    final fields = _buildProductFields();
    final variants =
        formData.variantsEnabled ? formData.variants : <ProductVariantModel>[];

    final Either<StatusRequest, Map> result;
    if (isEditing) {
      result = await inventoryData.updateProduct(
        _token, _editingProduct!.id, fields, productImages, variants,
      );
    } else {
      result = await inventoryData.createProduct(
        _token, fields, productImages, variants,
      );
    }

    result.fold(
      (failure) {
        formStatusRequest = failure;
        update();
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (response) async {
        if (response['success'] == true) {
          formStatusRequest = StatusRequest.success;
          update();
          customSnackbar(
            'success'.tr,
            isEditing
                ? 'product_updated_success'.tr
                : 'product_saved_success'.tr,
            isError: false,
          );
          _clearForm();
          await loadProducts();
          Get.back();
        } else {
          formStatusRequest = StatusRequest.none;
          update();
          // Show the first validation error from the backend (if any)
          final errors = response['errors'] as Map?;
          final message = errors != null
              ? (errors.values.first as List).first.toString()
              : (response['message'] ?? 'unknown_error'.tr).toString();
          customSnackbar('warning'.tr, message);
        }
      },
    );
  }

  /// Builds the product fields map with the correct backend field names.
  ///
  /// Backend field mapping:
  ///   original_price  ← priceCtrl
  ///   offer_price     ← salePriceCtrl
  ///   offer_expires_at← formSaleEndsAt
  ///   quantity        ← stockCtrl
  ///   alert_threshold ← alertCtrl
  ///   weight          ← weightCtrl
  Map<String, String> _buildProductFields() {
    final fields = <String, String>{
      'name': nameCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'category_id': formCategoryId.toString(),
      'original_price': priceCtrl.text.trim(),
      'sku': skuCtrl.text.trim(),
      'quantity': stockCtrl.text.trim(),
      'alert_threshold': alertCtrl.text.trim(),
      'status': formStatus,
      'is_free_shipping': formFreeShipping ? '1' : '0',
    };

    if (salePriceCtrl.text.isNotEmpty) {
      fields['offer_price'] = salePriceCtrl.text.trim();
    }
    if (formSaleEndsAt != null) {
      fields['offer_expires_at'] = formSaleEndsAt!;
    }
    if (weightCtrl.text.isNotEmpty) {
      fields['weight'] = weightCtrl.text.trim();
    }

    if (isWholesale) {
      if (wsPrice.text.isNotEmpty) {
        fields['wholesale_price'] = wsPrice.text.trim();
      }
      if (wsMinQty.text.isNotEmpty) {
        fields['min_wholesale_qty'] = wsMinQty.text.trim();
      }
      final stockList = formData.warehouseQty.entries
          .where((e) => e.value.isNotEmpty && (int.tryParse(e.value) ?? 0) > 0)
          .toList();
      for (int i = 0; i < stockList.length; i++) {
        fields['warehouse_stock[$i][warehouse_id]'] = stockList[i].key.toString();
        fields['warehouse_stock[$i][qty]'] = stockList[i].value;
      }
    }

    return fields;
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    for (final c in [
      nameCtrl, descCtrl, priceCtrl, salePriceCtrl,
      skuCtrl, stockCtrl, alertCtrl, weightCtrl, wsPrice, wsMinQty
    ]) {
      c.dispose();
    }
    _debounce?.cancel();
    _disposeVariantCtrls();
    super.onClose();
  }
}