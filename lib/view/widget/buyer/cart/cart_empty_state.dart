import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class CartEmptyState extends GetView<CartController> {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined,
                  size: 52, color: AppColor.primaryColor),
            ),
            const SizedBox(height: 24),
            Text('empty_cart_title'.tr, style: AppTextStyle.displaySmall),
            const SizedBox(height: 10),
            Text(
              'empty_cart_subtitle'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.startShopping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.storefront_rounded, color: AppColor.white),
                label: Text('start_shopping'.tr, style: AppTextStyle.buttonLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
