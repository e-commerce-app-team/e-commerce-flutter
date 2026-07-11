import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/data/datasource/static/explore_mock_data.dart';
import 'package:e_commerce/data/models/explore/explore_models.dart';

class ExploreController extends GetxController {
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  bool isSearchFocused = false;
  bool isStoresTab = false;
  bool isLoading = false;

  int selectedCategoryIndex = 0;
  String? selectedSubCategoryId;
  String currentQuery = '';

  RangeValues priceRange = const RangeValues(0, 3000000);
  double minRating = 0;
  bool freeShippingOnly = false;
  bool discountedOnly = false;
  String sortBy = 'latest';

  List<String> recentSearches = ['سماعات بلوتوث', 'فستان سهرة', 'لابتوب'];
  List<String> suggestions = [];

  final List<ExploreProductModel> _allProducts = List.of(ExploreMockData.products);
  final List<ExploreStoreModel> _allStores = List.of(ExploreMockData.stores);

  List<ExploreProductModel> products = [];
  List<ExploreStoreModel> stores = [];

  @override
  void onInit() {
    super.onInit();
    searchFocusNode.addListener(_handleFocusChange);
    applyFilters();
  }

  void _handleFocusChange() {
    isSearchFocused = searchFocusNode.hasFocus;
    update();
  }

  void onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      suggestions = [];
    } else {
      suggestions = _allProducts
          .where((p) => p.name.contains(query))
          .map((p) => p.name)
          .toSet()
          .take(6)
          .toList();
    }
    update();
  }

  void submitSearch(String query) {
    searchFocusNode.unfocus();
    final trimmed = query.trim();
    currentQuery = trimmed;
    if (trimmed.isNotEmpty && !recentSearches.contains(trimmed)) {
      recentSearches.insert(0, trimmed);
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

  void clearRecentSearches() {
    recentSearches = [];
    update();
  }

  void selectCategory(int index) {
    selectedCategoryIndex = index;
    selectedSubCategoryId = null;
    applyFilters();
  }

  void selectSubCategory(String id) {
    selectedSubCategoryId = selectedSubCategoryId == id ? null : id;
    applyFilters();
  }

  List<ExploreSubCategoryModel> get currentSubCategories {
    if (selectedCategoryIndex <= 0 || selectedCategoryIndex >= ExploreMockData.categories.length) {
      return const [];
    }
    return ExploreMockData.categories[selectedCategoryIndex].subCategories;
  }

  void switchTab(bool storesTab) {
    isStoresTab = storesTab;
    update();
  }

  void applyFilterValues({
    required RangeValues newPriceRange,
    required double newMinRating,
    required bool newFreeShippingOnly,
    required bool newDiscountedOnly,
  }) {
    priceRange = newPriceRange;
    minRating = newMinRating;
    freeShippingOnly = newFreeShippingOnly;
    discountedOnly = newDiscountedOnly;
    applyFilters();
  }

  void setSortBy(String value) {
    sortBy = value;
    applyFilters();
  }

  Future<void> applyFilters() async {
    isLoading = true;
    update();
    await Future.delayed(const Duration(milliseconds: 350));

    var list = List<ExploreProductModel>.from(_allProducts);
    var storeList = List<ExploreStoreModel>.from(_allStores);

    if (selectedCategoryIndex > 0 && selectedCategoryIndex < ExploreMockData.categories.length) {
      final catId = ExploreMockData.categories[selectedCategoryIndex].id;
      list = list.where((p) => p.categoryId == catId).toList();
      storeList = storeList.where((s) => s.category == 'cat_$catId').toList();
    }

    if (currentQuery.isNotEmpty) {
      list = list.where((p) => p.name.contains(currentQuery) || p.storeName.contains(currentQuery)).toList();
      storeList = storeList.where((s) => s.name.contains(currentQuery)).toList();
    }

    if (freeShippingOnly) list = list.where((p) => p.hasFreeShipping).toList();
    if (discountedOnly) list = list.where((p) => p.hasDiscount).toList();
    if (minRating > 0) {
      list = list.where((p) => p.rating >= minRating).toList();
      storeList = storeList.where((s) => s.rating >= minRating).toList();
    }
    list = list.where((p) => p.displayPrice >= priceRange.start && p.displayPrice <= priceRange.end).toList();

    switch (sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
        break;
      case 'price_desc':
        list.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        storeList.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    products = list;
    stores = storeList;
    isLoading = false;
    update();
  }

  void resetFilters() {
    selectedCategoryIndex = 0;
    selectedSubCategoryId = null;
    priceRange = const RangeValues(0, 3000000);
    minRating = 0;
    freeShippingOnly = false;
    discountedOnly = false;
    sortBy = 'latest';
    applyFilters();
  }

  void removeFilterChip(String key) {
    switch (key) {
      case 'subcategory':
        selectedSubCategoryId = null;
        break;
      case 'shipping':
        freeShippingOnly = false;
        break;
      case 'discount':
        discountedOnly = false;
        break;
      case 'rating':
        minRating = 0;
        break;
      case 'price':
        priceRange = const RangeValues(0, 3000000);
        break;
    }
    applyFilters();
  }

  void toggleFavorite(String productId) {
    final allIdx = _allProducts.indexWhere((p) => p.id == productId);
    if (allIdx != -1) {
      _allProducts[allIdx] = _allProducts[allIdx].copyWith(isFavorite: !_allProducts[allIdx].isFavorite);
    }
    final idx = products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      products[idx] = products[idx].copyWith(isFavorite: !products[idx].isFavorite);
    }
    update();
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedSubCategoryId != null) count++;
    if (freeShippingOnly) count++;
    if (discountedOnly) count++;
    if (minRating > 0) count++;
    if (priceRange.start != 0 || priceRange.end != 3000000) count++;
    return count;
  }

  List<Map<String, String>> get activeFilterChips {
    final chips = <Map<String, String>>[];
    if (selectedSubCategoryId != null) {
      ExploreSubCategoryModel? sub;
      for (final s in currentSubCategories) {
        if (s.id == selectedSubCategoryId) {
          sub = s;
          break;
        }
      }
      if (sub != null) chips.add({'key': 'subcategory', 'label': sub.name});
    }
    if (freeShippingOnly) chips.add({'key': 'shipping', 'label': 'free_shipping'});
    if (discountedOnly) chips.add({'key': 'discount', 'label': 'explore_discount_only'});
    if (minRating > 0) chips.add({'key': 'rating', 'label': '${minRating.toInt()}+'});
    if (priceRange.start != 0 || priceRange.end != 3000000) {
      chips.add({'key': 'price', 'label': 'explore_price_range'});
    }
    return chips;
  }

  int get resultCount => isStoresTab ? stores.length : products.length;

  @override
  void onClose() {
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}
