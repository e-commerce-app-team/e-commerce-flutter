import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/buyer/home_datasource.dart';
import 'package:e_commerce/data/models/explore/explore_models.dart';

class ExploreController extends GetxController {
  final BuyerHomeRemoteDataSource _remote = BuyerHomeRemoteDataSource();
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  bool isSearchFocused = false;
  bool isStoresTab = false;
  bool isLoading = true;
  int selectedCategoryIndex = 0;
  String? selectedSubCategoryId;
  String currentQuery = '';
  RangeValues priceRange = const RangeValues(0, 3000000);
  double minRating = 0;
  bool freeShippingOnly = false;
  bool discountedOnly = false;
  String sortBy = 'latest';
  List<String> recentSearches = [];
  List<String> suggestions = [];
  List<ExploreCategoryModel> categories = [];
  final List<ExploreProductModel> _allProducts = [];
  final List<ExploreStoreModel> _allStores = [];
  List<ExploreProductModel> products = [];
  List<ExploreStoreModel> stores = [];

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
    _loadRemote();
  }

  Future<void> _loadRemote() async {
    isLoading = true;
    update();
    final results = await Future.wait([
      _remote.getCategories(),
      _remote.getAllProducts(),
      _remote.getFeaturedStores(),
    ]);
    final categoryResponse = results[0].fold((_) => <String, dynamic>{}, (v) => v);
    final productResponse = results[1].fold((_) => <String, dynamic>{}, (v) => v);
    final storeResponse = results[2].fold((_) => <String, dynamic>{}, (v) => v);
    final categoryList = categoryResponse['data'] is List ? categoryResponse['data'] as List : const [];
    categories = [
      const ExploreCategoryModel(id: 'all', name: 'all_categories', icon: Icons.apps_rounded),
      ...categoryList.whereType<Map>().map((item) => ExploreCategoryModel(
            id: item['id'].toString(),
            name: item['name']?.toString() ?? '',
            icon: Icons.category_outlined,
          )),
    ];
    final rawProducts = productResponse['data'] is Map
        ? productResponse['data']['data']
        : productResponse['data'];
    _allProducts
      ..clear()
      ..addAll((rawProducts is List ? rawProducts : const [])
          .whereType<Map>()
          .map(_productFromJson));
    final rawStores = storeResponse['data'] is List ? storeResponse['data'] as List : const [];
    _allStores
      ..clear()
      ..addAll(rawStores.whereType<Map>().map(_storeFromJson));
    applyFilters();
    isLoading = false;
    update();
  }

  ExploreProductModel _productFromJson(Map item) => ExploreProductModel(
        id: item['id'].toString(),
        name: item['name']?.toString() ?? '',
        storeName: item['store_name']?.toString() ?? '',
        storeId: item['store_id']?.toString() ?? '',
        categoryId: item['category_id']?.toString() ?? '',
        price: double.tryParse('${item['old_price'] ?? item['price'] ?? 0}') ?? 0,
        salePrice: item['old_price'] != null
            ? double.tryParse('${item['price']}')
            : null,
        rating: double.tryParse('${item['rating'] ?? 0}') ?? 0,
        reviewCount: int.tryParse('${item['rating_count'] ?? 0}') ?? 0,
        hasFreeShipping: item['free_shipping'] == true || item['free_shipping'] == 1,
        hasWholesalePrice: item['has_wholesale'] == true || item['has_wholesale'] == 1,
        isFavorite: item['is_favorite'] == true,
      );

  ExploreStoreModel _storeFromJson(Map item) => ExploreStoreModel(
        id: item['id'].toString(),
        name: item['store_name']?.toString() ?? item['name']?.toString() ?? '',
        category: item['category']?.toString() ?? '',
        rating: double.tryParse('${item['rating'] ?? 0}') ?? 0,
        isOpen: item['is_open'] == true || item['is_open'] == 1,
        productCount: int.tryParse('${item['products_count'] ?? 0}') ?? 0,
      );

  void onSearchChanged(String query) {
    suggestions = _allProducts
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .map((p) => p.name)
        .take(6)
        .toList();
    update();
  }

  void submitSearch(String query) {
    searchFocusNode.unfocus();
    currentQuery = query.trim();
    if (currentQuery.isNotEmpty && !recentSearches.contains(currentQuery)) {
      recentSearches.insert(0, currentQuery);
      if (recentSearches.length > 5) recentSearches.removeLast();
    }
    applyFilters();
  }

  void selectSuggestion(String suggestion) {
    searchTextController.text = suggestion;
    submitSearch(suggestion);
  }

  void closeSearch() {
    searchTextController.clear();
    currentQuery = '';
    suggestions = [];
    searchFocusNode.unfocus();
    applyFilters();
  }

  void clearRecentSearches() { recentSearches = []; update(); }

  void selectCategory(int index) { selectedCategoryIndex = index; selectedSubCategoryId = null; applyFilters(); }
  void selectSubCategory(String id) { selectedSubCategoryId = selectedSubCategoryId == id ? null : id; applyFilters(); }
  List<ExploreSubCategoryModel> get currentSubCategories => const [];
  void switchTab(bool storesTab) { isStoresTab = storesTab; update(); }

  void applyFilterValues({required RangeValues newPriceRange, required double newMinRating, required bool newFreeShippingOnly, required bool newDiscountedOnly}) {
    priceRange = newPriceRange;
    minRating = newMinRating;
    freeShippingOnly = newFreeShippingOnly;
    discountedOnly = newDiscountedOnly;
    applyFilters();
  }

  void setSortBy(String value) { sortBy = value; applyFilters(); }

  Future<void> applyFilters() async {
    var nextProducts = List<ExploreProductModel>.from(_allProducts);
    var nextStores = List<ExploreStoreModel>.from(_allStores);
    if (selectedCategoryIndex > 0 && selectedCategoryIndex < categories.length) {
      final id = categories[selectedCategoryIndex].id;
      nextProducts = nextProducts.where((p) => p.categoryId == id).toList();
    }
    if (currentQuery.isNotEmpty) {
      final query = currentQuery.toLowerCase();
      nextProducts = nextProducts.where((p) => p.name.toLowerCase().contains(query) || p.storeName.toLowerCase().contains(query)).toList();
      nextStores = nextStores.where((s) => s.name.toLowerCase().contains(query)).toList();
    }
    if (discountedOnly) nextProducts = nextProducts.where((p) => p.hasDiscount).toList();
    if (freeShippingOnly) nextProducts = nextProducts.where((p) => p.hasFreeShipping).toList();
    if (minRating > 0) nextProducts = nextProducts.where((p) => p.rating >= minRating).toList();
    nextProducts = nextProducts.where((p) => p.displayPrice >= priceRange.start && p.displayPrice <= priceRange.end).toList();
    if (sortBy == 'price_asc') nextProducts.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
    if (sortBy == 'price_desc') nextProducts.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
    if (sortBy == 'rating') nextProducts.sort((a, b) => b.rating.compareTo(a.rating));
    products = nextProducts;
    stores = nextStores;
    update();
  }

  void resetFilters() { selectedCategoryIndex = 0; selectedSubCategoryId = null; priceRange = const RangeValues(0, 3000000); minRating = 0; freeShippingOnly = false; discountedOnly = false; sortBy = 'latest'; currentQuery = ''; applyFilters(); }
  void removeFilterChip(String key) { if (key == 'discount') discountedOnly = false; if (key == 'rating') minRating = 0; if (key == 'price') priceRange = const RangeValues(0, 3000000); applyFilters(); }

  Future<void> toggleFavorite(String productId) async {
    final token = _token;
    if (token == null) { Get.snackbar('Sign in required', 'Sign in to manage favorites.'); return; }
    await _remote.toggleFavorite(productId, token);
    final index = _allProducts.indexWhere((p) => p.id == productId);
    if (index != -1) _allProducts[index] = _allProducts[index].copyWith(isFavorite: !_allProducts[index].isFavorite);
    applyFilters();
  }

  Future<void> addToCart(String productId) async {
    final token = _token;
    if (token == null) { Get.snackbar('Sign in required', 'Sign in to add products to your cart.'); return; }
    final result = await _remote.addToCart(productId, token);
    result.fold((_) => Get.snackbar('Cart', 'The product could not be added.'), (_) => Get.snackbar('Cart', 'Product added to your cart.'));
  }

  int get activeFilterCount => (discountedOnly ? 1 : 0) + (minRating > 0 ? 1 : 0) + (priceRange.start != 0 || priceRange.end != 3000000 ? 1 : 0);
  List<Map<String, String>> get activeFilterChips => [
        if (discountedOnly) {'key': 'discount', 'label': 'discounted'},
        if (minRating > 0) {'key': 'rating', 'label': '${minRating.toInt()}+'},
        if (priceRange.start != 0 || priceRange.end != 3000000) {'key': 'price', 'label': 'price range'},
      ];
  int get resultCount => isStoresTab ? stores.length : products.length;

  @override
  void onClose() { searchTextController.dispose(); searchFocusNode.dispose(); super.onClose(); }
}
