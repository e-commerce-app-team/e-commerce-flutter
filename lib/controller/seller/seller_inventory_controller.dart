import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';
import 'package:e_commerce/core/services/services.dart';

import '../../core/functions/show_image_picker.dart';

class SellerInventoryController extends GetxController {

  MyServices myServices = Get.find();
  String get sellerType =>
      myServices.sharedPreferences.getString('seller_type') ?? 'wholesale';
  bool get isWholesale => sellerType == 'wholesale';
  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest formStatusRequest = StatusRequest.none;
  List<ProductModel>  _allProducts       = [];
  List<ProductModel>  displayedProducts  = [];
  List<CategoryModel> categories         = [];
  List<WarehouseModel> warehouses        = [];

  final searchCtrl  = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  void onSearchChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = q.trim();
      _applyFilters();
    });
  }

  void clearSearch() {
    searchCtrl.clear();
    _searchQuery = '';
    _applyFilters();
  }


  bool isGridView = true;
  void toggleViewMode() { isGridView = !isGridView; update(); }

  ProductFilter _filter = const ProductFilter();
  ProductFilter get filter => _filter;

  void applyFilter(ProductFilter f) { _filter = f; _applyFilters(); }
  void resetFilter()               { _filter = const ProductFilter(); _applyFilters(); }


  int selectedTabIndex = 0;

  void changeTab(int i) { selectedTabIndex = i; _applyFilters(); update(); }


  void _applyFilters() {
    var list = List<ProductModel>.from(_allProducts);
    switch (selectedTabIndex) {
      case 1: list = list.where((p) => p.status == 'active').toList();             break;
      case 2: list = list.where((p) => p.isLowStock || p.isOutOfStock).toList();   break;
      case 3: list = list.where((p) => p.status == 'draft').toList();              break;
    }
    if (_filter.categoryId != null)
      list = list.where((p) => p.categoryId == _filter.categoryId).toList();
    if (_filter.status != null)
      list = list.where((p) => p.status == _filter.status).toList();
    if (_filter.stock == 'low')
      list = list.where((p) => p.isLowStock).toList();
    else if (_filter.stock == 'out')
      list = list.where((p) => p.isOutOfStock).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
      p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q)).toList();
    }
    switch (_filter.sort) {
      case 'price_asc':  list.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_desc': list.sort((a, b) => b.price.compareTo(a.price)); break;
      default:           list.sort((a, b) => b.id.compareTo(a.id));
    }
    displayedProducts = list;
    update();
  }

  int get allCount      => _allProducts.length;
  int get activeCount   => _allProducts.where((p) => p.status == 'active').length;
  int get lowStockCount => _allProducts.where((p) => p.isLowStock || p.isOutOfStock).length;
  int get draftCount    => _allProducts.where((p) => p.status == 'draft').length;

  Future<void> loadProducts() async {
    statusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));
    //  var res = await inventoryData.getProducts(...)
    _allProducts = ProductModel.mockList();
    categories   = CategoryModel.mockList();
    if (isWholesale) await loadWarehouses();
    _applyFilters();
    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> refreshProducts() => loadProducts();

  Future<void> loadWarehouses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // var res = await branchesData.getBranches()
    warehouses = WarehouseModel.mockList();
    for (final w in warehouses) {
      if (!formData.warehouseQty.containsKey(w.id)) {
        formData.warehouseQty[w.id] = '';
      }
    }
  }

  Future<void> toggleProductStatus(ProductModel p) async {
    final newStatus = p.status == 'active' ? 'hidden' : 'active';
    final idx = _allProducts.indexWhere((x) => x.id == p.id);
    if (idx != -1) { _allProducts[idx] = p.copyWith(status: newStatus); _applyFilters(); }
    customSnackbar('نجاح',
        newStatus == 'active' ? 'تم تفعيل المنتج' : 'تم إخفاء المنتج',
        isError: false);
    //  await inventoryData.updateStatus(p.id, newStatus);
  }

  Future<void> deleteProduct(ProductModel p) async {
    _allProducts.removeWhere((x) => x.id == p.id);
    _applyFilters();
    customSnackbar('تم الحذف', 'تم حذف المنتج بنجاح', isError: false);
    //  await inventoryData.deleteProduct(p.id);
  }


  Future<void> addCategory(String name, int? parentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    //  await inventoryData.createCategory(name, parentId);
    final newId = (categories.isEmpty ? 0 :
    categories.map((c) => c.id).reduce((a, b) => a > b ? a : b)) + 1;
    categories.add(CategoryModel(
        id: newId, name: name, parentId: parentId, productCount: 0));
    update();
    customSnackbar('تمت الإضافة', 'تمت إضافة القسم بنجاح', isError: false);
  }

  Future<void> updateCategory(
      CategoryModel cat, String newName, int? parentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: await inventoryData.updateCategory(cat.id, newName, parentId);
    final idx = categories.indexWhere((c) => c.id == cat.id);
    if (idx != -1) {
      categories[idx] = CategoryModel(
          id: cat.id, name: newName, parentId: parentId,
          productCount: cat.productCount);
    }
    update();
    customSnackbar('تم التحديث', 'تم تحديث القسم', isError: false);
  }

  void deleteCategory(CategoryModel cat) {
    categories.removeWhere((c) => c.id == cat.id);
    update();
    customSnackbar('تم الحذف', 'تم حذف القسم', isError: false);
    // await inventoryData.deleteCategory(cat.id);
  }

  void toggleCategoryVisibility(CategoryModel cat) {
    //  await inventoryData.toggleCategory(cat.id);
    customSnackbar('تم', 'تم تغيير حالة القسم', isError: false);
  }

  void reorderCategory(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);
    update();
    //  await inventoryData.reorderCategories(categories.map((c)=>c.id).toList());
  }


  final formKey        = GlobalKey<FormState>();
  final nameCtrl       = TextEditingController();
  final descCtrl       = TextEditingController();
  final priceCtrl      = TextEditingController();
  final salePriceCtrl  = TextEditingController();
  final skuCtrl        = TextEditingController();
  final stockCtrl      = TextEditingController();
  final alertCtrl      = TextEditingController(text: '5');
  final weightCtrl     = TextEditingController();
  final wsPrice        = TextEditingController();
  final wsMinQty       = TextEditingController();

  int?   formCategoryId;
  String formStatus       = 'active';
  bool   formFreeShipping = false;
  bool   formWholesale    = false;
  String? formSaleEndsAt;

  final List<File> productImages = [];
  final ImagePicker _picker = ImagePicker();
  ProductModel? _editingProduct;
  bool get isEditing => _editingProduct != null;

  final formData = ProductFormData();

  void setFormCategory(int? id) { formCategoryId = id; update(); }
  void setFormStatus(String s)  { formStatus = s;      update(); }
  void toggleFreeShipping()     { formFreeShipping = !formFreeShipping; update(); }
  void toggleWholesale()        { formWholesale = !formWholesale;       update(); }
  void setSaleEndsAt(String? d) { formSaleEndsAt = d;  update(); }

  void setWarehouseQty(int warehouseId, String qty) {
    formData.warehouseQty[warehouseId] = qty;
    if (isWholesale) {
      final total = formData.totalWarehouseQty;
      stockCtrl.text = total > 0 ? total.toString() : '';
    }
    update();
  }



  Future<void> pickProductImages() async {
    if (productImages.length >= 10) {
      customSnackbar('تنبيه', 'لا يمكنك إضافة أكثر من 10 صور للمنتج');
      return;
    }

    final ImageSource? source = await showImagePickerBottomSheet();

    if (source == null) return;

    final ImagePicker picker = ImagePicker();

    if (source == ImageSource.camera) {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        productImages.add(File(photo.path));
        update();
      }
    }
    else if (source == ImageSource.gallery) {
      final List<XFile> selectedImages = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (selectedImages.isNotEmpty) {
        int slotsAvailable = 10 - productImages.length;

        var imagesToAdd = selectedImages.take(slotsAvailable).map((x) => File(x.path));

        productImages.addAll(imagesToAdd);

        if (selectedImages.length > slotsAvailable) {
          customSnackbar('ملاحظة', 'تم إضافة $slotsAvailable صور فقط للوصول للحد الأقصى (10)');
        }

        update();
      }
    }
  }
  void removeImage(int i) { productImages.removeAt(i); update(); }

  void prepareAddForm() {
    _editingProduct = null;
    _clearForm();
    if (isWholesale) {
      formData.warehouseQty = {for (var w in warehouses) w.id: ''};
    }
  }

  void prepareEditForm(ProductModel p) {
    _editingProduct = p;
    nameCtrl.text   = p.name;
    priceCtrl.text  = p.price.toString();
    if (p.salePrice != null) salePriceCtrl.text = p.salePrice.toString();
    skuCtrl.text    = p.sku;
    stockCtrl.text  = p.stock.toString();
    alertCtrl.text  = p.lowStockAlert.toString();
    weightCtrl.text = p.weightGrams.toString();
    formCategoryId  = p.categoryId;
    formStatus      = p.status;
    formFreeShipping= p.isFreeShipping;
    formWholesale   = p.wholesaleEnabled;
    if (isWholesale) {
      formData.warehouseQty = {for (var w in warehouses) w.id: ''};
      for (final ws in p.warehouseStock) {
        formData.warehouseQty[ws.warehouseId] = ws.qty.toString();
      }
    }
    update();
  }

  void _clearForm() {
    for (final c in [nameCtrl, descCtrl, priceCtrl, salePriceCtrl,
      skuCtrl, stockCtrl, wsPrice, wsMinQty, weightCtrl]) {
      c.clear();
    }
    alertCtrl.text   = '5';
    formCategoryId   = null;
    formStatus       = 'active';
    formFreeShipping = false;
    formWholesale    = false;
    formSaleEndsAt   = null;
    productImages.clear();
    formData.warehouseQty.clear();
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    if (formCategoryId == null) {
      customSnackbar('تنبيه', 'الرجاء اختيار قسم للمنتج');
      return;
    }
    if (productImages.isEmpty && !isEditing) {
      customSnackbar('تنبيه', 'الرجاء إضافة صورة واحدة على الأقل');
      return;
    }
    if (isWholesale && warehouses.isNotEmpty &&
        formData.totalWarehouseQty == 0) {
      customSnackbar('تنبيه',
          'الرجاء إدخال الكمية في مستودع واحد على الأقل');
      return;
    }
    formStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: API call with postDataWithFiles
    formStatusRequest = StatusRequest.success;
    customSnackbar(
      isEditing ? 'تم التحديث' : 'تمت الإضافة',
      isEditing ? 'تم تحديث المنتج بنجاح' : 'تمت إضافة المنتج بنجاح',
      isError: false,
    );
    _clearForm();
    await loadProducts();
    Get.back();
  }

  @override
  void onInit() { super.onInit(); loadProducts(); }

  @override
  void onClose() {
    searchCtrl.dispose();
    for (final c in [nameCtrl, descCtrl, priceCtrl, salePriceCtrl,
      skuCtrl, stockCtrl, alertCtrl, weightCtrl,
      wsPrice, wsMinQty]) {
      c.dispose();
    }
    _debounce?.cancel();
    super.onClose();
  }


  Future<void> refreshCategories() async {


    try {
      // var response = await inventoryData.getCategories();
      // categories = response.map((cat) => CategoryModel.fromJson(cat)).toList();

      await Future.delayed(const Duration(milliseconds: 300)); // محاكاة وقت الاتصال بالنت

      categories = CategoryModel.mockList();

      update();

    } catch (e) {
      customSnackbar('خطأ', 'حدث خطأ أثناء تحديث قائمة الأقسام', isError: true);
    }
  }
}