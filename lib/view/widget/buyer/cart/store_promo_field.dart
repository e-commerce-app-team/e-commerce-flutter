import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class StorePromoField extends GetView<CartController> {
  final String sellerId;

  const StorePromoField({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final applied = controller.appliedCoupons[sellerId];
      if (applied != null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColor.successLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.success.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColor.success, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applied.code, style: AppTextStyle.labelLarge),
                    Text(
                      '- ${controller.formatPrice(applied.discountAmount)}',
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColor.success,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => controller.removePromoCode(sellerId),
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColor.grey,
              ),
            ],
          ),
        );
      }

      final error = controller.promoErrors[sellerId] ?? '';
      final loading = controller.isApplyingPromo[sellerId] == true;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.promoControllerFor(sellerId),
                  textCapitalization: TextCapitalization.characters,
                  style: AppTextStyle.inputText,
                  decoration: InputDecoration(
                    hintText: 'promo_code_hint'.tr,
                    hintStyle: AppTextStyle.inputHint,
                    prefixIcon: Icon(Icons.local_offer_outlined,
                        color: AppColor.primaryColor, size: 20),
                    filled: true,
                    fillColor: AppColor.cardBackground,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColor.greyBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColor.greyBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () => controller.applyPromoCode(sellerId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.white,
                          ),
                        )
                      : Text('apply'.tr, style: AppTextStyle.buttonMedium),
                ),
              ),
            ],
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 4, left: 4),
              child: Text(
                error,
                style: AppTextStyle.inputError,
              ),
            ),
        ],
      );
    });
  }
}
