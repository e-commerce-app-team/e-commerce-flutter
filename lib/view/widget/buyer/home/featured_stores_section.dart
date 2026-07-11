import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_network_image.dart';
import '../shared/buyer_section_header.dart';

/// A store card modeled on a boutique storefront listing: the logo sits
/// half over the cover photo, the way a shop sign overlaps its own
/// window display, instead of two flat, stacked rectangles.
class BuyerStoreCard extends StatelessWidget {
  final BuyerStoreItem store;
  final VoidCallback? onTap;
  static const double _coverHeight = 88;
  static const double _logoSize = 46;

  const BuyerStoreCard({
    Key? key,
    required this.store,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColor.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: _coverHeight,
                  width: double.infinity,
                  child: BuyerNetworkImage(
                    url: store.coverUrl,
                    fallbackIcon: Icons.storefront_outlined,
                  ),
                ),
                const SizedBox(height: _logoSize / 2 + 6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        store.name,
                        style: AppTextStyle.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        store.category,
                        style: AppTextStyle.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 13, color: AppColor.warning),
                          const SizedBox(width: 3),
                          Text(
                            store.rating.toStringAsFixed(1),
                            style: AppTextStyle.labelSmall.copyWith(color: AppColor.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (store.isFeatured)
              PositionedDirectional(
                top: 8,
                start: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 10, color: AppColor.white),
                      const SizedBox(width: 3),
                      Text('featured_badge'.tr, style: AppTextStyle.badge),
                    ],
                  ),
                ),
              ),
            if (store.isOpen)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.successLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColor.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'open_now'.tr,
                        style: AppTextStyle.labelSmall.copyWith(color: AppColor.successDark),
                      ),
                    ],
                  ),
                ),
              ),
            PositionedDirectional(
              top: _coverHeight - _logoSize / 2,
              start: 12,
              child: Container(
                width: _logoSize,
                height: _logoSize,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: AppColor.backgroundcolor,
                  shape: BoxShape.circle,
                  boxShadow: AppColor.cardShadow,
                ),
                child: ClipOval(
                  child: BuyerNetworkImage(
                    url: store.logoUrl,
                    fallbackIcon: Icons.storefront_outlined,
                    fallbackIconSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal row of [BuyerStoreCard]s under a [BuyerSectionHeader].
class FeaturedStoresSection extends StatelessWidget {
  final List<BuyerStoreItem> stores;
  final VoidCallback? onSeeAll;
  final void Function(int index)? onStoreTap;

  const FeaturedStoresSection({
    Key? key,
    required this.stores,
    this.onSeeAll,
    this.onStoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BuyerSectionHeader(
            eyebrow: 'eyebrow_curated'.tr,
            title: 'featured_stores_title'.tr,
            onSeeAll: onSeeAll,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 224,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: stores.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return BuyerStoreCard(
                store: stores[index],
                onTap: onStoreTap == null ? null : () => onStoreTap!(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
