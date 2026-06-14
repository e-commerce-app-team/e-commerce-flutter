import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/functions/show_image_picker.dart';
import 'package:e_commerce/data/model/seller/profile_models.dart';
import 'package:e_commerce/core/services/services.dart';

class SellerProfileController extends GetxController {
  final MyServices myServices = Get.find();

  String get sellerType => myServices.sharedPreferences.getString('seller_type') ?? 'vendor';
  bool get isWholesale => sellerType == 'wholesale';

  // إدارة حالات الطلبات المنفصلة للبروفايل والشحن
  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest saveStatusRequest = StatusRequest.none;

  SellerProfileModel? profile;

  // الحقول النصية الخاصة بالملف الشخصي والبيانات العامة للمتجر فقط
  late final TextEditingController firstNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController storeNameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController cityCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController returnPolicyCtrl;

  // ملفات رفع الصور
  File? newLogo;
  File? newCover;
  File? newProfilePhoto;

  // حقول إعدادات الشحن الخاصة بالبائع
  String shippingMethod = 'our_delivery';
  String whoPaysShipping = 'buyer';
  late final TextEditingController baseFeeCtrl;
  late final TextEditingController perKmCtrl;
  late final TextEditingController perKgCtrl;
  late final TextEditingController thresholdCtrl;

  @override
  void onInit() {
    super.onInit();
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

    // قيم افتراضية آمنة لحساب الشحن لتجنب الفراغات المفاجئة
    baseFeeCtrl   = TextEditingController(text: '2000');
    perKmCtrl     = TextEditingController(text: '100');
    perKgCtrl     = TextEditingController(text: '500');
    thresholdCtrl = TextEditingController(text: '100000');
  }

  Future<void> loadProfile() async {
    statusRequest = StatusRequest.loading;
    update();

    // محاكاة استجابة الخادم لتهيئة البيانات
    await Future.delayed(const Duration(milliseconds: 600));

    profile = SellerProfileModel.mock();
    _fillFormFromProfile();

    statusRequest = StatusRequest.success;
    update();
  }

  void _fillFormFromProfile() {
    if (profile == null) return;
    firstNameCtrl.text    = profile!.firstName;
    lastNameCtrl.text     = profile!.lastName;
    storeNameCtrl.text    = profile!.storeName;
    descCtrl.text         = profile!.description ?? '';
    cityCtrl.text         = profile!.city;
    phoneCtrl.text        = profile!.phone;
    returnPolicyCtrl.text = profile!.returnPolicy;
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
    // التحقق الأساسي من صحة البيانات (Edge Case Validation) قبل بدء الـ Loading
    if (storeNameCtrl.text.trim().isEmpty) {
      customSnackbar('warning'.tr, 'store_name_required'.tr); // استخدام الترجمة لحفظ الاحترافية العالمية
      return;
    }

    saveStatusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(milliseconds: 700));

    saveStatusRequest = StatusRequest.success;
    customSnackbar('success'.tr, 'profile_updated_success'.tr, isError: false);
    update();
  }

  Future<void> saveShipping() async {
    saveStatusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(milliseconds: 600));

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
    // تنظيف مؤكد لجميع الـ Controllers لحماية ذاكرة الهاتف من التسريب (Memory Leak)
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