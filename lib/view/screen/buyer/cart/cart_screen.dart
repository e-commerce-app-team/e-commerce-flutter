// ─────────────────────────────────────────────────────────────────────────────
// lib/view/screen/buyer/cart/cart_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/buyer/cart_controller.dart';
import '../../../../core/constant/color.dart';
import '../../../widget/buyer/cart/cart_empty_state.dart';
import '../../../widget/buyer/cart/cart_item_card.dart';
import '../../../widget/buyer/cart/cart_summary_section.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller — GetX handles singleton automatically
    // if already registered (e.g. from BottomNav), Find won't re-create it
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      appBar: _buildAppBar(context, controller),
      body: Obx(() {
        // ── Empty state ────────────────────────────────────────────────────────
        if (controller.cartItems.isEmpty) {
          return const CartEmptyState();
        }

        // ── Cart content ───────────────────────────────────────────────────────
        return Column(
          children: [
            // Scrollable items list
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return CartItemCard(
                    key: ValueKey(item.id),
                    item: item,
                    controller: controller,
                  );
                },
              ),
            ),

            // Sticky summary at bottom
            const CartSummarySection(),
          ],
        );
      }),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, CartController controller) {
    return AppBar(
      backgroundColor: AppColor.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,

      // Title + item count
      title: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'cart_title'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 280),
              crossFadeState: controller.cartItems.isEmpty
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: const SizedBox(height: 2),
              secondChild: Text(
                '${controller.totalItemsCount} ${'items_in_cart'.tr}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColor.greyText,
                    ),
              ),
            ),
          ],
        ),
      ),

      // Thin bottom border
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 0.6,
          color: AppColor.greyText.withOpacity(0.15),
        ),
      ),

      // Clear cart action
      actions: [
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: controller.cartItems.isEmpty
                ? const SizedBox(key: ValueKey('empty'), width: 48)
                : IconButton(
                    key: const ValueKey('deleteBtn'),
                    onPressed: () => _confirmClearCart(controller),
                    tooltip: 'clear_cart'.tr,
                    icon: Icon(
                      Icons.delete_sweep_outlined,
                      color: AppColor.danger,
                      size: 26,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Confirm clear cart dialog ───────────────────────────────────────────────
  void _confirmClearCart(CartController c) {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColor.danger, size: 26),
            const SizedBox(width: 10),
            Text(
              'clear_cart'.tr,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'clear_cart_confirm'.tr,
          style: TextStyle(color: AppColor.greyText, height: 1.55),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr,
                style: TextStyle(
                    color: AppColor.greyText, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              c.clearCart();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'clear_confirm'.tr,
              style: TextStyle(
                  color: AppColor.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
