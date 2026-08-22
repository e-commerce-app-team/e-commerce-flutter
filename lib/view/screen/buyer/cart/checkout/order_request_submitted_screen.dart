import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/buyer_main_controller.dart';
import 'package:e_commerce/controller/buyer/buyer_orders_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';

class OrderRequestSubmittedScreen extends StatelessWidget {
  final String orderNumber;
  final double provisionalTotal;
  final bool shippingPending;

  const OrderRequestSubmittedScreen({
    super.key,
    required this.orderNumber,
    required this.provisionalTotal,
    required this.shippingPending,
  });

  Future<void> _goToBuyerTab(int index) async {
    final controller = Get.isRegistered<BuyerMainController>()
        ? Get.find<BuyerMainController>()
        : null;
    if (controller == null) {
      Get.offAllNamed(AppRoute.buyerMain);
      return;
    }

    Get.until((route) => route.isFirst);
    controller.changeTab(index);
    if (index == 3 && Get.isRegistered<BuyerOrdersController>()) {
      await Get.find<BuyerOrdersController>().reloadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final waitingText = shippingPending
        ? (isArabic
              ? 'سيحدد التاجر تكلفة الشحن وموعد التسليم، ثم سيظهر لك المبلغ النهائي للدفع.'
              : 'The seller will set the shipping cost and delivery time, then the final amount will be ready for payment.')
        : (isArabic
              ? 'طلبك بانتظار معالجة التاجر قبل تأكيد الدفع.'
              : 'Your order is waiting for seller processing before payment confirmation.');

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
                  color: AppColor.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: AppColor.primaryColor,
                  size: 54,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                isArabic ? 'تم إرسال طلبك' : 'Order request submitted',
                style: AppTextStyle.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                waitingText,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium,
              ),
              const SizedBox(height: 26),
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
                    _InfoRow(
                      label: isArabic ? 'رقم الطلب' : 'Order number',
                      value: orderNumber,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      label: isArabic ? 'الحالة' : 'Status',
                      value: isArabic
                          ? 'بانتظار تكلفة الشحن'
                          : 'Awaiting shipping quote',
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _goToBuyerTab(3),
                  icon: const Icon(Icons.receipt_long_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  label: Text(
                    isArabic ? 'متابعة الطلب' : 'Track order',
                    style: AppTextStyle.buttonLarge,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _goToBuyerTab(1),
                child: Text(isArabic ? 'متابعة التسوق' : 'Continue shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(child: Text(label, style: AppTextStyle.bodyMedium)),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: AppTextStyle.labelLarge,
        ),
      ),
    ],
  );
}
