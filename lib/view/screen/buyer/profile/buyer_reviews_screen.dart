import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/controller/buyer/buyer_profile_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuyerReviewsScreen extends StatelessWidget {
  const BuyerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BuyerProfileController>()) {
      Get.put(BuyerProfileController());
    }

    return GetBuilder<BuyerProfileController>(
      initState: (_) => _safeLoad(Get.find<BuyerProfileController>()),
      builder: (controller) {
        final StatusRequest status = _safeStatus(controller);
        final List reviews = _safeReviews(controller);

        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColor.darkSecondBackground : AppColor.secondBackground,
          appBar: AppBar(
            title: Text(
              'buyer_reviews_title'.tr,
              style: AppTextStyle.heading2.copyWith(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: AppColor.primaryColor,
          ),
          body: status == StatusRequest.loading
              ? const _ReviewsShimmer()
              : reviews.isEmpty
                  ? const _ReviewsEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (_, index) => _ReviewCard(
                        controller: controller,
                        review: reviews[index],
                      ),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: reviews.length,
                    ),
        );
      },
    );
  }

  Future<void> _safeLoad(BuyerProfileController controller) async {
    final dynamic c = controller;
    await c.loadReviews();
  }

  StatusRequest _safeStatus(BuyerProfileController controller) {
    final dynamic c = controller;
    return (c.statusRequest as StatusRequest?) ?? StatusRequest.none;
  }

  List _safeReviews(BuyerProfileController controller) {
    final dynamic c = controller;
    final dynamic reviews = c.myReviews;
    return reviews is List ? reviews : <dynamic>[];
  }
}

class _ReviewCard extends StatelessWidget {
  final BuyerProfileController controller;
  final Map review;

  const _ReviewCard({
    required this.controller,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Map product = (review['product'] as Map?) ?? <String, dynamic>{};
    final List images = (product['images'] as List?) ?? <dynamic>[];
    final String imageUrl = images.isNotEmpty ? _toString(images.first) : '';
    final int stars = int.tryParse(_toString(review['rating'])) ?? 0;
    final bool canEdit = _safeCanEdit(controller, review);
    final Map? sellerReply = review['seller_reply'] as Map?;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const _ReviewImageFallback(),
                        placeholder: (_, __) => const _ReviewImageFallback(),
                      )
                    : const _ReviewImageFallback(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _toString(product['name']),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.heading3.copyWith(
                    color: isDark ? Colors.white : AppColor.black,
                  ),
                ),
              ),
              if (canEdit)
                TextButton(
                  onPressed: () => _openEditSheet(context, controller, review),
                  child: Text(
                    'edit'.tr,
                    style: AppTextStyle.labelLarge.copyWith(color: AppColor.primaryColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                size: 18,
                color: AppColor.warning,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _toString(review['comment']),
            style: AppTextStyle.bodyMedium.copyWith(
              color: isDark ? AppColor.greyLight : AppColor.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _toString(review['created_at']),
            style: AppTextStyle.timestamp,
          ),
          if (sellerReply != null && sellerReply.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColor.darkSecondBackground : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'buyer_seller_reply_title'.tr,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: AppColor.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _toString(sellerReply['message']),
                    style: AppTextStyle.bodySmall.copyWith(
                      color: isDark ? AppColor.greyLight : AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _safeCanEdit(BuyerProfileController controller, Map review) {
    final dynamic c = controller;
    return c.canEditReview(review) == true;
  }

  void _openEditSheet(BuildContext context, BuyerProfileController controller, Map review) {
    int selectedRating = int.tryParse(_toString(review['rating'])) ?? 0;
    final TextEditingController commentController =
        TextEditingController(text: _toString(review['comment']));

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'buyer_edit_review_title'.tr,
                  style: AppTextStyle.heading3.copyWith(
                    color: Get.isDarkMode ? Colors.white : AppColor.black,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () => setState(() => selectedRating = index + 1),
                      icon: Icon(
                        index < selectedRating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppColor.warning,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'buyer_review_comment_hint'.tr,
                    hintStyle: AppTextStyle.inputHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final dynamic c = controller;
                      await c.updateReview(
                        _toString(review['id']),
                        selectedRating,
                        commentController.text.trim(),
                      );
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'save'.tr,
                      style: AppTextStyle.buttonMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _ReviewImageFallback extends StatelessWidget {
  const _ReviewImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      color: AppColor.primarySurface,
      child: Icon(Icons.image_outlined, color: AppColor.primaryColor),
    );
  }
}

class _ReviewsEmptyState extends StatelessWidget {
  const _ReviewsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColor.warningLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_outline_rounded, color: AppColor.warning, size: 38),
          ),
          const SizedBox(height: 12),
          Text('buyer_no_reviews'.tr, style: AppTextStyle.heading3),
        ],
      ),
    );
  }
}

class _ReviewsShimmer extends StatelessWidget {
  const _ReviewsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColor.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(width: 52, height: 52, radius: 10),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(width: 160, height: 12)),
              ],
            ),
            SizedBox(height: 10),
            ShimmerBox(width: 110, height: 12),
            SizedBox(height: 10),
            ShimmerBox(width: double.infinity, height: 10),
            SizedBox(height: 6),
            ShimmerBox(width: 80, height: 10),
          ],
        ),
      ),
    );
  }
}

String _toString(dynamic value) => value?.toString() ?? '';
