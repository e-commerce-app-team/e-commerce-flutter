import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/explore/explore_models.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_network_image.dart';

class ExploreStoreCard extends StatelessWidget {
  final ExploreStoreModel store;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  const ExploreStoreCard({
    Key? key,
    required this.store,
    required this.index,
    required this.onTap,
    required this.onFollowTap,
  }) : super(key: key);

  static List<List<Color>> _gradients = [
    [AppColor.primarySurface, AppColor.primaryLight],
    [AppColor.statViewsLight, AppColor.statViews],
    [AppColor.statOrdersLight, AppColor.statOrders],
    [AppColor.successLight, AppColor.success],
    [AppColor.warningLight, AppColor.warning],
    [AppColor.infoLight, AppColor.info],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[index % _gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColor.cardShadow,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 64,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: store.coverUrl.isEmpty
                        ? LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: store.coverUrl.isEmpty
                      ? const Icon(Icons.storefront_rounded, color: Colors.white, size: 26)
                      : BuyerNetworkImage(
                          url: store.coverUrl,
                          fallbackIcon: Icons.storefront_rounded,
                          backgroundColor: gradient.first.withOpacity(0.25),
                        ),
                ),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  bottom: -6,
                  end: -6,
                  child: Container(
                    width: 34,
                    height: 34,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColor.backgroundcolor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColor.backgroundcolor, width: 2),
                    ),
                    child: store.logoUrl.isEmpty
                        ? Icon(
                            Icons.store_mall_directory_rounded,
                            color: AppColor.primaryColor,
                            size: 18,
                          )
                        : BuyerNetworkImage(
                            url: store.logoUrl,
                            fallbackIcon: Icons.store_mall_directory_rounded,
                            fallbackIconSize: 18,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.heading3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: store.isOpen ? AppColor.successLight : AppColor.secondBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          store.isOpen
                              ? 'explore_store_open'.tr
                              : 'explore_store_closed'.tr,
                          style: AppTextStyle.labelSmall.copyWith(
                            color: store.isOpen ? AppColor.success : AppColor.grey,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColor.warning),
                      const SizedBox(width: 3),
                      Text(
                        store.rating.toStringAsFixed(1),
                        style: AppTextStyle.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColor.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColor.greyLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${store.productCount} ${'explore_products_count'.tr}',
                        style: AppTextStyle.labelSmall,
                      ),
                      if (store.distance != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColor.greyLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${store.distance!.toStringAsFixed(1)} ${'km_away'.tr}',
                          style: AppTextStyle.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFollowTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: store.isFollowing ? AppColor.secondBackground : AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  border: store.isFollowing
                      ? Border.all(color: AppColor.greyBorder)
                      : null,
                ),
                child: Text(
                  store.isFollowing ? 'explore_following'.tr : 'explore_follow'.tr,
                  style: AppTextStyle.labelSmall.copyWith(
                    color: store.isFollowing ? AppColor.grey : Colors.white,
                    fontWeight: FontWeight.w700,
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
