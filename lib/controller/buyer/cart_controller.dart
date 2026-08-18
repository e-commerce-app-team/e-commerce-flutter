import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/controller/buyer/buyer_main_controller.dart';
import 'package:e_commerce/core/functions/format_price.dart' as price_fmt;
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/buyer/cart_datasource.dart';
import 'package:e_commerce/data/models/buyer/cart_models.dart';
import 'package:e_commerce/view/screen/buyer/cart/checkout/sham_cash_payment_screen.dart';
import 'package:e_commerce/view/screen/buyer/cart/checkout/order_success_screen.dart';

class CartController extends GetxController {
  final BuyerCartDataSource _cartData = BuyerCartDataSource(Get.find<Crud>());
  final BuyerAddressDataSource _addressData =
      BuyerAddressDataSource(Get.find<Crud>());
  final MyServices _services = Get.find<MyServices>();

  // ── State ───────────────────────────────────────────────────────────────────
  final RxList<StoreCartGroup> storeGroups = <StoreCartGroup>[].obs;
  final RxList<BuyerAddress> addresses = <BuyerAddress>[].obs;
  final Rxn<BuyerAddress> selectedAddress = Rxn<BuyerAddress>();
  final RxString driverNotes = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxBool isAddingToCart = false.obs;
  final RxDouble walletBalance = 0.0.obs;

  /// Per-store selected shipping option id
  final RxMap<String, String> selectedShipping = <String, String>{}.obs;

  /// Per-store applied coupon
  final RxMap<String, AppliedStoreCoupon> appliedCoupons =
      <String, AppliedStoreCoupon>{}.obs;

  /// Per-store promo field controllers & errors
  final Map<String, TextEditingController> promoControllers = {};
  final RxMap<String, String> promoErrors = <String, String>{}.obs;
  final RxMap<String, bool> isApplyingPromo = <String, bool>{}.obs;

  final TextEditingController driverNotesCtrl = TextEditingController();

  String? get _token {
    final t = _services.sharedPreferences.getString('token');
    if (t == null || t.isEmpty) return null;
    return t;
  }

  // ── Computed ────────────────────────────────────────────────────────────────
  int get totalItemsCount =>
      storeGroups.fold(0, (acc, g) => acc + g.itemsCount);

  bool get isEmpty => storeGroups.isEmpty;

  double get grandSubtotal =>
      storeGroups.fold(0.0, (acc, g) => acc + g.subtotal);

  double get totalShipping => storeGroups.fold(0.0, (acc, g) {
        final opt = _selectedShippingOption(g);
        return acc + (opt?.cost ?? 0);
      });

  double get totalDiscount => appliedCoupons.values.fold(
        0.0,
        (acc, c) => acc + c.discountAmount,
      );

  double get grandTotal =>
      (grandSubtotal - totalDiscount + totalShipping).clamp(0, double.infinity);

  bool get hasOutOfStock =>
      storeGroups.any((g) => g.items.any((i) => i.isOutOfStock));

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    driverNotesCtrl.addListener(() => driverNotes.value = driverNotesCtrl.text);
    refreshAll();
    _applySpinWheelCouponIfAny();
  }

  @override
  void onClose() {
    driverNotesCtrl.dispose();
    for (final c in promoControllers.values) {
      c.dispose();
    }
    super.onClose();
  }

  Future<void> refreshAll() async {
    await Future.wait([loadCart(), loadAddresses(), loadWalletBalance()]);
  }

  /// Adds a product to the cart via API, refreshes cart state, and updates the nav badge.
  Future<bool> addToCart(
    String productId, {
    int qty = 1,
    String? variantId,
    int? maxStock,
  }) async {
    if (productId.isEmpty) return false;

    if (maxStock != null && maxStock <= 0) {
      customSnackbar('warning'.tr, 'explore_unavailable_body'.tr);
      return false;
    }

    final token = _token;
    if (token == null) {
      customSnackbar('warning'.tr, 'signin_required_cart'.tr);
      return false;
    }

    isAddingToCart.value = true;
    final result = await _cartData.addToCart(
      token,
      productId: productId,
      qty: qty,
      variantId: variantId,
    );
    isAddingToCart.value = false;

    return result.fold(
      (_) {
        customSnackbar('error'.tr, 'product_add_failed'.tr);
        return false;
      },
      (body) {
        final success = body['success'] != false;
        if (success) {
          customSnackbar('success'.tr, 'product_added_cart'.tr, isError: false);
          loadCart();
        } else {
          customSnackbar(
            'error'.tr,
            body['message']?.toString() ?? 'product_add_failed'.tr,
          );
        }
        return success;
      },
    );
  }

  Future<void> loadCart() async {
    final token = _token;
    if (token == null) {
      storeGroups.clear();
      return;
    }

    isLoading.value = true;
    final result = await _cartData.getCart(token);
    isLoading.value = false;

    result.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (body) {
        if (body['success'] != true && body['message'] != null) {
          customSnackbar('error'.tr, body['message'].toString());
          return;
        }
        final data = body['data'];
        if (data is! Map) return;

        final stores = data['stores'];
        if (stores is! List) return;

        storeGroups.assignAll(
          stores
              .map((e) => StoreCartGroup.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );

        _initStoreSelections();
        _applySpinWheelCouponIfAny();
      },
    );
  }

  Future<void> loadAddresses() async {
    final token = _token;
    if (token == null) return;

    final result = await _addressData.getAddresses(token);
    result.fold((_) {}, (body) {
      final data = body['data'];
      if (data is! List) return;

      addresses.assignAll(
        data.map((e) => BuyerAddress.fromJson(Map<String, dynamic>.from(e))),
      );

      selectedAddress.value = addresses.firstWhereOrNull((a) => a.isDefault) ??
          addresses.firstOrNull;
    });
  }

  Future<void> loadWalletBalance() async {
    final token = _token;
    if (token == null) return;

    final result = await _cartData.getWalletBalance(token);
    result.fold((_) {}, (body) {
      walletBalance.value =
          double.tryParse('${body['balance']}') ?? walletBalance.value;
    });
  }

  void _initStoreSelections() {
    for (final group in storeGroups) {
      promoControllers.putIfAbsent(group.sellerId, TextEditingController.new);

      if (!selectedShipping.containsKey(group.sellerId)) {
        final first = group.shippingOptions.isNotEmpty
            ? group.shippingOptions.first.id
            : 'standard';
        selectedShipping[group.sellerId] = first;
      }

      final coupon = appliedCoupons[group.sellerId];
      if (coupon != null) {
        promoControllers[group.sellerId]?.text = coupon.code;
      }
    }
  }

  void _applySpinWheelCouponIfAny() {
    final pending =
        _services.sharedPreferences.getString('pending_spin_coupon');
    if (pending == null || pending.isEmpty || storeGroups.isEmpty) return;

    final firstStore = storeGroups.first;
    promoControllers[firstStore.sellerId]?.text = pending;
    applyPromoCode(firstStore.sellerId);
    _services.sharedPreferences.remove('pending_spin_coupon');
  }

  ShippingOption? _selectedShippingOption(StoreCartGroup group) {
    final id = selectedShipping[group.sellerId];
    if (id == null) return null;
    return group.shippingOptions.firstWhereOrNull((o) => o.id == id) ??
        group.shippingOptions.firstOrNull;
  }

  double storeDiscount(String sellerId) =>
      appliedCoupons[sellerId]?.discountAmount ?? 0;

  double storeShippingCost(String sellerId) {
    final group = storeGroups.firstWhereOrNull((g) => g.sellerId == sellerId);
    if (group == null) return 0;
    return _selectedShippingOption(group)?.cost ?? 0;
  }

  double storeTotal(String sellerId) {
    final group = storeGroups.firstWhereOrNull((g) => g.sellerId == sellerId);
    if (group == null) return 0;
    return group.subtotal - storeDiscount(sellerId) + storeShippingCost(sellerId);
  }

  void selectShipping(String sellerId, String optionId) {
    selectedShipping[sellerId] = optionId;
    selectedShipping.refresh();
  }

  void selectAddress(BuyerAddress address) {
    selectedAddress.value = address;
    if (address.driverNotes != null && address.driverNotes!.isNotEmpty) {
      driverNotesCtrl.text = address.driverNotes!;
    }
  }

  Future<void> addAddress(BuyerAddress draft) async {
    final token = _token;
    if (token == null) return;

    final result = await _addressData.createAddress(token, draft.toJson());
    result.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (body) {
        if (body['success'] == true) {
          customSnackbar('success'.tr, 'address_saved'.tr, isError: false);
          loadAddresses();
        } else {
          customSnackbar('error'.tr, body['message']?.toString() ?? 'error'.tr);
        }
      },
    );
  }

  Future<void> increaseQuantity(String itemId, String sellerId) async {
    final group = storeGroups.firstWhereOrNull((g) => g.sellerId == sellerId);
    if (group == null) return;

    final item = group.items.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;

    if (item.quantity >= item.maxStock) {
      customSnackbar('notice'.tr, '${'max_stock_msg'.tr} ${item.maxStock}');
      return;
    }

    await _updateQtyRemote(itemId, item.quantity + 1);
  }

  Future<void> decreaseQuantity(String itemId, String sellerId) async {
    final group = storeGroups.firstWhereOrNull((g) => g.sellerId == sellerId);
    if (group == null) return;
    final item = group.items.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;

    if (item.quantity <= 1) {
      await removeItem(itemId);
    } else {
      await _updateQtyRemote(itemId, item.quantity - 1);
    }
  }

  Future<void> _updateQtyRemote(String itemId, int qty) async {
    final token = _token;
    if (token == null) return;

    final result = await _cartData.updateQty(token, itemId, qty);
    result.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (body) {
        if (body['success'] != true) {
          customSnackbar('error'.tr, body['message']?.toString() ?? 'error'.tr);
          return;
        }
        loadCart();
      },
    );
  }

  Future<void> removeItem(String itemId) async {
    final token = _token;
    if (token == null) return;

    final result = await _cartData.removeItem(token, itemId);
    result.fold(
      (_) => customSnackbar('error'.tr, 'server_error'.tr),
      (body) {
        if (body['success'] == true) {
          loadCart();
        }
      },
    );
  }

  Future<void> clearCart() async {
    final token = _token;
    if (token == null) return;

    final result = await _cartData.clearCart(token);
    result.fold((_) {}, (_) {
      storeGroups.clear();
      appliedCoupons.clear();
      selectedShipping.clear();
    });
  }

  Future<void> applyPromoCode(String sellerId) async {
    final token = _token;
    if (token == null) return;

    final code = promoControllers[sellerId]?.text.trim().toUpperCase() ?? '';
    if (code.isEmpty) {
      promoErrors[sellerId] = 'promo_code_empty'.tr;
      promoErrors.refresh();
      return;
    }

    final group = storeGroups.firstWhereOrNull((g) => g.sellerId == sellerId);
    if (group == null) return;

    promoErrors[sellerId] = '';
    isApplyingPromo[sellerId] = true;
    isApplyingPromo.refresh();

    final productIds = group.items.map((i) => i.productId).toList();
    final result = await _cartData.validateCoupon(
      token,
      code: code,
      sellerId: sellerId,
      orderTotal: group.subtotal,
      productIds: productIds,
    );

    isApplyingPromo[sellerId] = false;
    isApplyingPromo.refresh();

    result.fold(
      (_) {
        promoErrors[sellerId] = 'promo_code_invalid'.tr;
        promoErrors.refresh();
      },
      (body) {
        if (body['success'] != true) {
          promoErrors[sellerId] =
              body['message']?.toString() ?? 'promo_code_invalid'.tr;
          promoErrors.refresh();
          return;
        }

        final coupon = body['coupon'];
        final discount = double.tryParse('${body['discount_amount']}') ?? 0;
        appliedCoupons[sellerId] = AppliedStoreCoupon(
          code: code,
          type: coupon is Map ? '${coupon['type']}' : 'percentage',
          discountAmount: discount,
        );
        appliedCoupons.refresh();

        if (coupon is Map && coupon['type'] == 'free_shipping') {
          final pickup = group.shippingOptions
              .firstWhereOrNull((o) => o.id == 'pickup' || o.cost == 0);
          if (pickup != null) selectShipping(sellerId, pickup.id);
        }

        customSnackbar('success'.tr, 'promo_applied_success'.tr, isError: false);
      },
    );
  }

  void removePromoCode(String sellerId) {
    appliedCoupons.remove(sellerId);
    appliedCoupons.refresh();
    promoControllers[sellerId]?.clear();
    promoErrors[sellerId] = '';
    promoErrors.refresh();
  }

  TextEditingController promoControllerFor(String sellerId) =>
      promoControllers.putIfAbsent(sellerId, TextEditingController.new);

  Future<void> proceedToCheckout() async {
    if (isEmpty) return;

    if (_token == null) {
      customSnackbar('notice'.tr, 'login_required'.tr);
      return;
    }

    if (hasOutOfStock) {
      customSnackbar('notice'.tr, 'cart_out_of_stock_warning'.tr);
      return;
    }

    if (selectedAddress.value == null) {
      customSnackbar('notice'.tr, 'select_delivery_address'.tr);
      return;
    }

    isCheckingOut.value = true;

    final storesPayload = storeGroups.map((g) {
      return {
        'seller_id': int.tryParse(g.sellerId) ?? g.sellerId,
        'shipping_option_id': selectedShipping[g.sellerId] ?? 'standard',
        if (appliedCoupons[g.sellerId] != null)
          'coupon_code': appliedCoupons[g.sellerId]!.code,
      };
    }).toList();

    final result = await _cartData.checkout(
      _token!,
      {
        'address_id': int.tryParse(selectedAddress.value!.id) ??
            selectedAddress.value!.id,
        'driver_notes': driverNotesCtrl.text.trim(),
        'stores': storesPayload,
      },
    );

    isCheckingOut.value = false;

    await result.fold(
      (_) async {
        customSnackbar('error'.tr, 'server_error'.tr);
      },
      (body) async {
        if (body['success'] != true) {
          customSnackbar('error'.tr, body['message']?.toString() ?? 'error'.tr);
          return;
        }

        final checkout = CheckoutResult.fromJson(Map<String, dynamic>.from(body));
        await loadWalletBalance();

        final paid = await Get.to<bool>(() => ShamCashPaymentScreen(
              orderId: checkout.orderId,
              orderNumber: checkout.orderNumber,
              totalAmount: checkout.totalPrice,
              walletBalance: walletBalance.value,
            ));

        if (paid == true) {
          await Get.off(() => OrderSuccessScreen(
                orderNumber: checkout.orderNumber,
                totalAmount: checkout.totalPrice,
              ));
          await loadCart();
        }
      },
    );
  }

  void startShopping() {
    if (Get.isRegistered<BuyerMainController>()) {
      Get.find<BuyerMainController>().changeTab(1);
    } else {
      Get.back();
    }
  }

  String formatPrice(double price) =>
      '${price_fmt.formatPrice(price)} ${'currency'.tr}';
}
