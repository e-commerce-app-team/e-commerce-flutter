import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/buyer/store_detail_datasource.dart';
import 'package:e_commerce/data/models/buyer/store_detail_models.dart';

class BuyerStoreDetailController extends GetxController {
  BuyerStoreDetailController({required this.storeId});

  final String storeId;
  final BuyerStoreDetailDataSource _dataSource = BuyerStoreDetailDataSource();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();

  StatusRequest statusRequest = StatusRequest.loading;
  StatusRequest departmentsStatus = StatusRequest.loading;
  StatusRequest reviewsStatus = StatusRequest.loading;
  StatusRequest productsStatus = StatusRequest.loading;
  BuyerStoreDetailModel? store;
  List<BuyerStoreDepartmentModel> departments = [];
  List<BuyerStoreDepartmentModel> departmentPath = [];
  List<BuyerStoreProductModel> products = [];
  List<BuyerStoreReviewModel> reviews = [];

  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  bool isTogglingFollow = false;
  bool isSubmittingReview = false;
  int? selectedDepartmentId;
  num? minPrice;
  num? maxPrice;
  String sortBy = 'latest';
  double selectedRating = 5;
  Timer? _searchDebounce;

  BuyerStoreReviewModel? get myReview {
    if (buyerId <= 0) return null;
    for (final review in reviews) {
      if (review.reviewerId == buyerId) return review;
    }
    return null;
  }

  bool get isAuthenticated => _token?.isNotEmpty == true;

  String? get _token {
    try {
      return Get.find<MyServices>().sharedPreferences.getString('token');
    } catch (_) {
      return null;
    }
  }

  int get buyerId {
    try {
      return int.tryParse(
            Get.find<MyServices>().sharedPreferences.getString('id') ?? '0',
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  String get buyerName {
    try {
      final prefs = Get.find<MyServices>().sharedPreferences;
      final first = prefs.getString('first_name') ?? '';
      final last = prefs.getString('last_name') ?? '';
      final fullName = '$first $last'.trim();
      return fullName.isNotEmpty ? fullName : (prefs.getString('name') ?? '');
    } catch (_) {
      return '';
    }
  }

  List<BuyerStoreDepartmentModel> get visibleDepartments =>
      departments.where((item) => item.isVisible).toList();

  List<BuyerStoreDepartmentModel> get currentDepartments => visibleDepartments;
  int get activeFilterCount {
    return [
      selectedDepartmentId,
      minPrice,
      maxPrice,
      searchController.text.trim().isEmpty ? null : searchController.text,
      sortBy == 'latest' ? null : sortBy,
    ].where((item) => item != null).length;
  }

  @override
  void onInit() {
    super.onInit();
    loadStore();
  }

  Future<void> loadStore() async {
    statusRequest = StatusRequest.loading;
    update();

    await Future.wait([
      _loadDetails(),
      _loadDepartments(),
      _loadReviews(),
      loadProducts(reset: true),
    ]);

    statusRequest = store == null
        ? StatusRequest.failure
        : StatusRequest.success;
    update();
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      page = 1;
      hasMore = true;
      products = [];
      productsStatus = StatusRequest.loading;
    } else {
      if (!hasMore || isLoadingMore) return;
      isLoadingMore = true;
    }
    update();

    final result = await _dataSource.getProducts(
      storeId,
      token: _token,
      page: page,
      departmentId: selectedDepartmentId,
      query: searchController.text,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
    );

    result.fold(
      (_) {
        productsStatus = StatusRequest.failure;
      },
      (response) {
        final raw = _extractPayload(response);
        final list = _extractList(response);
        final newProducts = list
            .map((item) => BuyerStoreProductModel.fromJson(item))
            .toList();
        products = reset ? newProducts : [...products, ...newProducts];

        final lastPage = raw is Map
            ? int.tryParse('${raw['last_page']}') ?? page
            : page;
        hasMore = page < lastPage;
        page++;
        productsStatus = StatusRequest.success;
      },
    );

    isLoadingMore = false;
    update();
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      loadProducts(reset: true);
    });
  }

  Future<void> openDepartment(BuyerStoreDepartmentModel department) async {
    selectedDepartmentId = department.id;

    if (department.hasChildren) {
      departmentPath = [...departmentPath, department];

      await _loadDepartments(parentId: department.id);

      products = [];
      productsStatus = StatusRequest.success;
      update();
      return;
    }

    // وصلنا إلى آخر مستوى.
    departmentPath = [...departmentPath, department];

    await loadProducts(reset: true);
  }

  void popDepartment() {
    if (departmentPath.isEmpty) {
      selectedDepartmentId = null;
      products = [];
      update();
      return;
    }

    final path = [...departmentPath]..removeLast();
    departmentPath = path;

    if (path.isEmpty) {
      selectedDepartmentId = null;
      products = [];
    } else {
      selectedDepartmentId = path.last.id;

      // إذا رجعنا لقسم أب، لا نعرض منتجاته.
      if (path.last.hasChildren) {
        products = [];
        productsStatus = StatusRequest.loading;
      } else {
        loadProducts(reset: true);
        return;
      }
    }

    update();
  }

  void selectDepartmentOnly(BuyerStoreDepartmentModel department) {
    selectedDepartmentId = department.id;
    loadProducts(reset: true);
  }

  void applyFilters({num? min, num? max, required String sort}) {
    minPrice = min;
    maxPrice = max;
    sortBy = sort;
    loadProducts(reset: true);
  }

  Future<void> clearFilters() async {
    minPrice = null;
    maxPrice = null;
    sortBy = 'latest';
    selectedDepartmentId = null;
    departmentPath = [];
    searchController.clear();

    products = [];
    productsStatus = StatusRequest.success;

    await _loadDepartments();

    update();
  }

  Future<void> toggleFollow() async {
    final token = _token;
    final current = store;
    if (token == null || token.isEmpty || current == null) {
      _showLoginMessage();
      return;
    }

    if (isTogglingFollow) return;
    isTogglingFollow = true;

    final following = current.isFollowing;
    store = current.copyWith(
      isFollowing: !following,
      followersCount: current.followersCount + (following ? -1 : 1),
    );
    update();

    final result = await _dataSource.toggleFollow(storeId, token);
    result.fold(
      (_) {
        store = current;
        update();
        Get.snackbar('تعذر تنفيذ المتابعة', 'تحقق من الاتصال وحاول مجدداً');
      },
      (response) {
        if (response['success'] != true) {
          store = current;
          update();
        } else {
          store = store?.copyWith(
            isFollowing: response['is_following'] == true,
            followersCount: _intFromResponse(
              response['followers_count'],
              fallback: store?.followersCount ?? 0,
            ),
          );
        }
      },
    );
    isTogglingFollow = false;
    update();
  }

  Future<void> submitReview() async {
    final token = _token;
    final comment = reviewController.text.trim();
    if (token == null || token.isEmpty) {
      _showLoginMessage();
      return;
    }
    if (store?.canReview != true && myReview == null) {
      Get.snackbar('error'.tr, 'buyer_store_review_not_eligible'.tr);
      return;
    }
    if (comment.isEmpty) {
      Get.snackbar('التعليق مطلوب', 'اكتب تجربتك مع المتجر قبل الإرسال');
      return;
    }

    if (isSubmittingReview) return;
    isSubmittingReview = true;
    update();

    final result = await _dataSource.addReview(
      storeId,
      token,
      rating: selectedRating,
      comment: comment,
    );

    result.fold(
      (_) => Get.snackbar('تعذر إرسال التقييم', 'حاول مرة أخرى بعد قليل'),
      (response) async {
        if (response['success'] != true) {
          Get.snackbar(
            'تعذر إرسال التقييم',
            response['message']?.toString() ?? 'حاول مرة أخرى',
          );
          return;
        }
        store = store?.copyWith(
          rating: _doubleFromResponse(
            response['rating'],
            fallback: store?.rating ?? 0,
          ),
          reviewsCount: _intFromResponse(
            response['reviews_count'],
            fallback: store?.reviewsCount ?? 0,
          ),
        );
        reviewController.clear();
        selectedRating = 5;
        await _loadReviews();
        await _loadDetails();
        update();
        Get.back();
        Get.snackbar('تم إرسال التقييم', 'شكراً لمشاركة رأيك');
      },
    );
    isSubmittingReview = false;
    update();
  }

  void prepareReview() {
    final review = myReview;
    selectedRating = review?.rating ?? 5;
    reviewController.text = review?.comment ?? '';
  }

  Future<void> _loadDetails() async {
    final result = await _dataSource.getStoreDetails(storeId, token: _token);
    result.fold((_) => store = null, (response) {
      final payload = _extractPayload(response);
      if (payload is Map) {
        store = BuyerStoreDetailModel.fromJson(
          Map<String, dynamic>.from(payload),
        );
      }
    });
  }

  Future<void> _loadDepartments({int? parentId}) async {
    departmentsStatus = StatusRequest.loading;
    update();
    final result = await _dataSource.getDepartments(
      storeId,
      token: _token,
      parentId: parentId,
    );

    result.fold(
      (_) {
        departments = [];
        departmentsStatus = StatusRequest.failure;
      },
      (response) {
        final list = _extractList(response);

        final parsed = list
            .map(
              (item) => BuyerStoreDepartmentModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((item) => item.isVisible)
            .toList();

        departments = parsed;
        departmentsStatus = StatusRequest.success;
      },
    );

    update();
  }

  Future<void> _loadReviews() async {
    reviewsStatus = StatusRequest.loading;
    update();
    final result = await _dataSource.getReviews(storeId, token: _token);
    result.fold(
      (_) {
        reviews = [];
        reviewsStatus = StatusRequest.failure;
      },
      (response) {
        reviews = _extractList(
          response,
        ).map((item) => BuyerStoreReviewModel.fromJson(item)).toList();
        reviewsStatus = StatusRequest.success;
      },
    );
  }

  dynamic _extractPayload(Map response) {
    final data = response['data'];
    if (data is Map && data['data'] != null) return data['data'];
    return data ?? response;
  }

  List<Map<String, dynamic>> _extractList(Map response) {
    final payload = _extractPayload(response);
    final raw = payload is List
        ? payload
        : payload is Map && payload['data'] is List
        ? payload['data'] as List
        : const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  void _showLoginMessage() {
    Get.snackbar(
      'تسجيل الدخول مطلوب',
      'سجل دخولك لتتمكن من استخدام هذه الميزة',
    );
  }

  int _intFromResponse(dynamic value, {required int fallback}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _doubleFromResponse(dynamic value, {required double fallback}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    reviewController.dispose();
    super.onClose();
  }
}
