import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/functions/handling_data_controller.dart';
import 'package:e_commerce/data/model/seller/coupon_models.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_coupons_data.dart';
import 'package:e_commerce/core/services/services.dart';

class SellerCouponsController extends GetxController {
  SellerCouponsData couponsData = SellerCouponsData(Get.find());
  MyServices myServices = Get.find();
  String get token => myServices.sharedPreferences.getString('token') ?? "";

  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest formStatusRequest = StatusRequest.none;

  List<
      CouponModel>   _allCoupons = [];
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

    var response = await couponsData.getCoupons(token);
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['success'] == true) {
        List data = [];
        if (response['data'] is List) {
          data = response['data'];
        } else if (response['data'] != null && response['data']['data'] is List) {
          data = response['data']['data'];
        }
        _allCoupons = data.map((e) => CouponModel.fromJson(e)).toList();
        categories  = CategoryModel.mockTree(); // Or fetch from Categories API if needed
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
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
    maxUsageCtrl.text   = c.maxUses?.toString() ?? '';
    maxPerUserCtrl.text = c.usageLimitPerUser == 'once' ? '1' : 'unlimited';
    formAppliesTo       = c.applyToAllProducts ? 'all' : 'category'; // Adjust based on how UI is implemented
    formCategoryId      = null; // Would need product matching
    formStartDate       = c.startsAt;
    formEndDate         = c.expiresAt;
    formStatus          = c.isActive ? 'active' : 'paused';
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

    Map<String, dynamic> data = {
      'title': '', // UI might not have a title field but backend accepts it
      'type': formType,
      'value': valueCtrl.text.isNotEmpty ? valueCtrl.text : '0',
      'min_order_amount': minOrderCtrl.text.isNotEmpty ? minOrderCtrl.text : '0',
      if (maxUsageCtrl.text.isNotEmpty) 'max_uses': maxUsageCtrl.text,
      'usage_limit_per_user': maxPerUserCtrl.text == '1' ? 'once' : 'unlimited',
      if (formStartDate != null) 'starts_at': formStartDate,
      'expires_at': formEndDate,
      'apply_to_all_products': formAppliesTo == 'all' ? '1' : '0',
      // 'product_ids': ... // If you have specific products
    };

    var response;
    if (isEditing) {
      response = await couponsData.updateCoupon(token, _editingCoupon!.id.toString(), data);
    } else {
      response = await couponsData.createCoupon(token, data);
    }

    formStatusRequest = handlingData(response);

    if (StatusRequest.success == formStatusRequest) {
      if (response['success'] == true) {
        customSnackbar(
          isEditing ? 'coupon_updated'.tr : 'coupon_added'.tr,
          isEditing ? 'coupon_updated_msg'.tr : 'coupon_added_msg'.tr,
          isError: false,
        );
        _clearForm();
        Get.back();
        loadCoupons();
      } else {
        customSnackbar('خطأ', response['message'] ?? 'فشل حفظ الكوبون');
        formStatusRequest = StatusRequest.failure;
      }
    } else {
      customSnackbar('خطأ', 'حدث خطأ في الاتصال');
    }
    update();
  }

  Future<void> toggleStatus(CouponModel coupon) async {
    if (coupon.isExpired) return;
    statusRequest = StatusRequest.loading;
    update();

    var response = await couponsData.toggleCoupon(token, coupon.id.toString());
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['success'] == true) {
        customSnackbar(
          coupon.isActive ? 'coupon_paused_msg'.tr : 'coupon_activated'.tr,
          '', isError: false,
        );
        loadCoupons();
      } else {
        customSnackbar('خطأ', response['message'] ?? 'فشل تغيير حالة الكوبون');
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  Future<void> deleteCoupon(CouponModel coupon) async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await couponsData.deleteCoupon(token, coupon.id.toString());
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['success'] == true) {
        customSnackbar('coupon_deleted'.tr, '', isError: false);
        loadCoupons();
      } else {
        customSnackbar('خطأ', response['message'] ?? 'فشل حذف الكوبون');
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  void copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    customSnackbar('coupon_copied'.tr, code, isError: false);
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
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
