// ─────────────────────────────────────────────────────────────────────────────
// lib/view/widget/buyer/cart/promo_code_field.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/buyer/cart_controller.dart';
import '../../../../core/constant/color.dart';

class PromoCodeField extends GetView<CartController> {
  const PromoCodeField({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── Applied state — show chip + remove button ────────────────────────────
      if (controller.appliedPromoCode.value.isNotEmpty) {
        return _AppliedPromoChip(
          code: controller.appliedPromoCode.value,
          discountPct: controller.discountPercentage.value,
          onRemove: controller.removePromoCode,
        );
      }

      // ── Input state — show text field + apply button ─────────────────────────
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Text field
              Expanded(
                child: _PromoTextField(controller: controller),
              ),
              const SizedBox(width: 10),
              // Apply button
              Obx(() => _ApplyButton(
                    isLoading: controller.isApplyingPromo.value,
                    onTap: controller.applyPromoCode,
                  )),
            ],
          ),
          // Error message
          Obx(() {
            if (controller.promoError.value.isEmpty) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 6, right: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 14, color: AppColor.danger),
                  const SizedBox(width: 4),
                  Text(
                    controller.promoError.value,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColor.danger,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}

// ── Text field ─────────────────────────────────────────────────────────────────
class _PromoTextField extends StatelessWidget {
  final CartController controller;
  const _PromoTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller.promoTextCtrl,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => controller.applyPromoCode(),
        style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2),
        decoration: InputDecoration(
          hintText: 'promo_code_hint'.tr,
          hintStyle:
              TextStyle(color: AppColor.greyText, fontWeight: FontWeight.normal),
          prefixIcon: Icon(Icons.local_offer_rounded,
              size: 20, color: AppColor.primaryColor),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          filled: true,
          fillColor: AppColor.backgroundcolor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: AppColor.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Apply button ───────────────────────────────────────────────────────────────
class _ApplyButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _ApplyButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.white,
                ),
              )
            : Text(
                'apply'.tr,
                style: TextStyle(
                  color: AppColor.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

// ── Applied promo chip ─────────────────────────────────────────────────────────
class _AppliedPromoChip extends StatelessWidget {
  final String code;
  final double discountPct;
  final VoidCallback onRemove;

  const _AppliedPromoChip({
    required this.code,
    required this.discountPct,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColor.primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${'discount_applied'.tr} ${discountPct.toInt()}%',
                  style: TextStyle(
                    color: AppColor.primaryColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColor.greyText.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  size: 16, color: AppColor.greyText),
            ),
          ),
        ],
      ),
    );
  }
}
