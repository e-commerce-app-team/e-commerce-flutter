import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/model/seller/coupon_models.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class SellerCouponsController extends GetxController {
  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest formStatusRequest = StatusRequest.none;

  List<CouponModel>   _allCoupons = [];
  List<CategoryModel> categories  = [];
  int selectedTabIndex = 0;

  List<CouponModel> get displayedCoupons {
    switch (selectedTabIndex) {
      case 1:  return _allCoupons.where((c) => c.isActive).toList();
      case 2:  return _allCoupons.where((c) => c.isExpired).toList();
      case 3:  return _allCoupons.where((c) => c.isPaused).toList();
      default: return _allCoupons;
    }
  }

  int get totalCount   => _allCoupons.length;
  int get activeCount  => _allCoupons.where((c) => c.isActive).length;
  int get expiredCount => _allCoupons.where((c) => c.isExpired).length;
  int get pausedCount  => _allCoupons.where((c) => c.isPaused).length;
  int get totalUsage   => _allCoupons.fold(0, (s, c) => s + c.usedCount);

  final formKey        = GlobalKey<FormState>();
  final codeCtrl       = TextEditingController();
  final valueCtrl      = TextEditingController();
  final minOrderCtrl   = TextEditingController();
  final maxUsageCtrl   = TextEditingController();
  final maxPerUserCtrl = TextEditingController(text: '1');

  String  formType       = 'percentage';
  String  formAppliesTo  = 'all';
  int?    formCategoryId;
  String? formStartDate;
  String? formEndDate;
  String  formStatus     = 'active';

  CouponModel? _editingCoupon;
  bool get isEditing => _editingCoupon != null;

  void changeTab(int i) { selectedTabIndex = i; update(); }

  Future<void> loadCoupons() async {
    statusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));
    _allCoupons = CouponModel.mockList();
    categories  = CategoryModel.mockTree();
    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> refreshCoupons() => loadCoupons();

  void prepareAddForm() {
    _editingCoupon = null;
    _clearForm();
    formStartDate = _todayStr();
    update();
  }

  void prepareEditForm(CouponModel c) {
    _editingCoupon      = c;
    codeCtrl.text       = c.code;
    formType            = c.type;
    valueCtrl.text      = c.type != 'free_shipping' ? c.value.toInt().toString() : '';
    minOrderCtrl.text   = c.minOrderAmount > 0 ? c.minOrderAmount.toString() : '';
    maxUsageCtrl.text   = c.maxUsage?.toString() ?? '';
    maxPerUserCtrl.text = c.maxUsagePerUser.toString();
    formAppliesTo       = c.appliesTo;
    formCategoryId      = c.categoryId;
    formStartDate       = c.startDate;
    formEndDate         = c.endDate;
    formStatus          = c.status;
    update();
  }

  void _clearForm() {
    codeCtrl.clear(); valueCtrl.clear();
    minOrderCtrl.clear(); maxUsageCtrl.clear();
    maxPerUserCtrl.text = '1';
    formType       = 'percentage';
    formAppliesTo  = 'all';
    formCategoryId = null;
    formStartDate  = null;
    formEndDate    = null;
    formStatus     = 'active';
  }

  void setFormType(String t) {
    formType = t;
    if (t == 'free_shipping') valueCtrl.clear();
    update();
  }

  void setAppliesTo(String a) {
    formAppliesTo = a;
    if (a == 'all') formCategoryId = null;
    update();
  }

  void setFormCategory(int? id) { formCategoryId = id; update(); }
  void setStartDate(String d)   { formStartDate = d;   update(); }
  void setEndDate(String d)     { formEndDate   = d;   update(); }
  void setFormStatus(String s)  { formStatus    = s;   update(); }

  void autoGenerateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand  = Random();
    codeCtrl.text = List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
    update();
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    if (formType != 'free_shipping' && valueCtrl.text.trim().isEmpty) {
      customSnackbar('warning'.tr, 'coupon_value_required'.tr);
      return;
    }
    if (formEndDate == null || formEndDate!.isEmpty) {
      customSnackbar('warning'.tr, 'coupon_end_date_required'.tr);
      return;
    }
    if (formAppliesTo == 'category' && formCategoryId == null) {
      customSnackbar('warning'.tr, 'coupon_category_required'.tr);
      return;
    }

    formStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));

    final cat = formCategoryId != null
        ? categories.firstWhereOrNull((c) => c.id == formCategoryId)
        : null;

    final newId = isEditing
        ? _editingCoupon!.id
        : (_allCoupons.isEmpty ? 1 : _allCoupons.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1);

    final coupon = CouponModel(
      id:              newId,
      code:            codeCtrl.text.trim().toUpperCase(),
      type:            formType,
      value:           double.tryParse(valueCtrl.text) ?? 0,
      minOrderAmount:  int.tryParse(minOrderCtrl.text) ?? 0,
      maxUsage:        maxUsageCtrl.text.isNotEmpty ? int.tryParse(maxUsageCtrl.text) : null,
      maxUsagePerUser: int.tryParse(maxPerUserCtrl.text) ?? 1,
      usedCount:       isEditing ? _editingCoupon!.usedCount : 0,
      status:          formStatus,
      startDate:       formStartDate ?? _todayStr(),
      endDate:         formEndDate!,
      appliesTo:       formAppliesTo,
      categoryId:      formCategoryId,
      categoryName:    cat?.name,
    );

    if (isEditing) {
      final idx = _allCoupons.indexWhere((c) => c.id == _editingCoupon!.id);
      if (idx != -1) _allCoupons[idx] = coupon;
    } else {
      _allCoupons.insert(0, coupon);
    }

    formStatusRequest = StatusRequest.success;
    customSnackbar(
      isEditing ? 'coupon_updated'.tr : 'coupon_added'.tr,
      isEditing ? 'coupon_updated_msg'.tr : 'coupon_added_msg'.tr,
      isError: false,
    );
    _clearForm();
    update();
    Get.back();
  }

  Future<void> toggleStatus(CouponModel coupon) async {
    if (coupon.isExpired) return;
    final newStatus = coupon.isActive ? 'paused' : 'active';
    final idx = _allCoupons.indexWhere((c) => c.id == coupon.id);
    if (idx != -1) {
      _allCoupons[idx] = coupon.copyWith(status: newStatus);
      update();
    }
    customSnackbar(
      newStatus == 'active' ? 'coupon_activated'.tr : 'coupon_paused_msg'.tr,
      '', isError: false,
    );
  }

  Future<void> deleteCoupon(CouponModel coupon) async {
    _allCoupons.removeWhere((c) => c.id == coupon.id);
    update();
    customSnackbar('coupon_deleted'.tr, '', isError: false);
  }

  void copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    customSnackbar('coupon_copied'.tr, code, isError: false);
  }

  String formatDate(String date) {
    if (date.isEmpty) return '';
    final p = date.split('-');
    return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : date;
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() { super.onInit(); loadCoupons(); }

  @override
  void onClose() {
    for (final c in [codeCtrl, valueCtrl, minOrderCtrl, maxUsageCtrl, maxPerUserCtrl]) {
      c.dispose();
    }
    super.onClose();
  }
}
