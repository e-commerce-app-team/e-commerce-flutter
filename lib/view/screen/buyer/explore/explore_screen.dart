import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/controller/buyer/explore_controller.dart';
import 'package:e_commerce/view/widget/buyer/explore/explore_search_header.dart';
import 'package:e_commerce/view/widget/buyer/explore/explore_category_bar.dart';
import 'package:e_commerce/view/widget/buyer/explore/explore_toolbar.dart';
import 'package:e_commerce/view/widget/buyer/explore/explore_product_card.dart';
import 'package:e_commerce/view/widget/buyer/explore/explore_store_card.dart';
import 'package:e_commerce/view/widget/buyer/explore/explore_filter_sheet.dart';
import 'package:e_commerce/view/widget/buyer/explore/explore_search_suggestions.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  static const List<Map<String, String>> _sortOptions = [
    {'value': 'latest', 'label': 'sort_latest'},
    {'value': 'price_asc', 'label': 'sort_price_asc'},
    {'value': 'price_desc', 'label': 'sort_price_desc'},
    {'value': 'rating', 'label': 'sort_rating'},
    {'value': 'popular', 'label': 'sort_popular'},
    {'value': 'name', 'label': 'sort_name'},
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(ExploreController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: GetBuilder<ExploreController>(
          builder: (controller) => Column(
            children: [
              ExploreSearchHeader(
                searchController: controller.searchTextController,
                focusNode: controller.searchFocusNode,
                activeFilterCount: controller.activeFilterCount,
                isSearchFocused: controller.isSearchFocused,
                showSearchBar: controller.hasSelectedMode,
                onFilterTap: () => _openFilterSheet(context),
                onChanged: controller.onSearchChanged,
                onSubmitted: controller.submitSearch,
                onCancel: controller.closeSearch,
              ),
              if (!controller.hasSelectedMode)
                Expanded(child: _buildModeChooser(controller))
              else if (!controller.isSearchFocused) ...[
                const SizedBox(height: 16),
                ExploreCategoryBar(
                  categories: controller.categories,
                  selectedIndex: controller.selectedCategoryIndex,
                  onSelect: controller.selectCategory,
                ),
                if (controller.activeFilterChips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ExploreActiveFilterChips(
                    chips: controller.activeFilterChips,
                    onRemove: controller.removeFilterChip,
                    onClearAll: controller.resetFilters,
                  ),
                ],
                ExploreToolbar(
                  isStoresTab: controller.isStoresMode,
                  resultCount: controller.resultCount,
                  onTabChanged: controller.switchTab,
                  onSortTap: () => _openSortSheet(context),
                ),
              ],
              if (controller.hasSelectedMode)
                Expanded(
                  child: controller.isSearchFocused
                      ? ExploreSearchSuggestions(
                          recentSearches: controller.recentSearches,
                          suggestions: controller.suggestions,
                          onSelectSuggestion: controller.selectSuggestion,
                          onClearRecent: controller.clearRecentSearches,
                        )
                      : controller.isLoading
                          ? _buildLoadingState(controller.isStoresMode)
                          : controller.errorMessage != null
                              ? _buildErrorState(controller)
                              : controller.isStoresMode
                                  ? _buildStoreSections(controller)
                                  : _buildProductSections(controller),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeChooser(ExploreController controller) {
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: controller.refreshResults,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          Text(
            'explore_choose_title'.tr,
            style: AppTextStyle.heading1,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'explore_choose_body'.tr,
            style: AppTextStyle.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 22),
          _DiscoveryChoiceCard(
            icon: Icons.storefront_rounded,
            title: 'explore_choose_stores'.tr,
            body: 'explore_choose_stores_body'.tr,
            countLabel: 'explore_store_rows_hint'.tr,
            colors: const [Color(0xff0F766E), Color(0xff22C55E)],
            onTap: () => controller.chooseMode(ExploreMode.stores),
          ),
          const SizedBox(height: 14),
          _DiscoveryChoiceCard(
            icon: Icons.inventory_2_rounded,
            title: 'explore_choose_products'.tr,
            body: 'explore_choose_products_body'.tr,
            countLabel: 'explore_product_rows_hint'.tr,
            colors: const [Color(0xff7C2D12), Color(0xffF59E0B)],
            onTap: () => controller.chooseMode(ExploreMode.products),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSections(ExploreController controller) {
    if (controller.products.isEmpty) return _buildEmptyState(controller);
    final sections = controller.productSections;
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: controller.refreshResults,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          return _ResultSection(
                title: section.title,
            subtitle: '${section.items.length} ${'explore_products_count'.tr}',
            child: SizedBox(
              height: 286,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: section.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = section.items[index];
                  return SizedBox(
                    width: 174,
                    child: ExploreProductCard(
                      product: product,
                      index: index,
                      onTap: () => Get.toNamed(
                        AppRoute.buyerProductDetail,
                        arguments: {'product_id': product.id},
                      ),
                      onFavoriteTap: () => controller.toggleFavorite(product.id),
                      onAddToCart: () => controller.addToCart(product.id),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreSections(ExploreController controller) {
    if (controller.stores.isEmpty) return _buildEmptyState(controller);
    final sections = controller.storeSections;
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: controller.refreshResults,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          return _ResultSection(
            title: section.title,
            subtitle: '${section.items.length} ${'explore_tab_stores'.tr}',
            child: Column(
              children: List.generate(section.items.length, (index) {
                final store = section.items[index];
                return ExploreStoreCard(
                  store: store,
                  index: index,
                  onTap: () => Get.toNamed(
                    AppRoute.buyerStoreDetail,
                    arguments: {'store_id': store.id},
                  ),
                  onFollowTap: () => Get.toNamed(
                    AppRoute.buyerStoreDetail,
                    arguments: {'store_id': store.id},
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isStoresTab) {
    if (isStoresTab) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: 4,
        itemBuilder: (_, __) => const _StoreCardSkeleton(),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (_, __) => const _ProductCardSkeleton(),
    );
  }

  Widget _buildErrorState(ExploreController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: const BoxDecoration(
                color: AppColor.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: AppColor.error,
              ),
            ),
            const SizedBox(height: 18),
            Text('explore_error_title'.tr, style: AppTextStyle.heading2),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'explore_error_body'.tr,
              style: AppTextStyle.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: controller.refreshResults,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('retry'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ExploreController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 46,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'explore_empty_title'.tr,
              style: AppTextStyle.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'explore_empty_body'.tr,
              style: AppTextStyle.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: controller.resetFilters,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColor.primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'explore_clear_filters'.tr,
                style: AppTextStyle.buttonMedium.copyWith(color: AppColor.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExploreFilterSheet(),
    );
  }

  void _openSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColor.backgroundcolor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColor.greyBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('sort_by'.tr, style: AppTextStyle.heading2),
              ),
            ),
            const SizedBox(height: 8),
            ..._sortOptions.map(
              (option) => GetBuilder<ExploreController>(
                builder: (controller) => ListTile(
                  onTap: () {
                    controller.setSortBy(option['value']!);
                    Navigator.pop(context);
                  },
                  title: Text(option['label']!.tr, style: AppTextStyle.bodyLarge),
                  trailing: controller.sortBy == option['value']
                      ? Icon(Icons.check_circle_rounded, color: AppColor.primaryColor)
                      : Icon(Icons.circle_outlined, color: AppColor.greyBorder),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String countLabel;
  final List<Color> colors;
  final VoidCallback onTap;

  const _DiscoveryChoiceCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.countLabel,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColor.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.heading2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodySmall.copyWith(color: Colors.white.withOpacity(0.86)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      countLabel,
                      style: AppTextStyle.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ResultSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.heading3,
                ),
              ),
              Text(subtitle, style: AppTextStyle.labelSmall),
            ],
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _ProductCardSkeleton extends StatefulWidget {
  const _ProductCardSkeleton();

  @override
  State<_ProductCardSkeleton> createState() => _ProductCardSkeletonState();
}

class _ProductCardSkeletonState extends State<_ProductCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColor.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: Container(color: AppColor.secondBackground),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bone(width: 60, height: 9),
                  const SizedBox(height: 8),
                  _bone(width: double.infinity, height: 12),
                  const SizedBox(height: 6),
                  _bone(width: 90, height: 12),
                  const SizedBox(height: 10),
                  _bone(width: 70, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bone({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _StoreCardSkeleton extends StatefulWidget {
  const _StoreCardSkeleton();

  @override
  State<_StoreCardSkeleton> createState() => _StoreCardSkeletonState();
}

class _StoreCardSkeletonState extends State<_StoreCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
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
                color: AppColor.secondBackground,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 14, color: AppColor.secondBackground),
                  const SizedBox(height: 8),
                  Container(width: 80, height: 10, color: AppColor.secondBackground),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 10, color: AppColor.secondBackground),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
