import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/format_price.dart';
import 'package:e_commerce/controller/buyer/buyer_main_controller.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final double totalAmount;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColor.successLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.success.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColor.success, size: 58),
              ),
              const SizedBox(height: 28),
              Text('order_success_title'.tr, style: AppTextStyle.displaySmall),
              const SizedBox(height: 10),
              Text(
                'order_success_sub'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium,
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColor.cardShadow,
                ),
                child: Column(
                  children: [
                    _Row(label: 'order_number'.tr, value: orderNumber),
                    const Divider(height: 24),
                    _Row(
                      label: 'total'.tr,
                      value: '${formatPrice(totalAmount)} ${'currency'.tr}',
                      bold: true,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (Get.isRegistered<BuyerMainController>()) {
                      Get.find<BuyerMainController>().changeTab(3);
                    }
                    Get.until((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text('track_order'.tr, style: AppTextStyle.buttonLarge),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.until((route) => route.isFirst),
                child: Text('continue_shopping'.tr,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: AppColor.primaryColor,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Row({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.bodyMedium),
        Text(
          value,
          style: bold ? AppTextStyle.priceLarge : AppTextStyle.price,
        ),
      ],
    );
  }
}
