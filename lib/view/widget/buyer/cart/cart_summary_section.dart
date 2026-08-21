import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

/// A deliberately compact action bar. Price breakdown lives in a bottom sheet
/// so the cart stays focused on the products and delivery choices.
class CartSummarySection extends GetView<CartController> {
  const CartSummarySection({super.key});

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SummaryDetails(isArabic: _isArabic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isEmpty) return const SizedBox.shrink();
      final pending = controller.hasPendingShipping;

      return Container(
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: AppColor.bottomNavShadow,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.greyBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showDetails(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColor.primarySurface,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  color: AppColor.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pending
                                          ? (_isArabic
                                                ? 'الإجمالي يحدد لاحقًا'
                                                : 'Final total pending')
                                          : 'grand_total'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.labelSmall,
                                    ),
                                    Text(
                                      pending
                                          ? controller.formatPrice(
                                              controller.grandSubtotal -
                                                  controller.totalDiscount,
                                            )
                                          : controller.formatPrice(
                                              controller.grandTotal,
                                            ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.price.copyWith(
                                        fontSize: 16,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: AppColor.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColor.mainGradient,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: AppColor.primaryShadow,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: controller.isCheckingOut.value
                              ? null
                              : controller.proceedToCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
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
                              : Icon(
                                  pending
                                      ? Icons.send_rounded
                                      : Icons.lock_rounded,
                                  color: AppColor.white,
                                ),
                          label: Text(
                            pending
                                ? (_isArabic ? 'إرسال الطلب' : 'Send request')
                                : 'pay_now'.tr,
                            style: AppTextStyle.buttonMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _SummaryDetails extends GetView<CartController> {
  final bool isArabic;

  const _SummaryDetails({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.greyBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isArabic ? 'ملخص الطلب' : 'Order summary',
                style: AppTextStyle.heading3,
              ),
              const SizedBox(height: 16),
              _SummaryLine(
                'subtotal'.tr,
                controller.formatPrice(controller.grandSubtotal),
              ),
              if (controller.totalDiscount > 0) ...[
                const SizedBox(height: 10),
                _SummaryLine(
                  'discount'.tr,
                  '- ${controller.formatPrice(controller.totalDiscount)}',
                  color: AppColor.success,
                ),
              ],
              const SizedBox(height: 10),
              _SummaryLine(
                isArabic ? 'الشحن' : 'Shipping',
                controller.hasPendingShipping
                    ? (isArabic
                          ? 'يحدد بعد قبول الطلب'
                          : 'Set after acceptance')
                    : controller.totalShipping <= 0
                    ? 'free'.tr
                    : controller.formatPrice(controller.totalShipping),
              ),
              if (controller.hasPendingShipping) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColor.info,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'سيتم تأكيد تكلفة الشحن قبل الدفع.'
                            : 'Shipping cost will be confirmed before payment.',
                        style: AppTextStyle.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(height: 1),
              ),
              _SummaryLine(
                'grand_total'.tr,
                controller.hasPendingShipping
                    ? (isArabic
                          ? 'بانتظار تكلفة الشحن'
                          : 'Pending shipping cost')
                    : controller.formatPrice(controller.grandTotal),
                bold: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'رصيد المحفظة المتاح'
                            : 'Available wallet balance',
                        style: AppTextStyle.bodySmall,
                      ),
                    ),
                    Text(
                      controller.formatPrice(controller.walletBalance.value),
                      style: AppTextStyle.price,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool bold;

  const _SummaryLine(this.label, this.value, {this.color, this.bold = false});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: bold ? AppTextStyle.labelLarge : AppTextStyle.bodyMedium,
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
          style: (bold ? AppTextStyle.price : AppTextStyle.labelLarge).copyWith(
            color: color ?? (bold ? AppColor.primaryColor : null),
          ),
        ),
      ),
    ],
  );
}
