import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/explore/explore_models.dart';

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

  static const List<List<Color>> _gradients = [
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
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
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
                  Text(store.category.tr, style: AppTextStyle.bodySmall),
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
                        decoration: const BoxDecoration(
                          color: AppColor.greyLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${store.productCount} ${'explore_products_count'.tr}',
                        style: AppTextStyle.labelSmall,
                      ),
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
