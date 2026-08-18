import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/buyer/cart/cart_empty_state.dart';
import 'package:e_commerce/view/widget/buyer/cart/cart_address_section.dart';
import 'package:e_commerce/view/widget/buyer/cart/cart_store_card.dart';
import 'package:e_commerce/view/widget/buyer/cart/cart_summary_section.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    return Scaffold(
      backgroundColor: AppColor.backgroundScaffold,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value && controller.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }

        if (controller.isEmpty) {
          return const CartEmptyState();
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColor.primaryColor,
                onRefresh: controller.refreshAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    const CartAddressSection(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        'cart_stores_section'.tr,
                        style: AppTextStyle.heading2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.storeGroups
                        .map((g) => CartStoreCard(group: g)),
                  ],
                ),
              ),
            ),
            const CartSummarySection(),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(CartController controller) {
    return AppBar(
      backgroundColor: AppColor.cardBackground,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('cart_title'.tr, style: AppTextStyle.heading2),
            if (!controller.isEmpty)
              Text(
                '${controller.totalItemsCount} ${'items_in_cart'.tr}',
                style: AppTextStyle.labelSmall,
              ),
          ],
        ),
      ),
      actions: [
        Obx(
          () => controller.isEmpty
              ? const SizedBox(width: 48)
              : IconButton(
                  onPressed: () => _confirmClear(controller),
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: AppColor.error),
                ),
        ),
      ],
    );
  }

  void _confirmClear(CartController c) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('clear_cart'.tr, style: AppTextStyle.heading3),
        content: Text('clear_cart_confirm'.tr, style: AppTextStyle.bodyMedium),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              c.clearCart();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.error),
            child: Text('clear_confirm'.tr, style: AppTextStyle.buttonMedium),
          ),
        ],
      ),
    );
  }
}
