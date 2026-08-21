import 'package:e_commerce/controller/buyer/buyer_store_detail_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
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
    final storeId = args is Map ? args['store_id']?.toString() : args?.toString();
    if (storeId == null || storeId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Ù„Ù… ÙŠØªÙ… ØªØ­Ø¯ÙŠØ¯ Ø§Ù„Ù…ØªØ¬Ø±')));
    }

    Get.put(BuyerStoreDetailController(storeId: storeId), tag: storeId);

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
                    ? _StoreError(onRetry: () => controller.loadStore())
                    : RefreshIndicator(
                        color: AppColor.primaryColor,
                        onRefresh: controller.loadStore,
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: _StoreHeader(controller: controller),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _FilterHeaderDelegate(
                                child: _SearchAndFilterBar(controller: controller),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: _DepartmentNavigator(controller: controller),
                            ),
                            SliverToBoxAdapter(
                              child: _ProductsHeader(controller: controller),
                            ),
                            _ProductGrid(controller: controller),
                            SliverToBoxAdapter(
                              child: _ReviewsSection(controller: controller),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 32)),
                          ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 238,
              width: double.infinity,
              child: BuyerNetworkImage(
                url: store.coverUrl,
                fallbackIcon: Icons.storefront_rounded,
                fallbackIconSize: 56,
              ),
            ),
            Container(
              height: 238,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.black.withOpacity(0.35),
                    AppColor.black.withOpacity(0.05),
                    AppColor.black.withOpacity(0.68),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              top: 12,
              start: 12,
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
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
                onTap: controller.toggleFollow,
              ),
            ),
            PositionedDirectional(
              start: 20,
              end: 20,
              bottom: 18,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      shape: BoxShape.circle,
                      boxShadow: AppColor.cardShadow,
                    ),
                    child: ClipOval(
                      child: BuyerNetworkImage(
                        url: store.logoUrl,
                        fallbackIcon: Icons.storefront_rounded,
                      ),
                    ),
                  ),
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
                            color: AppColor.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoPill(
                              icon: Icons.star_rounded,
                              label:
                                  '${store.rating.toStringAsFixed(1)} (${store.reviewsCount})',
                              color: AppColor.warning,
                            ),
                            _InfoPill(
                              icon: Icons.inventory_2_outlined,
                              label: '${store.productsCount} Ù…Ù†ØªØ¬',
                            ),
                            _InfoPill(
                              icon: Icons.people_alt_outlined,
                              label: '${store.followersCount} Ù…ØªØ§Ø¨Ø¹',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(color: AppColor.backgroundcolor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.description.isNotEmpty)
                Text(
                  store.description,
                  style: TextStyle(
                    color: AppColor.greyText,
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (store.phone.isNotEmpty)
                    _ContactChip(icon: Icons.call_outlined, label: store.phone),
                  if (store.email.isNotEmpty)
                    _ContactChip(icon: Icons.mail_outline_rounded, label: store.email),
                  if (store.address.isNotEmpty)
                    _ContactChip(
                      icon: Icons.location_on_outlined,
                      label: store.address,
                    ),
                  ...store.socialLinks.entries.map(
                    (entry) => _ContactChip(
                      icon: Icons.alternate_email_rounded,
                      label: entry.key,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _PrimaryAction(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Ù…Ø±Ø§Ø³Ù„Ø© Ø§Ù„ØªØ§Ø¬Ø±',
                      onTap: () => Get.toNamed(
                        AppRoute.buyerChatRoom,
                        arguments: {
                          'store_id': store.id,
                          'seller_id': store.sellerId == 0
                              ? int.tryParse(store.id) ?? 0
                              : store.sellerId,
                          'store_name': store.name,
                          'store_logo': store.logoUrl,
                          'buyer_id': controller.buyerId,
                          'buyer_name': controller.buyerName,
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SecondaryAction(
                      icon: Icons.rate_review_outlined,
                      label: 'ØªÙ‚ÙŠÙŠÙ… Ø§Ù„Ù…ØªØ¬Ø±',
                      onTap: () => _showReviewSheet(context, controller),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.backgroundcolor,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Ø§Ø¨Ø­Ø« Ø¯Ø§Ø®Ù„ Ù‡Ø°Ø§ Ø§Ù„Ù…ØªØ¬Ø±',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColor.secondBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => _showFilterSheet(context, controller),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.tune_rounded, color: AppColor.primaryColor),
                  if (controller.activeFilterCount > 0)
                    PositionedDirectional(
                      top: 9,
                      end: 9,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: const BoxDecoration(
                          color: AppColor.error,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${controller.activeFilterCount}',
                          style: const TextStyle(
                            color: AppColor.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentNavigator extends StatelessWidget {
  const _DepartmentNavigator({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    final departments = controller.currentDepartments;
    if (departments.isEmpty && controller.departmentPath.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColor.backgroundcolor,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (controller.departmentPath.isNotEmpty)
                _SmallIconButton(
                  icon: Icons.keyboard_arrow_right_rounded,
                  onTap: controller.popDepartment,
                ),
              Expanded(
                child: Text(
                  controller.departmentPath.isEmpty
                      ? 'Ø£Ù‚Ø³Ø§Ù… Ø§Ù„Ù…ØªØ¬Ø±'
                      : controller.departmentPath.map((e) => e.name).join(' / '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (controller.selectedDepartmentId != null)
                TextButton(
                  onPressed: controller.clearFilters,
                  child: const Text('Ø§Ù„ÙƒÙ„'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, index) {
                final department = departments[index];
                final selected = department.id == controller.selectedDepartmentId;
                return _DepartmentTile(
                  department: department,
                  selected: selected,
                  onTap: () => controller.openDepartment(department),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: departments.length,
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
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Ù…Ù†ØªØ¬Ø§Øª Ø§Ù„Ù…ØªØ¬Ø±',
              style: TextStyle(
                color: AppColor.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '${controller.products.length} Ù†ØªÙŠØ¬Ø©',
            style: TextStyle(
              color: AppColor.greyText,
              fontWeight: FontWeight.w700,
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
    if (controller.productsStatus == StatusRequest.loading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const _ProductSkeleton(),
            childCount: 6,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
        ),
      );
    }

    if (controller.products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 56),
          child: Center(child: Text('Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ù†ØªØ¬Ø§Øª Ù…Ø·Ø§Ø¨Ù‚Ø© Ø­Ø§Ù„ÙŠØ§Ù‹')),
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.68,
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
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                BuyerNetworkImage(url: product.imageUrl),
                if (product.hasDiscount)
                  PositionedDirectional(
                    top: 9,
                    start: 9,
                    child: _DarkChip(label: 'Ø¹Ø±Ø¶'),
                  ),
                PositionedDirectional(
                  top: 9,
                  end: 9,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColor.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      product.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: product.isFavorite ? AppColor.error : AppColor.grey,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColor.warning, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    if (product.stock <= 0)
                      const Text(
                        'ØºÙŠØ± Ù…ØªÙˆÙØ±',
                        style: TextStyle(
                          color: AppColor.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (product.oldPrice != null)
                  Text(
                    '${formatPrice(product.oldPrice!)} Ù„.Ø³',
                    style: TextStyle(
                      color: AppColor.greyLight,
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  '${formatPrice(product.price)} Ù„.Ø³',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.controller});

  final BuyerStoreDetailController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.reviews.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ø¢Ø±Ø§Ø¡ Ø§Ù„Ù…Ø´ØªØ±ÙŠÙ†',
            style: TextStyle(
              color: AppColor.black,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.reviews.take(4).map((review) => _ReviewTile(review: review)),
        ],
      ),
    );
  }
}

void _showFilterSheet(
  BuildContext context,
  BuyerStoreDetailController controller,
) {
  final minCtrl = TextEditingController(text: controller.minPrice?.toString() ?? '');
  final maxCtrl = TextEditingController(text: controller.maxPrice?.toString() ?? '');
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
          decoration: const BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              const Text(
                'ÙÙ„ØªØ±Ø© Ù…Ù†ØªØ¬Ø§Øª Ø§Ù„Ù…ØªØ¬Ø±',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _PriceField(controller: minCtrl, hint: 'Ø£Ù‚Ù„ Ø³Ø¹Ø±')),
                  const SizedBox(width: 10),
                  Expanded(child: _PriceField(controller: maxCtrl, hint: 'Ø£Ø¹Ù„Ù‰ Ø³Ø¹Ø±')),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: {
                  'latest': 'Ø§Ù„Ø£Ø­Ø¯Ø«',
                  'price_asc': 'Ø§Ù„Ø£Ù‚Ù„ Ø³Ø¹Ø±Ø§Ù‹',
                  'price_desc': 'Ø§Ù„Ø£Ø¹Ù„Ù‰ Ø³Ø¹Ø±Ø§Ù‹',
                  'best_selling': 'Ø§Ù„Ø£ÙƒØ«Ø± Ù…Ø¨ÙŠØ¹Ø§Ù‹',
                  'rating': 'Ø§Ù„Ø£Ø¹Ù„Ù‰ ØªÙ‚ÙŠÙŠÙ…Ø§Ù‹',
                }.entries.map((entry) {
                  final selected = sort == entry.key;
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (_) => setState(() => sort = entry.key),
                    selectedColor: AppColor.primarySurface,
                    labelStyle: TextStyle(
                      color: selected ? AppColor.primaryColor : AppColor.black,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _SecondaryAction(
                      icon: Icons.refresh_rounded,
                      label: 'Ù…Ø³Ø­',
                      onTap: () {
                        Get.back();
                        controller.clearFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _PrimaryAction(
                      icon: Icons.check_rounded,
                      label: 'ØªØ·Ø¨ÙŠÙ‚',
                      onTap: () {
                        Get.back();
                        controller.applyFilters(
                          min: num.tryParse(minCtrl.text),
                          max: num.tryParse(maxCtrl.text),
                          sort: sort,
                        );
                      },
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

void _showReviewSheet(
  BuildContext context,
  BuyerStoreDetailController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GetBuilder<BuyerStoreDetailController>(
      tag: controller.storeId,
      builder: (ctrl) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            const Text(
              'Ù‚ÙŠÙ‘Ù… ØªØ¬Ø±Ø¨ØªÙƒ Ù…Ø¹ Ø§Ù„Ù…ØªØ¬Ø±',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(5, (index) {
                final value = index + 1.0;
                return IconButton(
                  onPressed: () {
                    ctrl.selectedRating = value;
                    ctrl.update();
                  },
                  icon: Icon(
                    ctrl.selectedRating >= value
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColor.warning,
                    size: 32,
                  ),
                );
              }),
            ),
            TextField(
              controller: ctrl.reviewController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Ø§ÙƒØªØ¨ ØªØ¹Ù„ÙŠÙ‚Ùƒ Ø¹Ù† Ø¬ÙˆØ¯Ø© Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª ÙˆØ§Ù„Ø®Ø¯Ù…Ø©',
                filled: true,
                fillColor: AppColor.secondBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _PrimaryAction(
              icon: Icons.send_rounded,
              label: 'Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„ØªÙ‚ÙŠÙŠÙ…',
              onTap: ctrl.submitReview,
            ),
          ],
        ),
      ),
    ),
  );
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FilterHeaderDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: AppColor.backgroundcolor,
      elevation: overlapsContent ? 2 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 126,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColor.primarySurface : AppColor.secondBackground,
          borderRadius: BorderRadius.circular(18),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.black,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            Text(
              department.hasChildren ? 'Ø§ÙØªØ­ Ø§Ù„ÙØ±ÙˆØ¹' : '${department.productsCount} Ù…Ù†ØªØ¬',
              style: TextStyle(
                color: AppColor.greyText,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
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
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.buyerName.isEmpty ? 'Ù…Ø´ØªØ±ÙŠ' : review.buyerName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const Icon(Icons.star_rounded, color: AppColor.warning, size: 16),
              Text(review.rating.toStringAsFixed(1)),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: TextStyle(color: AppColor.greyText, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColor.black.withOpacity(0.35),
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppColor.white, size: 20),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColor.primaryColor),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? AppColor.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColor.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColor.info),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.greyText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColor.mainGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.primaryShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColor.white, size: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColor.primarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.primaryColor.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColor.primaryColor, size: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColor.secondBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  const _DarkChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColor.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StoreLoading extends StatelessWidget {
  const _StoreLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SkeletonBox(height: 230, radius: 22),
        SizedBox(height: 14),
        _SkeletonBox(height: 96, radius: 18),
        SizedBox(height: 14),
        _SkeletonBox(height: 56, radius: 16),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _SkeletonBox(height: 220, radius: 18)),
            SizedBox(width: 12),
            Expanded(child: _SkeletonBox(height: 220, radius: 18)),
          ],
        ),
      ],
    );
  }
}

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonBox(height: double.infinity, radius: 18);
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
      decoration: BoxDecoration(
        color: AppColor.greyBorder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _StoreError extends StatelessWidget {
  const _StoreError({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 72, color: AppColor.greyLight),
            const SizedBox(height: 16),
            const Text(
              'ØªØ¹Ø°Ø± ØªØ­Ù…ÙŠÙ„ Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ù…ØªØ¬Ø±',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'ØªØ£ÙƒØ¯ Ù…Ù† Ø§Ù„Ø§ØªØµØ§Ù„ Ø£Ùˆ Ù…Ù† ØªÙˆÙØ± Ø§Ù„Ù…ØªØ¬Ø± ÙÙŠ Ø§Ù„Ø¨Ø§Ùƒ.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.greyText),
            ),
            const SizedBox(height: 18),
            _PrimaryAction(
              icon: Icons.refresh_rounded,
              label: 'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©',
              onTap: () {
                onRetry();
              },
            ),
          ],
        ),
      ),
    );
  }
}
