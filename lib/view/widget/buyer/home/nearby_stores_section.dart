import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_network_image.dart';
import '../shared/buyer_section_header.dart';

/// Nearby Stores — map-pin-inspired cards showing stores sorted by
/// proximity. Each card shows a distance badge so the buyer immediately
/// knows how far the store is without opening details.
class NearbyStoresSection extends StatelessWidget {
  final List<BuyerStoreItem> stores;
  final VoidCallback? onSeeAll;
  final void Function(int index)? onStoreTap;

  const NearbyStoresSection({
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
            eyebrow: 'eyebrow_nearby'.tr,
            title: 'nearby_stores_title'.tr,
            onSeeAll: onSeeAll,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: stores.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _NearbyStoreCard(
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

class _NearbyStoreCard extends StatelessWidget {
  final BuyerStoreItem store;
  final VoidCallback? onTap;

  const _NearbyStoreCard({required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColor.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Cover image
            SizedBox(
              height: 148,
              width: 220,
              child: BuyerNetworkImage(
                url: store.coverUrl,
                fallbackIcon: Icons.storefront_outlined,
              ),
            ),
            // Bottom gradient scrim
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColor.black.withOpacity(0.78),
                    ],
                  ),
                ),
              ),
            ),
            // Store name + category bottom
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Logo
                  Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColor.backgroundcolor,
                      shape: BoxShape.circle,
                      boxShadow: AppColor.cardShadow,
                    ),
                    child: ClipOval(
                      child: BuyerNetworkImage(
                        url: store.logoUrl,
                        fallbackIcon: Icons.store_rounded,
                        fallbackIconSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          store.name,
                          style: AppTextStyle.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 11,
                              color: AppColor.warning,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              store.rating.toStringAsFixed(1),
                              style: AppTextStyle.labelSmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Distance badge top-right
            if (store.distance != null)
              PositionedDirectional(
                top: 10,
                end: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.near_me_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${store.distance!.toStringAsFixed(1)} ${'km_away'.tr}',
                        style: AppTextStyle.badge.copyWith(
                          color: Colors.white,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Open/Closed badge top-left
            PositionedDirectional(
              top: 10,
              start: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: store.isOpen
                      ? AppColor.success.withOpacity(0.88)
                      : AppColor.error.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  store.isOpen ? 'open_now'.tr : 'closed_now'.tr,
                  style: AppTextStyle.badge.copyWith(fontSize: 9.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
