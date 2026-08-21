import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/models/buyer/cart_models.dart';
import 'package:e_commerce/view/widget/buyer/cart/cart_item_row.dart';
import 'package:e_commerce/view/widget/buyer/cart/store_promo_field.dart';
import 'package:e_commerce/view/widget/buyer/cart/store_shipping_options.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_network_image.dart';

class CartStoreCard extends GetView<CartController> {
  final StoreCartGroup group;

  const CartStoreCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColor.cardShadow,
        border: Border.all(color: AppColor.greyBorder.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StoreHeader(group: group),
          const Divider(height: 1, thickness: 0.6),
          ...group.items.map(
            (item) => CartItemRow(
              item: item,
              sellerId: group.sellerId,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: StorePromoField(sellerId: group.sellerId),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: StoreShippingOptions(group: group),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Obx(() {
              final subtotal = group.subtotal;
              final discount = controller.storeDiscount(group.sellerId);
              final shipping = controller.storeShippingCost(group.sellerId);
              final total = controller.storeTotal(group.sellerId);
              final shippingPending = controller.storeShippingPending(group.sellerId);

              return Column(
                children: [
                  _TotalLine(
                    label: 'store_subtotal'.tr,
                    value: controller.formatPrice(subtotal),
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 6),
                    _TotalLine(
                      label: 'discount'.tr,
                      value: '- ${controller.formatPrice(discount)}',
                      valueColor: AppColor.success,
                    ),
                  ],
                  if (shippingPending) ...[
                    const SizedBox(height: 6),
                    _TotalLine(label: 'shipping_fee'.tr, value: 'يحدد بعد قبول الطلب'),
                  ] else if (shipping > 0) ...[
                    const SizedBox(height: 6),
                    _TotalLine(
                      label: 'shipping_fee'.tr,
                      value: controller.formatPrice(shipping),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _TotalLine(
                    label: 'store_total'.tr,
                    value: shippingPending ? 'بانتظار الشحن' : controller.formatPrice(total),
                    bold: true,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final StoreCartGroup group;
  const _StoreHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 46,
              height: 46,
              child: group.storeLogo != null && group.storeLogo!.isNotEmpty
                  ? BuyerNetworkImage(
                      url: group.storeLogo!,
                      fallbackIcon: Icons.storefront_rounded,
                      fallbackIconSize: 22,
                    )
                  : Container(
                      color: AppColor.primarySurface,
                      child: Icon(Icons.storefront_rounded,
                          color: AppColor.primaryColor),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.storeName, style: AppTextStyle.heading3),
                const SizedBox(height: 2),
                Text(
                  '${group.itemsCount} ${'items_in_cart'.tr}',
                  style: AppTextStyle.labelSmall,
                ),
              ],
            ),
          ),
          if (group.hasFreeShipping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'free_shipping'.tr,
                style: AppTextStyle.chip.copyWith(color: AppColor.success),
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _TotalLine({
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
          style: bold ? AppTextStyle.labelLarge : AppTextStyle.bodySmall,
        ),
        Text(
          value,
          style: (bold ? AppTextStyle.price : AppTextStyle.labelLarge)
              .copyWith(color: valueColor ?? (bold ? AppColor.primaryColor : null)),
        ),
      ],
    );
  }
}
