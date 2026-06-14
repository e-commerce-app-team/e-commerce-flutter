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

  MyServices myServices = Get.find();

  String get sellerType =>
      myServices.sharedPreferences.getString('seller_type') ?? 'vendor';
  bool get isWholesale => sellerType == 'wholesale';

  StatusRequest statusRequest       = StatusRequest.none;
  StatusRequest saveStatusRequest   = StatusRequest.none;
  StatusRequest walletStatusRequest = StatusRequest.none;

  SellerProfileModel? profile;
  WalletModel?        wallet;

  final storeNameCtrl    = TextEditingController();
  final descCtrl         = TextEditingController();
  final cityCtrl         = TextEditingController();
  final phoneCtrl        = TextEditingController();
  final returnPolicyCtrl = TextEditingController();
  final firstNameCtrl    = TextEditingController();
  final lastNameCtrl     = TextEditingController();

  File? newLogo;
  File? newCover;
  File? newProfilePhoto;

  String shippingMethod  = 'our_delivery';
  String whoPaysSipping  = 'buyer';
  final baseFeeCtrl   = TextEditingController(text: '2000');
  final perKmCtrl     = TextEditingController(text: '100');
  final perKgCtrl     = TextEditingController(text: '500');
  final thresholdCtrl = TextEditingController(text: '100000');

  final withdrawAmountCtrl = TextEditingController();
  final bankNameCtrl       = TextEditingController();
  final accountNumCtrl     = TextEditingController();
  final accountNameCtrl    = TextEditingController();
  String withdrawMethod    = 'bank_transfer';

  Future<void> loadProfile() async {
    statusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));
    // TODO: var res = await profileData.getProfile();
    profile = SellerProfileModel.mock();
    _fillFormFromProfile();
    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> loadWallet() async {
    walletStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: var res = await walletData.getWallet();
    wallet = WalletModel.mock();
    walletStatusRequest = StatusRequest.success;
    update();
  }

  void _fillFormFromProfile() {
    if (profile == null) return;
    storeNameCtrl.text    = profile!.storeName;
    descCtrl.text         = profile!.description ?? '';
    cityCtrl.text         = profile!.city;
    phoneCtrl.text        = profile!.phone;
    returnPolicyCtrl.text = profile!.returnPolicy;
    firstNameCtrl.text    = profile!.firstName;
    lastNameCtrl.text     = profile!.lastName;
  }

  Future<void> _pickImage(void Function(File) onPicked) async {
    final src = await showImagePickerBottomSheet();
    if (src == null) return;
    final f = await ImagePicker().pickImage(source: src, imageQuality: 80);
    if (f != null) { onPicked(File(f.path)); update(); }
  }

  Future<void> pickLogo()         => _pickImage((f) => newLogo = f);
  Future<void> pickCover()        => _pickImage((f) => newCover = f);
  Future<void> pickProfilePhoto() => _pickImage((f) => newProfilePhoto = f);

  void setShippingMethod(String m) { shippingMethod = m; update(); }
  void setWhoPays(String w)        { whoPaysSipping = w; update(); }

  Future<void> saveProfile() async {
    if (storeNameCtrl.text.trim().isEmpty) {
      customSnackbar('تنبيه', 'اسم المتجر مطلوب');
      return;
    }
    saveStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));
    // TODO: await profileData.updateProfile(textData, filesData);
    saveStatusRequest = StatusRequest.success;
    customSnackbar('تم الحفظ', 'تم تحديث الملف الشخصي بنجاح', isError: false);
    update();
  }

  Future<void> saveShipping() async {
    saveStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: await shippingData.updateSettings(...)
    saveStatusRequest = StatusRequest.success;
    customSnackbar('تم الحفظ', 'تم حفظ إعدادات الشحن', isError: false);
    update();
  }

  Future<void> requestWithdrawal() async {
    final amount = int.tryParse(withdrawAmountCtrl.text.trim()) ?? 0;
    if (amount < 10000) {
      customSnackbar('تنبيه', 'الحد الأدنى للسحب SP 10,000');
      return;
    }
    if (wallet != null && amount > wallet!.balance) {
      customSnackbar('تنبيه', 'المبلغ أكبر من رصيدك المتاح');
      return;
    }
    if (withdrawMethod == 'bank_transfer' &&
        (bankNameCtrl.text.isEmpty || accountNumCtrl.text.isEmpty)) {
      customSnackbar('تنبيه', 'الرجاء إدخال بيانات الحساب البنكي');
      return;
    }
    saveStatusRequest = StatusRequest.loading;
    update();
    await Future.delayed(const Duration(milliseconds: 700));
    // TODO: await walletData.requestWithdrawal(...)
    saveStatusRequest = StatusRequest.success;
    customSnackbar('تم الطلب',
        'تم إرسال طلب السحب — ستتم المعالجة خلال 24 ساعة',
        isError: false);
    withdrawAmountCtrl.clear();
    bankNameCtrl.clear();
    accountNumCtrl.clear();
    accountNameCtrl.clear();
    update();
    Get.back();
  }

  Future<void> logout() async {
    // TODO: POST /auth/logout
    await myServices.sharedPreferences.clear();
    Get.offAllNamed(AppRoute.login);
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadWallet();
  }

  @override
  void onClose() {
    for (final c in [
      storeNameCtrl, descCtrl, cityCtrl, phoneCtrl,
      returnPolicyCtrl, firstNameCtrl, lastNameCtrl,
      baseFeeCtrl, perKmCtrl, perKgCtrl, thresholdCtrl,
      withdrawAmountCtrl, bankNameCtrl, accountNumCtrl, accountNameCtrl,
    ]) c.dispose();
    super.onClose();
  }
}
