import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/buyer/explore_datasource.dart';
import 'package:e_commerce/data/models/explore/explore_models.dart';

enum ExploreMode { chooser, products, stores }

class ExploreSection<T> {
  final String id;
  final String title;
  final List<T> items;

  const ExploreSection({
    required this.id,
    required this.title,
    required this.items,
  });
}

class ExploreController extends GetxController {
  final BuyerExploreRemoteDataSource _remote = BuyerExploreRemoteDataSource();
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  ExploreMode mode = ExploreMode.chooser;
  bool isSearchFocused = false;
  bool isLoading = false;
  String? errorMessage;
  int selectedCategoryIndex = 0;
  String? selectedStoreId;
  String currentQuery = '';
  RangeValues priceRange = const RangeValues(0, 3000000);
  double minRating = 0;
  double radiusKm = 10;
  bool freeShippingOnly = false;
  bool discountedOnly = false;
  bool inStockOnly = false;
  bool openNowOnly = false;
  bool hasProductsOnly = false;
  bool nearbyOnly = false;
  String sortBy = 'latest';
  List<String> recentSearches = [];
  List<String> suggestions = [];
  List<ExploreCategoryModel> categories = const [
    ExploreCategoryModel(
      id: 'all',
      name: 'all_categories',
      icon: Icons.apps_rounded,
    ),
  ];
  final List<ExploreProductModel> _allProducts = [];
  final List<ExploreStoreModel> _allStores = [];
  List<ExploreProductModel> products = [];
  List<ExploreStoreModel> stores = [];

  bool get isProductsMode => mode == ExploreMode.products;
  bool get isStoresMode => mode == ExploreMode.stores;
  bool get hasSelectedMode => mode != ExploreMode.chooser;

  String? get _token {
    try {
      return Get.find<MyServices>().sharedPreferences.getString('token');
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    searchFocusNode.addListener(() {
      isSearchFocused = searchFocusNode.hasFocus;
      update();
    });
    _loadCategories();
  }

  Future<void> chooseMode(ExploreMode nextMode) async {
    mode = nextMode;
    isSearchFocused = false;
    searchFocusNode.unfocus();
    update();
    await refreshResults();
  }

  Future<void> _loadCategories() async {
    final result = await _remote.getCategories();
    result.fold(
      (_) {},
      (response) {
        final raw = response['data'] is List ? response['data'] as List : const [];
        categories = [
          const ExploreCategoryModel(
            id: 'all',
            name: 'all_categories',
            icon: Icons.apps_rounded,
          ),
          ...raw.whereType<Map>().map(
                (item) => ExploreCategoryModel(
                  id: item['id'].toString(),
                  name: item['name']?.toString() ?? '',
                  icon: Icons.category_outlined,
                ),
              ),
        ];
      },
    );
    update();
  }

  Future<void> refreshResults() async {
    if (!hasSelectedMode) return;
    isLoading = true;
    errorMessage = null;
    update();

    final categoryId = selectedCategoryIndex > 0 &&
            selectedCategoryIndex < categories.length
        ? categories[selectedCategoryIndex].id
        : null;

    final result = isProductsMode
        ? await _remote.getProducts(
            query: currentQuery,
            categoryId: categoryId,
            sortBy: sortBy,
            minPrice: priceRange.start,
            maxPrice: priceRange.end,
            minRating: minRating,
            freeShipping: freeShippingOnly,
            discounted: discountedOnly,
            inStock: inStockOnly,
            storeId: selectedStoreId,
            token: _token,
          )
        : await _remote.getStores(
            query: currentQuery,
            categoryId: categoryId,
            sortBy: sortBy,
            minRating: minRating,
            openNow: openNowOnly,
            hasProducts: hasProductsOnly,
            radius: nearbyOnly ? radiusKm : null,
            token: _token,
          );

    result.fold(
      (failure) {
        errorMessage = 'explore_error_body'.tr;
      },
      (response) {
        if (response['success'] == false) {
          errorMessage =
              response['message']?.toString().isNotEmpty == true
                  ? response['message'].toString()
                  : 'explore_error_body'.tr;
          return;
        }
        if (isProductsMode) {
          final rawData = response['data'];
          final raw = rawData is Map ? rawData['data'] : rawData;
          _allProducts
            ..clear()
            ..addAll((raw is List ? raw : const [])
                .whereType<Map>()
                .map((item) => ExploreProductModel.fromJson(Map<String, dynamic>.from(item))));
          products = List<ExploreProductModel>.from(_allProducts);
          suggestions = _buildProductSuggestions(currentQuery);
        } else {
          final rawData = response['data'];
          final raw = rawData is Map ? rawData['data'] : rawData;
          _allStores
            ..clear()
            ..addAll((raw is List ? raw : const [])
                .whereType<Map>()
                .map((item) => ExploreStoreModel.fromJson(Map<String, dynamic>.from(item))));
          stores = List<ExploreStoreModel>.from(_allStores);
          suggestions = _buildStoreSuggestions(currentQuery);
        }
      },
    );

    isLoading = false;
    update();
  }

  void onSearchChanged(String query) {
    suggestions = isStoresMode
        ? _buildStoreSuggestions(query)
        : _buildProductSuggestions(query);
    update();
  }

  List<String> _buildProductSuggestions(String query) {
    final normalized = query.toLowerCase().trim();
    return _allProducts
        .where((p) =>
            normalized.isEmpty ||
            p.name.toLowerCase().contains(normalized) ||
            p.storeName.toLowerCase().contains(normalized))
        .map((p) => p.name)
        .where((name) => name.isNotEmpty)
        .toSet()
        .take(6)
        .toList();
  }

  List<String> _buildStoreSuggestions(String query) {
    final normalized = query.toLowerCase().trim();
    return _allStores
        .where((s) =>
            normalized.isEmpty ||
            s.name.toLowerCase().contains(normalized) ||
            s.category.toLowerCase().contains(normalized))
        .map((s) => s.name)
        .where((name) => name.isNotEmpty)
        .toSet()
        .take(6)
        .toList();
  }

  Future<void> submitSearch(String query) async {
    searchFocusNode.unfocus();
    currentQuery = query.trim();
    if (currentQuery.isNotEmpty && !recentSearches.contains(currentQuery)) {
      recentSearches.insert(0, currentQuery);
      if (recentSearches.length > 5) recentSearches.removeLast();
    }
    await refreshResults();
  }

  void selectSuggestion(String suggestion) {
    searchTextController.text = suggestion;
    submitSearch(suggestion);
  }

  Future<void> closeSearch() async {
    searchTextController.clear();
    currentQuery = '';
    suggestions = [];
    searchFocusNode.unfocus();
    await refreshResults();
  }

  void clearRecentSearches() {
    recentSearches = [];
    update();
  }

  Future<void> selectCategory(int index) async {
    selectedCategoryIndex = index;
    await refreshResults();
  }

  void switchTab(bool storesTab) {
    chooseMode(storesTab ? ExploreMode.stores : ExploreMode.products);
  }

  Future<void> applyFilterValues({
    required RangeValues newPriceRange,
    required double newMinRating,
    required bool newFreeShippingOnly,
    required bool newDiscountedOnly,
    required bool newInStockOnly,
    required bool newOpenNowOnly,
    required bool newHasProductsOnly,
    required bool newNearbyOnly,
    required double newRadiusKm,
  }) async {
    priceRange = newPriceRange;
    minRating = newMinRating;
    freeShippingOnly = newFreeShippingOnly;
    discountedOnly = newDiscountedOnly;
    inStockOnly = newInStockOnly;
    openNowOnly = newOpenNowOnly;
    hasProductsOnly = newHasProductsOnly;
    nearbyOnly = newNearbyOnly;
    radiusKm = newRadiusKm;
    await refreshResults();
  }

  Future<void> setSortBy(String value) async {
    sortBy = value;
    await refreshResults();
  }

  Future<void> resetFilters() async {
    selectedCategoryIndex = 0;
    selectedStoreId = null;
    priceRange = const RangeValues(0, 3000000);
    minRating = 0;
    radiusKm = 10;
    freeShippingOnly = false;
    discountedOnly = false;
    inStockOnly = false;
    openNowOnly = false;
    hasProductsOnly = false;
    nearbyOnly = false;
    sortBy = 'latest';
    currentQuery = '';
    searchTextController.clear();
    await refreshResults();
  }

  Future<void> removeFilterChip(String key) async {
    if (key == 'discount') discountedOnly = false;
    if (key == 'rating') minRating = 0;
    if (key == 'price') priceRange = const RangeValues(0, 3000000);
    if (key == 'shipping') freeShippingOnly = false;
    if (key == 'stock') inStockOnly = false;
    if (key == 'open') openNowOnly = false;
    if (key == 'has_products') hasProductsOnly = false;
    if (key == 'nearby') nearbyOnly = false;
    if (key == 'category') selectedCategoryIndex = 0;
    await refreshResults();
  }

  Future<void> toggleFavorite(String productId) async {
    final token = _token;
    if (token == null) {
      customSnackbar('warning'.tr, 'signin_required_favorite'.tr, isError: true);
      return;
    }
    final result = await _remote.toggleFavorite(productId, token);
    result.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr, isError: true),
      (_) {
        final index = _allProducts.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _allProducts[index] = _allProducts[index].copyWith(
            isFavorite: !_allProducts[index].isFavorite,
          );
          products = List<ExploreProductModel>.from(_allProducts);
          update();
        }
      },
    );
  }

  Future<void> addToCart(String productId) async {
    ExploreProductModel? product;
    for (final item in _allProducts) {
      if (item.id == productId) {
        product = item;
        break;
      }
    }

    final maxStock = product?.quantity;
    if (!Get.isRegistered<CartController>()) return;

    await Get.find<CartController>().addToCart(
      productId,
      maxStock: maxStock,
    );
  }

  Map<String, String> get _categoryNames => {
        for (final category in categories) category.id: category.name,
      };

  List<ExploreSection<ExploreProductModel>> get productSections {
    final grouped = <String, List<ExploreProductModel>>{};
    for (final product in products) {
      final key = product.categoryId.isNotEmpty ? product.categoryId : 'uncategorized';
      grouped.putIfAbsent(key, () => []).add(product);
    }
    return grouped.entries
        .map(
          (entry) => ExploreSection<ExploreProductModel>(
            id: entry.key,
            title: _categoryNames[entry.key] ??
                _fallbackLabel(entry.value.first.categoryName, 'explore_uncategorized'.tr),
            items: entry.value,
          ),
        )
        .toList();
  }

  List<ExploreSection<ExploreStoreModel>> get storeSections {
    final grouped = <String, List<ExploreStoreModel>>{};
    for (final store in stores) {
      final key = store.categoryId.isNotEmpty
          ? store.categoryId
          : _fallbackLabel(store.category, 'explore_uncategorized'.tr);
      grouped.putIfAbsent(key, () => []).add(store);
    }
    return grouped.entries
        .map(
          (entry) => ExploreSection<ExploreStoreModel>(
            id: entry.key,
            title: _categoryNames[entry.key] ??
                _fallbackLabel(entry.value.first.category, 'explore_uncategorized'.tr),
            items: entry.value,
          ),
        )
        .toList();
  }

  String _fallbackLabel(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value;
  }

  int get activeFilterCount =>
      (discountedOnly ? 1 : 0) +
      (minRating > 0 ? 1 : 0) +
      (priceRange.start != 0 || priceRange.end != 3000000 ? 1 : 0) +
      (freeShippingOnly ? 1 : 0) +
      (inStockOnly ? 1 : 0) +
      (openNowOnly ? 1 : 0) +
      (hasProductsOnly ? 1 : 0) +
      (nearbyOnly ? 1 : 0) +
      (selectedCategoryIndex > 0 ? 1 : 0);

  List<Map<String, String>> get activeFilterChips => [
        if (selectedCategoryIndex > 0 && selectedCategoryIndex < categories.length)
          {'key': 'category', 'label': categories[selectedCategoryIndex].name},
        if (discountedOnly) {'key': 'discount', 'label': 'explore_discount_only'},
        if (freeShippingOnly) {'key': 'shipping', 'label': 'free_shipping'},
        if (inStockOnly) {'key': 'stock', 'label': 'explore_in_stock_only'},
        if (openNowOnly) {'key': 'open', 'label': 'explore_open_now_only'},
        if (hasProductsOnly) {'key': 'has_products', 'label': 'explore_has_products_only'},
        if (nearbyOnly) {'key': 'nearby', 'label': 'explore_nearby_only'},
        if (minRating > 0) {'key': 'rating', 'label': '${minRating.toInt()}+'},
        if (priceRange.start != 0 || priceRange.end != 3000000)
          {'key': 'price', 'label': 'explore_price_range'},
      ];

  int get resultCount => isStoresMode ? stores.length : products.length;

  @override
  void onClose() {
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}
