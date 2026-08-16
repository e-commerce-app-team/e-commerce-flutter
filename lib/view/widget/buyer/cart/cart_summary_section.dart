// ─────────────────────────────────────────────────────────────────────────────
// lib/view/widget/buyer/cart/cart_summary_section.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/buyer/cart_controller.dart';
import '../../../../core/constant/color.dart';
import 'promo_code_field.dart';

class CartSummarySection extends GetView<CartController> {
  const CartSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.10),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ───────────────────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColor.greyText.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Promo code field ──────────────────────────────────────────
              const PromoCodeField(),

              const SizedBox(height: 18),

              // ── Divider ───────────────────────────────────────────────────
              Divider(
                height: 1,
                thickness: 0.8,
                color: AppColor.greyText.withOpacity(0.12),
              ),

              const SizedBox(height: 16),

              // ── Bill details ──────────────────────────────────────────────
              Obx(() => Column(
                    children: [
                      _SummaryRow(
                        label: 'subtotal'.tr,
                        value: controller
                            .formatPrice(controller.subtotal),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'shipping_fee'.tr,
                        value: controller.effectiveShipping == 0
                            ? 'free'.tr
                            : controller.formatPrice(
                                controller.effectiveShipping),
                        valueColor: controller.effectiveShipping == 0
                            ? AppColor.primaryColor
                            : null,
                      ),
                      if (controller.hasDiscount) ...[
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label:
                              '${'discount'.tr} (${controller.discountPercentage.value.toInt()}%)',
                          value:
                              '- ${controller.formatPrice(controller.discountAmount)}',
                          valueColor: AppColor.danger,
                          labelColor: AppColor.danger,
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Dashed separator
                      _DashedDivider(),

                      const SizedBox(height: 12),

                      // Total row
                      _SummaryRow(
                        label: 'total'.tr,
                        value: controller.formatPrice(controller.total),
                        isBold: true,
                        fontSize: 17,
                      ),
                    ],
                  )),

              const SizedBox(height: 18),

              // ── Checkout button ───────────────────────────────────────────
              _CheckoutButton(onTap: controller.proceedToCheckout),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary row ────────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final bool isBold;
  final double fontSize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.isBold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textStyle.copyWith(
            color: labelColor ??
                (isBold ? null : AppColor.greyText),
          ),
        ),
        Text(
          value,
          style: textStyle.copyWith(
            color: valueColor ??
                (isBold ? AppColor.primaryColor : null),
          ),
        ),
      ],
    );
  }
}

// ── Dashed divider ─────────────────────────────────────────────────────────────
class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final count = (width / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dashWidth,
              height: 1,
              color: AppColor.greyText.withOpacity(0.25),
              margin: const EdgeInsets.only(left: dashSpace),
            ),
          ),
        );
      },
    );
  }
}

// ── Checkout button ────────────────────────────────────────────────────────────
class _CheckoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CheckoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primaryColor,
              AppColor.primaryColor.withOpacity(0.78),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.40),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: Icon(
            Icons.lock_rounded,
            size: 20,
            color: AppColor.white,
          ),
          label: Text(
            'proceed_checkout'.tr,
            style: TextStyle(
              color: AppColor.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
