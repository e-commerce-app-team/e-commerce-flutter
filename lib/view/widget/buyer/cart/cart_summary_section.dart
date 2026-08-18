import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class CartSummarySection extends GetView<CartController> {
  const CartSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isEmpty) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppColor.bottomNavShadow,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Line(
                  label: 'subtotal'.tr,
                  value: controller.formatPrice(controller.grandSubtotal),
                ),
                if (controller.totalDiscount > 0) ...[
                  const SizedBox(height: 8),
                  _Line(
                    label: 'discount'.tr,
                    value: '- ${controller.formatPrice(controller.totalDiscount)}',
                    valueColor: AppColor.success,
                  ),
                ],
                const SizedBox(height: 8),
                _Line(
                  label: 'shipping_fee'.tr,
                  value: controller.totalShipping <= 0
                      ? 'free'.tr
                      : controller.formatPrice(controller.totalShipping),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _Line(
                  label: 'grand_total'.tr,
                  value: controller.formatPrice(controller.grandTotal),
                  bold: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColor.mainGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppColor.primaryShadow,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: controller.isCheckingOut.value
                          ? null
                          : controller.proceedToCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: controller.isCheckingOut.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.white,
                              ),
                            )
                          : const Icon(Icons.lock_rounded, color: AppColor.white),
                      label: Text(
                        'pay_now'.tr,
                        style: AppTextStyle.buttonLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _Line({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold ? AppTextStyle.labelLarge : AppTextStyle.bodyMedium,
        ),
        Text(
          value,
          style: (bold ? AppTextStyle.priceLarge : AppTextStyle.price)
              .copyWith(color: valueColor),
        ),
      ],
    );
  }
}
