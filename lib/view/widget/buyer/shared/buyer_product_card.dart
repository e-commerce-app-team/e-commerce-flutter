import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import 'package:e_commerce/core/utils/buyer_format_utils.dart';
import 'buyer_network_image.dart';

/// The single product card used everywhere a product is shown on the
/// buyer home screen (trending grid, flash sale row, recommendations).
/// One definition, reused with different data, keeps the catalog feel
/// consistent instead of drifting into several slightly-different cards.
class BuyerProductCard extends StatelessWidget {
  final BuyerProductItem product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToCart;

  const BuyerProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onFavoriteToggle,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double? discount = product.discountPercent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColor.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BuyerNetworkImage(url: product.imageUrl),
                  if (product.badgeLabel != null)
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: _Chip(
                        label: product.badgeLabel!,
                        background: AppColor.black.withOpacity(0.72),
                      ),
                    )
                  else if (discount != null)
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: _Chip(
                        label: '-${discount.round()}%',
                        background: AppColor.error,
                      ),
                    ),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.backgroundcolor.withOpacity(0.92),
                        ),
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: product.isFavorite ? AppColor.error : AppColor.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyle.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (product.ratingCount > 0)
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 13, color: AppColor.warning),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppTextStyle.labelSmall.copyWith(color: AppColor.black),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${product.ratingCount})',
                          style: AppTextStyle.timestamp,
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product.oldPrice != null)
                              Text(
                                '${formatBuyerPrice(product.oldPrice!)} ${'currency'.tr}',
                                style: AppTextStyle.bodySmall.copyWith(
                                  color: AppColor.greyLight,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '${formatBuyerPrice(product.price)} ${'currency'.tr}',
                              style: AppTextStyle.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (onAddToCart != null) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              gradient: AppColor.mainGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: AppColor.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color background;

  const _Chip({required this.label, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyle.badge),
    );
  }
}
