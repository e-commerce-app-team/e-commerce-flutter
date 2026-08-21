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

  const CartItemRow({super.key, required this.item, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final isArabic = Get.locale?.languageCode == 'ar';

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmRemove(),
      onDismissed: (_) => controller.removeItem(item.id),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: AppColor.errorLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColor.error),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.secondBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isOutOfStock
                ? AppColor.error.withValues(alpha: .45)
                : AppColor.greyBorder.withValues(alpha: .55),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.isOutOfStock) _StockWarning(isArabic: isArabic),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(item: item),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.labelLarge,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 36,
                            child: IconButton(
                              tooltip: 'remove'.tr,
                              onPressed: () => controller.removeItem(item.id),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColor.error,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.variant != null &&
                          item.variant!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            item.variant!,
                            style: AppTextStyle.labelSmall,
                          ),
                        ),
                      const SizedBox(height: 7),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: _PriceBlock(item: item)),
                          _QtyStepper(item: item, sellerId: sellerId),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColor.cardBackground.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: AppColor.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isArabic ? 'إجمالي المنتج' : 'Product total',
                    style: AppTextStyle.labelSmall,
                  ),
                  const Spacer(),
                  Text(
                    controller.formatPrice(item.lineTotal),
                    style: AppTextStyle.price.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmRemove() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('remove_item'.tr, style: AppTextStyle.heading3),
            content: Text(
              'remove_item_confirm'.tr,
              style: AppTextStyle.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(
                  'remove'.tr,
                  style: const TextStyle(color: AppColor.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _ProductImage extends StatelessWidget {
  final CartItem item;
  const _ProductImage({required this.item});

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 82,
          height: 82,
          child: BuyerNetworkImage(url: item.imageUrl),
        ),
      ),
      if (item.discountPercent != null)
        PositionedDirectional(
          top: -5,
          start: -5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColor.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '-${item.discountPercent!.toInt()}%',
              style: AppTextStyle.badge,
            ),
          ),
        ),
    ],
  );
}

class _PriceBlock extends StatelessWidget {
  final CartItem item;
  const _PriceBlock({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(controller.formatPrice(item.price), style: AppTextStyle.price),
        if (item.originalPrice != null) ...[
          const SizedBox(height: 2),
          Text(
            controller.formatPrice(item.originalPrice!),
            style: AppTextStyle.labelSmall.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class _StockWarning extends StatelessWidget {
  final bool isArabic;
  const _StockWarning({required this.isArabic});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: AppColor.errorLight,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 16,
          color: AppColor.error,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            isArabic
                ? 'الكمية المطلوبة لم تعد متوفرة.'
                : 'The requested quantity is no longer available.',
            style: AppTextStyle.chip.copyWith(color: AppColor.error),
          ),
        ),
      ],
    ),
  );
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
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColor.greyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: atMin ? Icons.delete_outline_rounded : Icons.remove_rounded,
            color: atMin ? AppColor.error : AppColor.primaryColor,
            onTap: () => controller.decreaseQuantity(item.id, sellerId),
          ),
          SizedBox(
            width: 31,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: AppTextStyle.labelLarge,
            ),
          ),
          _QtyButton(
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

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: SizedBox(
      width: 36,
      height: 36,
      child: Icon(icon, size: 18, color: color),
    ),
  );
}
