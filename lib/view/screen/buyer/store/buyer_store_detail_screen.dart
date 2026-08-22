import 'package:e_commerce/controller/buyer/buyer_store_detail_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/functions/format_price.dart';
import 'package:e_commerce/data/models/buyer/store_detail_models.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuyerStoreDetailScreen extends StatelessWidget {
  const BuyerStoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final storeId = args is Map
        ? args['store_id']?.toString()
        : args?.toString();
    if (storeId == null || storeId.isEmpty) {
      return Scaffold(
        body: _FullState(
          icon: Icons.storefront_outlined,
          title: 'buyer_store_not_selected'.tr,
          message: 'buyer_store_not_found'.tr,
        ),
      );
    }

    if (!Get.isRegistered<BuyerStoreDetailController>(tag: storeId)) {
      Get.put(BuyerStoreDetailController(storeId: storeId), tag: storeId);
    }

    return GetBuilder<BuyerStoreDetailController>(
      tag: storeId,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.backgroundScaffold,
          body: SafeArea(
            bottom: false,
            child: controller.statusRequest == StatusRequest.loading
                ? const _StoreLoading()
                : controller.store == null
                ? _StoreError(onRetry: controller.loadStore)
                : RefreshIndicator(
                    color: AppColor.primaryColor,
                    onRefresh: controller.loadStore,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.extentAfter < 500 &&
                            controller.hasMore &&
                            !controller.isLoadingMore) {
                          controller.loadProducts();
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _StoreHeader(controller: controller),
                          ),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _FilterHeaderDelegate(
                              child: _SearchAndFilterBar(
                                controller: controller,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _DepartmentSection(controller: controller),
                          ),
                          SliverToBoxAdapter(
                            child: _ProductsHeader(controller: controller),
                          ),
                          _ProductGrid(controller: controller),
                          SliverToBoxAdapter(
                            child: _ReviewsSection(controller: controller),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 36)),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    final store = controller.store!;
    final surface = Theme.of(context).colorScheme.surface;
    return Column(
      children: [
        SizedBox(
          height: 238,
          child: Stack(
            fit: StackFit.expand,
            children: [
              BuyerNetworkImage(
                url: store.coverUrl,
                fallbackIcon: Icons.storefront_rounded,
                fallbackIconSize: 58,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: .42),
                      Colors.transparent,
                      Colors.black.withValues(alpha: .72),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                top: 12,
                start: 12,
                child: _CircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: 'back_label'.tr,
                  onTap: Get.back,
                ),
              ),
              PositionedDirectional(
                top: 12,
                end: 12,
                child: _CircleButton(
                  icon: store.isFollowing
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: store.isFollowing
                      ? 'explore_following'.tr
                      : 'explore_follow'.tr,
                  onTap: controller.toggleFollow,
                ),
              ),
              PositionedDirectional(
                start: 20,
                end: 20,
                bottom: 18,
                child: Row(
                  children: [
                    _StoreLogo(url: store.logoUrl, size: 78),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          if (store.category.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              store.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
          padding: const EdgeInsets.fromLTRB(16, 42, 16, 18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: AppColor.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.description.isNotEmpty) ...[
                Text(
                  store.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyMedium.copyWith(height: 1.6),
                ),
                const SizedBox(height: 16),
              ],
              _StoreStats(store: store),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: controller.isTogglingFollow
                      ? null
                      : controller.toggleFollow,
                  icon: Icon(
                    store.isFollowing ? Icons.check_rounded : Icons.add_rounded,
                  ),
                  label: Text(
                    store.isFollowing
                        ? 'explore_following'.tr
                        : 'explore_follow'.tr,
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (_hasStoreInfo(store)) ...[
                const SizedBox(height: 16),
                Text('description'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (store.phone.isNotEmpty)
                      _InfoChip(Icons.call_outlined, store.phone),
                    if (store.email.isNotEmpty)
                      _InfoChip(Icons.mail_outline_rounded, store.email),
                    if (store.address.isNotEmpty)
                      _InfoChip(Icons.location_on_outlined, store.address),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _hasStoreInfo(BuyerStoreDetailModel store) =>
      store.phone.isNotEmpty ||
      store.email.isNotEmpty ||
      store.address.isNotEmpty;
}

class _StoreStats extends StatelessWidget {
  const _StoreStats({required this.store});

  final BuyerStoreDetailModel store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.star_rounded,
            value: store.rating.toStringAsFixed(1),
            label: '${store.reviewsCount} ${'reviews'.tr}',
            color: AppColor.warning,
          ),
        ),
        _StatDivider(),
        Expanded(
          child: _StatItem(
            icon: Icons.people_alt_outlined,
            value: '${store.followersCount}',
            label: 'acct_followers'.tr,
            color: AppColor.primaryColor,
          ),
        ),
        _StatDivider(),
        Expanded(
          child: _StatItem(
            icon: Icons.inventory_2_outlined,
            value: '${store.productsCount}',
            label: 'products_count'.tr,
            color: AppColor.info,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: AppColor.greyBorder);
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 5),
        Text(value, style: AppTextStyle.heading2),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.labelMedium,
        ),
      ],
    );
  }
}

class _DepartmentSection extends StatelessWidget {
  const _DepartmentSection({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    final departments = controller.currentDepartments;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('category'.tr, style: AppTextStyle.heading1),
              ),
              if (controller.departmentPath.isNotEmpty)
                TextButton.icon(
                  onPressed: controller.popDepartment,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text('all'.tr),
                ),
            ],
          ),
          if (controller.departmentsStatus == StatusRequest.failure)
            _InlineState(
              icon: Icons.cloud_off_outlined,
              message: 'buyer_store_reviews_load_failed'.tr,
              onRetry: () => controller.loadStore(),
            )
          else if (departments.isEmpty)
            _InlineState(
              icon: Icons.category_outlined,
              message: 'buyer_store_no_departments'.tr,
            )
          else
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: departments.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final department = departments[index];
                  return _DepartmentTile(
                    department: department,
                    selected: department.id == controller.selectedDepartmentId,
                    onTap: () => controller.openDepartment(department),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DepartmentTile extends StatelessWidget {
  const _DepartmentTile({
    required this.department,
    required this.selected,
    required this.onTap,
  });

  final BuyerStoreDepartmentModel department;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 132,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.primarySurface
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColor.primaryColor : AppColor.greyBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                department.hasChildren
                    ? Icons.account_tree_outlined
                    : Icons.category_outlined,
                color: selected ? AppColor.primaryColor : AppColor.info,
              ),
              const Spacer(),
              Text(
                department.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.labelLarge,
              ),
              Text(
                department.hasChildren
                    ? '›'
                    : '${department.productsCount} ${'products_count'.tr}',
                style: AppTextStyle.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.backgroundScaffold,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'search_hint_home'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'reset_filter'.tr,
                        onPressed: () {
                          controller.searchController.clear();
                          controller.loadProducts(reset: true);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => _showFilterSheet(context, controller),
                borderRadius: BorderRadius.circular(14),
                child: const Icon(Icons.tune_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'explore_tab_products'.tr,
              style: AppTextStyle.heading1,
            ),
          ),
          Text(
            '${controller.products.length}',
            style: AppTextStyle.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.productsStatus == StatusRequest.loading &&
        controller.products.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const _ProductSkeleton(),
            childCount: 6,
          ),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 308,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
        ),
      );
    }

    if (controller.productsStatus == StatusRequest.failure &&
        controller.products.isEmpty) {
      return SliverToBoxAdapter(
        child: _InlineState(
          icon: Icons.cloud_off_outlined,
          message: 'buyer_store_load_failed'.tr,
          onRetry: () => controller.loadProducts(reset: true),
        ),
      );
    }

    if (controller.products.isEmpty) {
      return SliverToBoxAdapter(
        child: _InlineState(
          icon: Icons.inventory_2_outlined,
          message: 'buyer_store_no_products'.tr,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) => _StoreProductCard(product: controller.products[index]),
          childCount: controller.products.length,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisExtent: 308,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
      ),
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  const _StoreProductCard({required this.product});

  final BuyerStoreProductModel product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoute.buyerProductDetail,
          arguments: {'product_id': product.id},
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 162,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BuyerNetworkImage(
                    url: product.imageUrl,
                    fallbackIcon: Icons.image_outlined,
                  ),
                  if (product.hasDiscount)
                    PositionedDirectional(
                      top: 9,
                      start: 9,
                      child: _Badge(label: 'offers_title'.tr),
                    ),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: _IconBadge(
                      icon: product.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: product.isFavorite
                          ? AppColor.error
                          : AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.labelLarge.copyWith(height: 1.3),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColor.warning,
                          size: 15,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppTextStyle.labelMedium,
                        ),
                        const Spacer(),
                        if (product.stock <= 0)
                          Text(
                            'out_of_stock'.tr,
                            style: AppTextStyle.labelSmall.copyWith(
                              color: AppColor.error,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (product.oldPrice != null)
                      Text(
                        '${formatPrice(product.oldPrice!)} ل.س',
                        style: AppTextStyle.labelSmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '${formatPrice(product.price)} ل.س',
                      style: AppTextStyle.price.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    final store = controller.store!;
    final review = controller.myReview;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'customer_reviews'.tr,
                  style: AppTextStyle.heading1,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColor.warning,
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    store.rating.toStringAsFixed(1),
                    style: AppTextStyle.heading3,
                  ),
                  Text(
                    ' (${store.reviewsCount})',
                    style: AppTextStyle.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!controller.isAuthenticated)
            _ReviewAction(
              label: 'write_review'.tr,
              icon: Icons.rate_review_outlined,
              onTap: () => _showReviewSheet(context, controller),
            )
          else if (store.canReview || review != null)
            _ReviewAction(
              label: review == null ? 'write_review'.tr : 'edit_review'.tr,
              icon: review == null
                  ? Icons.rate_review_outlined
                  : Icons.edit_note_rounded,
              onTap: () => _showReviewSheet(context, controller),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'buyer_store_review_not_eligible'.tr,
                style: AppTextStyle.bodySmall,
              ),
            ),
          if (controller.reviewsStatus == StatusRequest.loading)
            const _ReviewSkeleton()
          else if (controller.reviewsStatus == StatusRequest.failure)
            _InlineState(
              icon: Icons.cloud_off_outlined,
              message: 'buyer_store_reviews_load_failed'.tr,
              onRetry: controller.loadStore,
            )
          else if (controller.reviews.isEmpty)
            _InlineState(
              icon: Icons.forum_outlined,
              message: 'buyer_no_reviews'.tr,
            )
          else
            ...controller.reviews.map((item) => _ReviewTile(review: item)),
        ],
      ),
    );
  }
}

class _ReviewAction extends StatelessWidget {
  const _ReviewAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 19),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColor.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final BuyerStoreReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColor.primarySurface,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColor.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  review.buyerName.isEmpty ? 'buyer'.tr : review.buyerName,
                  style: AppTextStyle.labelLarge,
                ),
              ),
              const Icon(Icons.star_rounded, color: AppColor.warning, size: 17),
              const SizedBox(width: 3),
              Text(
                review.rating.toStringAsFixed(1),
                style: AppTextStyle.labelLarge,
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(review.comment, style: AppTextStyle.bodyMedium),
          ],
        ],
      ),
    );
  }
}

void _showReviewSheet(
  BuildContext context,
  BuyerStoreDetailController controller,
) {
  controller.prepareReview();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GetBuilder<BuyerStoreDetailController>(
      tag: controller.storeId,
      builder: (ctrl) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.greyBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  ctrl.myReview == null ? 'write_review'.tr : 'edit_review'.tr,
                  style: AppTextStyle.heading2,
                ),
                const SizedBox(height: 12),
                Text('reviews'.tr, style: AppTextStyle.labelLarge),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final value = index + 1.0;
                    return IconButton(
                      tooltip: '$value',
                      onPressed: () {
                        ctrl.selectedRating = value;
                        ctrl.update();
                      },
                      icon: Icon(
                        ctrl.selectedRating >= value
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppColor.warning,
                        size: 34,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text('description'.tr, style: AppTextStyle.labelLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: ctrl.reviewController,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'review_hint'.tr,
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppColor.secondBackground,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: ctrl.isSubmittingReview
                        ? null
                        : ctrl.submitReview,
                    icon: ctrl.isSubmittingReview
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text('publish_review'.tr),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void _showFilterSheet(
  BuildContext context,
  BuyerStoreDetailController controller,
) {
  final minController = TextEditingController();
  final maxController = TextEditingController();
  var sort = controller.sortBy;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.greyBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('filter_products'.tr, style: AppTextStyle.heading2),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PriceField(
                      controller: minController,
                      hint: 'price'.tr,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PriceField(
                      controller: maxController,
                      hint: 'price'.tr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    {
                      'latest': 'sort_latest'.tr,
                      'price_asc': 'sort_price_asc'.tr,
                      'price_desc': 'sort_price_desc'.tr,
                      'rating': 'reviews'.tr,
                    }.entries.map((entry) {
                      final selected = sort == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: selected,
                        onSelected: (_) => setState(() => sort = entry.key),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        controller.clearFilters();
                      },
                      child: Text('reset_filter'.tr),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.applyFilters(
                          min: num.tryParse(minController.text),
                          max: num.tryParse(maxController.text),
                          sort: sort,
                        );
                      },
                      child: Text('apply_filter'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: AppColor.backgroundScaffold,
      elevation: overlapsContent ? 2 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
}

class _StoreLogo extends StatelessWidget {
  const _StoreLogo({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppColor.cardShadow,
      ),
      child: ClipOval(
        child: BuyerNetworkImage(
          url: url,
          fallbackIcon: Icons.storefront_rounded,
          backgroundColor: AppColor.secondBackground,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black.withValues(alpha: .36),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColor.primaryColor),
          const SizedBox(width: 6),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .92),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InlineState extends StatelessWidget {
  const _InlineState({required this.icon, required this.message, this.onRetry});

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: AppColor.greyLight, size: 30),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySmall,
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text('retry'.tr)),
          ],
        ),
      ),
    );
  }
}

class _FullState extends StatelessWidget {
  const _FullState({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: AppColor.greyLight),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyle.heading2),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMedium,
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text('retry'.tr)),
          ],
        ),
      ),
    );
  }
}

class _StoreError extends StatelessWidget {
  const _StoreError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _FullState(
      icon: Icons.cloud_off_outlined,
      title: 'error'.tr,
      message: 'buyer_store_load_failed'.tr,
      onRetry: onRetry,
    );
  }
}

class _StoreLoading extends StatelessWidget {
  const _StoreLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const _SkeletonBox(height: 238, radius: 0),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            padding: const EdgeInsets.fromLTRB(16, 42, 16, 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: const Column(
              children: [
                _SkeletonBox(height: 18, radius: 8),
                SizedBox(height: 14),
                _SkeletonBox(height: 70, radius: 14),
                SizedBox(height: 14),
                _SkeletonBox(height: 48, radius: 14),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SkeletonBox(height: 48, radius: 14),
          const SizedBox(height: 20),
          const _ProductSkeletonRow(),
        ],
      ),
    );
  }
}

class _ProductSkeletonRow extends StatelessWidget {
  const _ProductSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Expanded(child: _ProductSkeleton()),
          const SizedBox(width: 12),
          const Expanded(child: _ProductSkeleton()),
        ],
      ),
    );
  }
}

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          _SkeletonBox(height: 160, radius: 0),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                _SkeletonBox(height: 14, radius: 6),
                SizedBox(height: 10),
                _SkeletonBox(height: 14, radius: 6),
                SizedBox(height: 32),
                _SkeletonBox(height: 16, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSkeleton extends StatelessWidget {
  const _ReviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SkeletonBox(height: 80, radius: 16),
        SizedBox(height: 10),
        _SkeletonBox(height: 80, radius: 16),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.greyBorder.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
