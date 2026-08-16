import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_product_card.dart';
import '../shared/buyer_section_header.dart';

/// Favorites section — shows the user's saved/wishlisted products.
/// Hidden when favoriteProducts is empty — replaced by a gentle empty
/// state nudge instead of a blank section.
class FavoritesSection extends StatelessWidget {
  final List<BuyerProductItem> products;
  final VoidCallback? onSeeAll;
  final void Function(int index)? onProductTap;
  final void Function(int index)? onFavoriteToggle;
  final void Function(int index)? onAddToCart;

  const FavoritesSection({
    Key? key,
    required this.products,
    this.onSeeAll,
    this.onProductTap,
    this.onFavoriteToggle,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BuyerSectionHeader(
            eyebrow: 'eyebrow_favorites'.tr,
            title: 'favorites_title'.tr,
            onSeeAll: products.isNotEmpty ? onSeeAll : null,
          ),
        ),
        const SizedBox(height: 16),
        if (products.isEmpty)
          _EmptyFavoritesHint()
        else
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 160,
                  child: BuyerProductCard(
                    product: products[index],
                    onTap: onProductTap == null ? null : () => onProductTap!(index),
                    onFavoriteToggle: onFavoriteToggle == null
                        ? null
                        : () => onFavoriteToggle!(index),
                    onAddToCart:
                        onAddToCart == null ? null : () => onAddToCart!(index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyFavoritesHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColor.primarySurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColor.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'no_favorites'.tr,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: AppColor.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'add_to_favorites_hint'.tr,
                    style: AppTextStyle.bodySmall,
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
