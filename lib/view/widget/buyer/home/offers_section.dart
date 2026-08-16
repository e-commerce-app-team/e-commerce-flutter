import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_product_card.dart';
import '../shared/buyer_section_header.dart';

/// Deals & Offers — products with active discounts, shown in a visually
/// charged horizontal row with a "fire" eyebrow to signal urgency.
class OffersSection extends StatelessWidget {
  final List<BuyerProductItem> products;
  final VoidCallback? onSeeAll;
  final void Function(int index)? onProductTap;
  final void Function(int index)? onFavoriteToggle;
  final void Function(int index)? onAddToCart;

  const OffersSection({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BuyerSectionHeader(
            eyebrow: 'eyebrow_offers'.tr,
            title: 'offers_title'.tr,
            onSeeAll: onSeeAll,
          ),
        ),
        const SizedBox(height: 16),
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
