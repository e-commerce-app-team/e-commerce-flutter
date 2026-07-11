import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_section_header.dart';
import '../shared/buyer_product_card.dart';

/// Two-column grid of [BuyerProductCard]s under a section header.
/// Nested inside the home screen's outer scroll view, so the grid itself
/// does not scroll independently.
class TrendingProductsSection extends StatelessWidget {
  final List<BuyerProductItem> products;
  final VoidCallback? onSeeAll;
  final void Function(int index)? onProductTap;
  final void Function(int index)? onFavoriteToggle;
  final void Function(int index)? onAddToCart;

  const TrendingProductsSection({
    Key? key,
    required this.products,
    this.onSeeAll,
    this.onProductTap,
    this.onFavoriteToggle,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BuyerSectionHeader(
            eyebrow: 'eyebrow_this_week'.tr,
            title: 'trending_products_title'.tr,
            onSeeAll: onSeeAll,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) {
              return BuyerProductCard(
                product: products[index],
                onTap: onProductTap == null ? null : () => onProductTap!(index),
                onFavoriteToggle:
                    onFavoriteToggle == null ? null : () => onFavoriteToggle!(index),
                onAddToCart: onAddToCart == null ? null : () => onAddToCart!(index),
              );
            },
          ),
        ],
      ),
    );
  }
}
