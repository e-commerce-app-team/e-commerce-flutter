import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_product_card.dart';
import '../shared/buyer_section_header.dart';

/// All Products — a 2-column grid of the complete catalog, shown at the
/// bottom of the home screen. Includes a "Load More" button for
/// pagination without infinite scroll (to avoid performance issues
/// inside a nested scroll view).
class AllProductsSection extends StatelessWidget {
  final List<BuyerProductItem> products;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final void Function(int index)? onProductTap;
  final void Function(int index)? onFavoriteToggle;
  final void Function(int index)? onAddToCart;

  const AllProductsSection({
    Key? key,
    required this.products,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onProductTap,
    this.onFavoriteToggle,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty && !isLoading) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BuyerSectionHeader(
            eyebrow: 'eyebrow_all'.tr,
            title: 'all_products_title'.tr,
          ),
          const SizedBox(height: 16),
          // Shimmer placeholders during first load
          if (products.isEmpty && isLoading)
            _LoadingGrid()
          else
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
                  onFavoriteToggle: onFavoriteToggle == null
                      ? null
                      : () => onFavoriteToggle!(index),
                  onAddToCart:
                      onAddToCart == null ? null : () => onAddToCart!(index),
                );
              },
            ),

          // Load more button
          if (hasMore && !isLoading) ...[
            const SizedBox(height: 20),
            _LoadMoreButton(onTap: onLoadMore),
          ],

          if (isLoading && products.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _LoadMoreButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'load_more'.tr,
              style: AppTextStyle.bodyLarge.copyWith(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.expand_more_rounded,
              color: AppColor.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColor.secondBackground,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
