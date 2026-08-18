import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/show_image_picker.dart';
import 'package:e_commerce/core/services/services.dart';

class BuyerProfileController extends GetxController {
  final MyServices _services = Get.find();

  StatusRequest statusRequest = StatusRequest.none;

  // ─── User data ─────────────────────────────────────────────────────────────
  // TODO: populate from GET /buyer/profile when endpoint is ready
  String userName  = 'خالد أحمد';
  String userEmail = '';
  String userPhone = '0912345678';
  File?   localAvatar;
  String? serverAvatarUrl;

  // ─── Stats ─────────────────────────────────────────────────────────────────
  int ordersCount   = 12;
  int wishlistCount = 7;
  int reviewsCount  = 5;

  // ─── Wallet ─────────────────────────────────────────────────────────────────
  int  walletBalance    = 85000;
  bool isBalanceVisible = true;

  // ─── VIP threshold ─────────────────────────────────────────────────────────
  static const int _vipThreshold = 10;
  bool get isVip => ordersCount >= _vipThreshold;

  // ─── Unread chat badge ─────────────────────────────────────────────────────
  int unreadChats = 3;

  // ─── Spin availability ─────────────────────────────────────────────────────
  bool canSpinToday = true;

  @override
  void onInit() {
    super.onInit();
    userEmail = _services.sharedPreferences.getString('email') ?? '';
    _loadProfile();
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    statusRequest = StatusRequest.loading;
    update();
    // TODO: replace with real API → GET /buyer/profile
    await Future.delayed(const Duration(milliseconds: 500));
    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> refresh() => _loadProfile();

  // ── Wallet balance toggle ──────────────────────────────────────────────────

  void toggleBalanceVisibility() {
    isBalanceVisible = !isBalanceVisible;
    update();
  }

  // ── Avatar picker ──────────────────────────────────────────────────────────

  Future<void> pickAvatar() async {
    final source = await showImagePickerBottomSheet();
    if (source == null) return;
    final picked = await ImagePicker()
        .pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      localAvatar = File(picked.path);
      update();
      // TODO: upload → POST /buyer/profile (multipart)
    }
  }

  // ── Navigation stubs (wire to routes when screens are ready) ───────────────

  void goToOrders()               {} // switch BuyerMainController tab
  void goToWishlist()             {} // TODO: Get.toNamed(AppRoute.buyerWishlist)
  void goToWallet()               {} // TODO: Get.toNamed(AppRoute.buyerWallet)
  void goToSpin()                 {} // TODO: spin bottom-sheet / screen
  void goToAddresses()            {} // TODO: Get.toNamed(AppRoute.buyerAddresses)
  void goToFollowedStores()       {} // TODO: Get.toNamed(AppRoute.buyerFollowedStores)
  void goToChats()                {} // TODO: Get.toNamed(AppRoute.buyerChats)
  void goToMyReviews()            {} // TODO: Get.toNamed(AppRoute.buyerReviews)
  void goToNotificationSettings() {} // TODO: Get.toNamed(AppRoute.buyerNotifSettings)

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final bool? confirmed = await Get.defaultDialog<bool>(
      title: 'buyer_logout_title'.tr,
      titleStyle: const TextStyle(
        color:      AppColor.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize:   18,
      ),
      middleText:      'buyer_logout_body'.tr,
      middleTextStyle: const TextStyle(fontSize: 14),
      radius:          16,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side:  const BorderSide(color: AppColor.greyBorder),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          ),
          onPressed: () => Get.back(result: false),
          child: Text(
            'cancel'.tr,
            style: const TextStyle(
              color:      AppColor.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.error,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            elevation: 0,
          ),
          onPressed: () => Get.back(result: true),
          child: Text(
            'buyer_logout_btn'.tr,
            style: const TextStyle(
              color:      Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
    if (confirmed == true) {
      await _services.sharedPreferences.clear();
      Get.offAllNamed(AppRoute.login);
    }
  }
}
