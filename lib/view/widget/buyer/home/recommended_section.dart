import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_section_header.dart';
import '../shared/buyer_product_card.dart';

/// Horizontal "picked for you" row, closing out the home screen. Reuses
/// [BuyerProductCard] rather than a bespoke layout — variety here comes
/// from the eyebrow copy and the horizontal rhythm, not a new card type.
class RecommendedSection extends StatelessWidget {
  final List<BuyerProductItem> products;
  final void Function(int index)? onProductTap;
  final void Function(int index)? onFavoriteToggle;
  final void Function(int index)? onAddToCart;

  const RecommendedSection({
    Key? key,
    required this.products,
    this.onProductTap,
    this.onFavoriteToggle,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BuyerSectionHeader(
            eyebrow: 'eyebrow_for_you'.tr,
            title: 'recommended_title'.tr,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 264,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 158,
                child: BuyerProductCard(
                  product: products[index],
                  onTap: onProductTap == null ? null : () => onProductTap!(index),
                  onFavoriteToggle: onFavoriteToggle == null
                      ? null
                      : () => onFavoriteToggle!(index),
                  onAddToCart: onAddToCart == null ? null : () => onAddToCart!(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
