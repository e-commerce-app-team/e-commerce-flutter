import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/functions/show_image_picker.dart';
import 'package:e_commerce/data/datasource/remote/seller/seller_profile_data.dart';
import 'package:e_commerce/data/model/seller/profile_models.dart';
import 'package:e_commerce/core/services/services.dart';

class SellerProfileController extends GetxController {
  final MyServices myServices = Get.find();
  late final SellerProfileData profileData;

  String get _token => myServices.sharedPreferences.getString('token') ?? '';

  /// نوع البائع من SharedPreferences (يُحفظ عند تسجيل الدخول)
  String get sellerType =>
      profile?.sellerType ??
      myServices.sharedPreferences.getString('seller_type') ??
      myServices.sharedPreferences.getString('role') ??
      'vendor';

  bool get isWholesale => sellerType == 'wholesale';

  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest saveStatusRequest = StatusRequest.none;

  SellerProfileModel? profile;

  late final TextEditingController firstNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController storeNameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController cityCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController returnPolicyCtrl;

  File? newLogo;
  File? newCover;
  File? newProfilePhoto;

  // Shipping - محلي فقط (الباك لم ينفّذ endpoint الشحن بعد)
  String shippingMethod = 'our_delivery';
  String whoPaysShipping = 'buyer';
  late final TextEditingController baseFeeCtrl;
  late final TextEditingController perKmCtrl;
  late final TextEditingController perKgCtrl;
  late final TextEditingController thresholdCtrl;

  @override
  void onInit() {
    super.onInit();
    profileData = SellerProfileData(Get.find<Crud>());
    _initControllers();
    loadProfile();
  }

  void _initControllers() {
    firstNameCtrl    = TextEditingController();
    lastNameCtrl     = TextEditingController();
    storeNameCtrl    = TextEditingController();
    descCtrl         = TextEditingController();
    cityCtrl         = TextEditingController();
    phoneCtrl        = TextEditingController();
    returnPolicyCtrl = TextEditingController();

    baseFeeCtrl   = TextEditingController();
    perKmCtrl     = TextEditingController();
    perKgCtrl     = TextEditingController();
    thresholdCtrl = TextEditingController();
  }

  Future<void> loadProfile() async {
    statusRequest = StatusRequest.loading;
    update();

    final response = await profileData.getProfile(_token);

    response.fold(
      (failure) {
        statusRequest = failure;
        update();
      },
      (data) {
        // الباك يُرجع: { "success": true, "data": { ... } }
        if (data['success'] == true && data['data'] != null) {
          profile = SellerProfileModel.fromJson(data, sellerType: sellerType);
          _fillFormFromProfile();
          statusRequest = StatusRequest.success;
        } else {
          statusRequest = StatusRequest.failure;
        }
        update();
      },
    );
  }

  Future<void> refreshProfile() => loadProfile();

  void _fillFormFromProfile() {
    if (profile == null) return;
    firstNameCtrl.text    = profile!.firstName;
    lastNameCtrl.text     = profile!.lastName;
    storeNameCtrl.text    = profile!.storeName;
    descCtrl.text         = profile!.storeDescription ?? '';
    cityCtrl.text         = profile!.detailedAddress ?? '';
    phoneCtrl.text        = profile!.phone;
    returnPolicyCtrl.text = profile!.storeReturnPolicy ?? '';
  }

  Future<void> _pickImage(void Function(File) onPicked) async {
    final src = await showImagePickerBottomSheet();
    if (src == null) return;

    final pickedFile = await ImagePicker().pickImage(source: src, imageQuality: 80);
    if (pickedFile != null) {
      onPicked(File(pickedFile.path));
      update();
    }
  }

  Future<void> pickLogo()         => _pickImage((f) => newLogo = f);
  Future<void> pickCover()        => _pickImage((f) => newCover = f);
  Future<void> pickProfilePhoto() => _pickImage((f) => newProfilePhoto = f);

  void setShippingMethod(String m) { shippingMethod = m; update(); }
  void setWhoPays(String w)        { whoPaysShipping = w; update(); }

  Future<void> saveProfile() async {
    if (storeNameCtrl.text.trim().isEmpty) {
      customSnackbar('warning'.tr, 'store_name_required'.tr);
      return;
    }

    saveStatusRequest = StatusRequest.loading;
    update();

    final data = <String, String>{
      'store_name':        storeNameCtrl.text.trim(),
      'store_description': descCtrl.text.trim(),
      'detailed_address':  cityCtrl.text.trim(),
      'return_policy':     returnPolicyCtrl.text.trim(),
      'first_name':        firstNameCtrl.text.trim(),
      'last_name':         lastNameCtrl.text.trim(),
      'phone':             phoneCtrl.text.trim(),
    };
    final response = await profileData.updateProfile(
      _token,
      data: data,
      logo: newLogo,
      cover: newCover,
    );

    response.fold(
      (failure) {
        saveStatusRequest = failure;
        update();
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (res) {
        if (res['success'] == true) {
          // الباك يُرجع المستخدم المحدّث كاملاً
          if (res['data'] != null || res['user'] != null) {
            final raw = res['data'] ?? res['user'];
            // نبني model مؤقتاً من البيانات المُرجَعة
            profile = SellerProfileModel.fromJson({'data': raw}, sellerType: sellerType);
          }
          newLogo  = null;
          newCover = null;
          saveStatusRequest = StatusRequest.success;
          customSnackbar('success'.tr, 'profile_updated_success'.tr, isError: false);
        } else {
          saveStatusRequest = StatusRequest.failure;
          customSnackbar('warning'.tr, (res['message'] ?? '').toString());
        }
        update();
      },
    );
  }

  /// ملاحظة: shipping settings endpoint غير موجود على الباك بعد.
  /// هذا placeholder يعمل محلياً فقط حتى يُنفّذ الباك تيم الـ endpoint.
  Future<void> saveShipping() async {
    saveStatusRequest = StatusRequest.loading;
    update();

    // TODO: ربط بـ /seller/shipping-settings عند توفره على الباك
    // محاكاة نجاح محلي
    await Future.delayed(const Duration(milliseconds: 500));
    saveStatusRequest = StatusRequest.success;
    customSnackbar('success'.tr, 'shipping_settings_saved'.tr, isError: false);
    update();
  }

  Future<void> logout() async {
    await myServices.sharedPreferences.clear();
    Get.offAllNamed(AppRoute.login);
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    storeNameCtrl.dispose();
    descCtrl.dispose();
    cityCtrl.dispose();
    phoneCtrl.dispose();
    returnPolicyCtrl.dispose();
    baseFeeCtrl.dispose();
    perKmCtrl.dispose();
    perKgCtrl.dispose();
    thresholdCtrl.dispose();
    super.onClose();
  }
}
