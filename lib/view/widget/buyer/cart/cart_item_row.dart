import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/models/buyer/cart_models.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_network_image.dart';

class CartItemRow extends StatelessWidget {
  final CartItem item;
  final String sellerId;

  const CartItemRow({
    super.key,
    required this.item,
    required this.sellerId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('remove_item'.tr, style: AppTextStyle.heading3),
            content: Text('remove_item_confirm'.tr, style: AppTextStyle.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('remove'.tr,
                    style: const TextStyle(color: AppColor.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => controller.removeItem(item.id),
      background: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColor.errorLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline_rounded, color: AppColor.error),
            Text('delete'.tr,
                style: AppTextStyle.chip.copyWith(color: AppColor.error)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.secondBackground,
          borderRadius: BorderRadius.circular(16),
          border: item.isOutOfStock
              ? Border.all(color: AppColor.error.withOpacity(0.35))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.isOutOfStock)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 16, color: AppColor.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'item_out_of_stock'.tr,
                        style: AppTextStyle.chip.copyWith(color: AppColor.error),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: BuyerNetworkImage(url: item.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.labelLarge,
                      ),
                      if (item.variant != null) ...[
                        const SizedBox(height: 4),
                        Text(item.variant!, style: AppTextStyle.labelSmall),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.formatPrice(item.price),
                                  style: AppTextStyle.price,
                                ),
                                if (item.originalPrice != null)
                                  Text(
                                    controller.formatPrice(item.originalPrice!),
                                    style: AppTextStyle.labelSmall.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _QtyStepper(
                            item: item,
                            sellerId: sellerId,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final CartItem item;
  final String sellerId;

  const _QtyStepper({required this.item, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final atMax = item.quantity >= item.maxStock;
    final atMin = item.quantity <= 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.greyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: atMin ? Icons.delete_outline_rounded : Icons.remove_rounded,
            color: atMin ? AppColor.error : AppColor.primaryColor,
            onTap: () => controller.decreaseQuantity(item.id, sellerId),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: AppTextStyle.labelLarge,
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            color: atMax ? AppColor.greyLight : AppColor.primaryColor,
            onTap: atMax
                ? null
                : () => controller.increaseQuantity(item.id, sellerId),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _Btn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
