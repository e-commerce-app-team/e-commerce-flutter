import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/controller/buyer/buyer_profile_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuyerFollowingStoresScreen extends StatelessWidget {
  const BuyerFollowingStoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BuyerProfileController>()) {
      Get.put(BuyerProfileController());
    }

    return GetBuilder<BuyerProfileController>(
      initState: (_) => _safeLoad(Get.find<BuyerProfileController>()),
      builder: (controller) {
        final List stores = _safeStores(controller);
        final StatusRequest status = _safeStatus(controller);

        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColor.darkSecondBackground : AppColor.secondBackground,
          appBar: AppBar(
            title: Text(
              'buyer_following_title'.tr,
              style: AppTextStyle.heading2.copyWith(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: AppColor.primaryColor,
          ),
          body: status == StatusRequest.loading
              ? const _FollowingShimmer()
              : RefreshIndicator(
                  onRefresh: () => _safeLoad(controller),
                  color: AppColor.primaryColor,
                  child: stores.isEmpty
                      ? const _FollowingEmptyState()
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) => _StoreCard(
                            store: stores[index],
                            onTap: () {
                              final id = _toString(stores[index]['id']);
                              Get.toNamed(AppRoute.buyerStoreDetail, arguments: id);
                            },
                            onUnfollow: () => _confirmUnfollow(
                              context: context,
                              controller: controller,
                              store: stores[index],
                            ),
                          ),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemCount: stores.length,
                        ),
                ),
        );
      },
    );
  }

  Future<void> _safeLoad(BuyerProfileController controller) async {
    final dynamic c = controller;
    await c.loadFollowingStores();
  }

  StatusRequest _safeStatus(BuyerProfileController controller) {
    final dynamic c = controller;
    return (c.statusRequest as StatusRequest?) ?? StatusRequest.none;
  }

  List _safeStores(BuyerProfileController controller) {
    final dynamic c = controller;
    final dynamic stores = c.followingStores;
    return stores is List ? stores : <dynamic>[];
  }

  void _confirmUnfollow({
    required BuildContext context,
    required BuyerProfileController controller,
    required Map store,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Get.isDarkMode ? AppColor.darkCard : Colors.white,
        title: Text(
          'buyer_unfollow_confirm_title'.tr,
          style: AppTextStyle.heading3.copyWith(
            color: Get.isDarkMode ? Colors.white : AppColor.black,
          ),
        ),
        content: Text(
          'buyer_unfollow_confirm_body'.tr,
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'cancel'.tr,
              style: AppTextStyle.labelLarge.copyWith(color: AppColor.grey),
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              Get.back();
              final dynamic c = controller;
              await c.unfollowStore(_toString(store['id']));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColor.error),
            ),
            child: Text(
              'buyer_unfollow_btn'.tr,
              style: AppTextStyle.labelLarge.copyWith(color: AppColor.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Map store;
  final VoidCallback onTap;
  final VoidCallback onUnfollow;

  const _StoreCard({
    required this.store,
    required this.onTap,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: _toString(store['logo']),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const _StoreAvatarFallback(),
                placeholder: (_, __) => const _StoreAvatarFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _toString(store['name']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.heading3.copyWith(
                      color: isDark ? Colors.white : AppColor.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _toString(store['category']),
                    style: AppTextStyle.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${'buyer_followers_label'.tr}: ${_toString(store['followers_count'])}',
                    style: AppTextStyle.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${'buyer_followed_at_label'.tr}: ${_toString(store['followed_at'])}',
                    style: AppTextStyle.labelMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: onUnfollow,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.error,
                side: const BorderSide(color: AppColor.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('buyer_unfollow_btn'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreAvatarFallback extends StatelessWidget {
  const _StoreAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: AppColor.primarySurface,
      child: const Icon(Icons.store, color: AppColor.primaryColor),
    );
  }
}

class _FollowingEmptyState extends StatelessWidget {
  const _FollowingEmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: AppColor.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.store_outlined,
                    color: AppColor.primaryColor,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Text('buyer_no_following'.tr, style: AppTextStyle.heading3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FollowingShimmer extends StatelessWidget {
  const _FollowingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: const Row(
          children: [
            ShimmerBox.circle(size: 56),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 12),
                  SizedBox(height: 8),
                  ShimmerBox(width: 100, height: 10),
                  SizedBox(height: 8),
                  ShimmerBox(width: 160, height: 10),
                ],
              ),
            ),
            SizedBox(width: 8),
            ShimmerBox(width: 74, height: 34, radius: 10),
          ],
        ),
      ),
    );
  }
}

String _toString(dynamic value) => value?.toString() ?? '';
