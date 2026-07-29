// ─────────────────────────────────────────────────────────────────────────────
// lib/controller/buyer/cart_controller.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/color.dart';
import '../../data/models/buyer/cart_models.dart';

class CartController extends GetxController {
  // ── Observable State ─────────────────────────────────────────────────────────
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  // Promo code state
  final TextEditingController promoTextCtrl = TextEditingController();
  final RxString appliedPromoCode = ''.obs;
  final RxString promoError = ''.obs;
  final RxBool isApplyingPromo = false.obs;
  final RxDouble discountPercentage = 0.0.obs;

  // Shipping (static for now, comes from API in production)
  final RxDouble shippingFee = 15.0.obs;
  final RxBool isFreeShipping = false.obs;

  // ── Valid promo codes (بيانات وهمية — تُستبدل بـ API) ────────────────────────
  static const Map<String, double> _validCodes = {
    'SAVE10': 10.0,
    'SAVE20': 20.0,
    'WELCOME': 15.0,
    'FLASH30': 30.0,
  };

  // ── Computed getters ─────────────────────────────────────────────────────────
  double get subtotal =>
      cartItems.fold(0.0, (acc, item) => acc + item.lineTotal);

  double get discountAmount => subtotal * (discountPercentage.value / 100);

  double get effectiveShipping =>
      isFreeShipping.value ? 0.0 : shippingFee.value;

  double get total => subtotal - discountAmount + effectiveShipping;

  int get totalItemsCount =>
      cartItems.fold(0, (acc, item) => acc + item.quantity);

  bool get hasDiscount =>
      appliedPromoCode.value.isNotEmpty && discountAmount > 0;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  @override
  void onClose() {
    promoTextCtrl.dispose();
    super.onClose();
  }

  // ── Dummy data ────────────────────────────────────────────────────────────────
  void _loadDummyData() {
    cartItems.assignAll([
      CartItem(
        id: 'ci_001',
        productId: 'p_101',
        name: 'قميص كلاسيكي بريميوم',
        imageUrl:
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300',
        price: 149.99,
        originalPrice: 199.99,
        quantity: 1,
        variant: 'مقاس: L — لون: أبيض',
        storeName: 'متجر الأناقة',
        storeId: 'store_01',
        maxStock: 10,
      ),
      CartItem(
        id: 'ci_002',
        productId: 'p_102',
        name: 'بنطلون جينز سليم فيت',
        imageUrl:
            'https://images.unsplash.com/photo-1542272604-787c3835535d?w=300',
        price: 249.99,
        quantity: 2,
        variant: 'مقاس: 32×32 — لون: أزرق داكن',
        storeName: 'متجر الأناقة',
        storeId: 'store_01',
        maxStock: 5,
      ),
      CartItem(
        id: 'ci_003',
        productId: 'p_103',
        name: 'حذاء رياضي كلاسيك',
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
        price: 399.99,
        originalPrice: 549.99,
        quantity: 1,
        variant: 'مقاس: 42 — لون: أسود/أبيض',
        storeName: 'ستور الرياضة',
        storeId: 'store_02',
        maxStock: 3,
      ),
    ]);
  }

  // ── Quantity Actions ──────────────────────────────────────────────────────────
  void increaseQuantity(String itemId) {
    final idx = cartItems.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    final item = cartItems[idx];
    if (item.quantity >= item.maxStock) {
      _showMaxStockSnackbar(item.maxStock);
      return;
    }
    cartItems[idx] = item.copyWith(quantity: item.quantity + 1);
    cartItems.refresh();
  }

  void decreaseQuantity(String itemId) {
    final idx = cartItems.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    final item = cartItems[idx];
    if (item.quantity <= 1) {
      removeItem(itemId);
    } else {
      cartItems[idx] = item.copyWith(quantity: item.quantity - 1);
      cartItems.refresh();
    }
  }

  void removeItem(String itemId) {
    cartItems.removeWhere((i) => i.id == itemId);
    // إعادة حساب الخصم بعد الحذف
    _recalcDiscount();
  }

  void clearCart() {
    cartItems.clear();
    removePromoCode();
  }

  // ── Promo Code ────────────────────────────────────────────────────────────────
  Future<void> applyPromoCode() async {
    final code = promoTextCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      promoError.value = 'promo_code_empty'.tr;
      return;
    }

    promoError.value = '';
    isApplyingPromo.value = true;

    // محاكاة طلب API
    await Future.delayed(const Duration(milliseconds: 900));

    if (_validCodes.containsKey(code)) {
      appliedPromoCode.value = code;
      discountPercentage.value = _validCodes[code]!;
      _recalcDiscount();
      isApplyingPromo.value = false;

      Get.snackbar(
        'success'.tr,
        '${'promo_applied_msg'.tr} ${discountPercentage.value.toInt()}%',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.white,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.local_offer_rounded, color: Colors.white),
        isDismissible: true,
      );
    } else {
      promoError.value = 'promo_code_invalid'.tr;
      isApplyingPromo.value = false;
    }
  }

  void removePromoCode() {
    appliedPromoCode.value = '';
    discountPercentage.value = 0.0;
    promoError.value = '';
    promoTextCtrl.clear();
  }

  void _recalcDiscount() {
    // إعادة الحساب عند تغيير الكميات
    if (appliedPromoCode.value.isEmpty) return;
    // discountAmount getter يعيد الحساب تلقائياً عبر computed getter
    cartItems.refresh(); // trigger UI rebuild
  }

  // ── Navigation ────────────────────────────────────────────────────────────────
  void proceedToCheckout() {
    // TODO: Get.toNamed(AppRoutes.buyerCheckout);
    Get.snackbar(
      'checkout_soon'.tr,
      'checkout_wip'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 14,
    );
  }

  void startShopping() {
    // TODO: Navigate to explore tab
    Get.back();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _showMaxStockSnackbar(int max) {
    Get.snackbar(
      'notice'.tr,
      '${'max_stock_msg'.tr} $max',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }

  String formatPrice(double price) =>
      '${price.toStringAsFixed(2)} ${'currency'.tr}';
}
