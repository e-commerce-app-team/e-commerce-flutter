import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/functions/format_price.dart';
import 'package:e_commerce/data/models/explore/explore_models.dart';

class ExploreProductCard extends StatelessWidget {
  final ExploreProductModel product;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onAddToCart;

  const ExploreProductCard({
    Key? key,
    required this.product,
    required this.index,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onAddToCart,
  }) : super(key: key);

  static const List<List<Color>> _placeholderGradients = [
    [AppColor.primarySurface, AppColor.primaryLight],
    [AppColor.statViewsLight, AppColor.statViews],
    [AppColor.statOrdersLight, AppColor.statOrders],
    [AppColor.successLight, AppColor.success],
    [AppColor.warningLight, AppColor.warning],
    [AppColor.infoLight, AppColor.info],
  ];

  static const List<IconData> _categoryIcons = [
    Icons.headphones_rounded,
    Icons.checkroom_rounded,
    Icons.chair_outlined,
    Icons.face_retouching_natural_rounded,
    Icons.shopping_basket_outlined,
    Icons.toys_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final gradient = _placeholderGradients[index % _placeholderGradients.length];
    final placeholderIcon = _categoryIcons[index % _categoryIcons.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColor.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        placeholderIcon,
                        size: 44,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned.directional(
                      textDirection: direction,
                      top: 10,
                      start: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: AppTextStyle.badge,
                        ),
                      ),
                    ),
                  Positioned.directional(
                    textDirection: direction,
                    top: 8,
                    end: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
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
                  if (product.hasFreeShipping)
                    Positioned.directional(
                      textDirection: direction,
                      bottom: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.94),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_shipping_rounded,
                              size: 11,
                              color: AppColor.success,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'free_shipping'.tr,
                              style: AppTextStyle.labelSmall.copyWith(
                                color: AppColor.success,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned.directional(
                    textDirection: direction,
                    bottom: 8,
                    end: 8,
                    child: GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: AppColor.mainGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.labelSmall.copyWith(color: AppColor.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodyLarge.copyWith(fontSize: 13.5, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: AppColor.warning),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: AppTextStyle.labelSmall.copyWith(
                          color: AppColor.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text('(${product.reviewCount})', style: AppTextStyle.labelSmall),
                      if (product.hasWholesalePrice) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColor.shippedBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'explore_wholesale_badge'.tr,
                            style: AppTextStyle.labelSmall.copyWith(
                              color: AppColor.shippedText,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${formatPrice(product.displayPrice)} ${'currency'.tr}',
                        style: AppTextStyle.price.copyWith(fontSize: 14.5),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          formatPrice(product.price),
                          style: AppTextStyle.bodySmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColor.greyLight,
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
