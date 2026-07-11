import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/controller/buyer/explore_controller.dart';
import 'package:e_commerce/data/datasource/static/explore_mock_data.dart';
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
                onFilterTap: () => _openFilterSheet(context),
                onChanged: controller.onSearchChanged,
                onSubmitted: controller.submitSearch,
                onCancel: controller.closeSearch,
              ),
              if (!controller.isSearchFocused) ...[
                const SizedBox(height: 16),
                ExploreCategoryBar(
                  categories: ExploreMockData.categories,
                  selectedIndex: controller.selectedCategoryIndex,
                  onSelect: controller.selectCategory,
                ),
                if (controller.currentSubCategories.isNotEmpty)
                  ExploreSubCategoryBar(
                    subCategories: controller.currentSubCategories,
                    selectedId: controller.selectedSubCategoryId,
                    onSelect: controller.selectSubCategory,
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
                  isStoresTab: controller.isStoresTab,
                  resultCount: controller.resultCount,
                  onTabChanged: controller.switchTab,
                  onSortTap: () => _openSortSheet(context),
                ),
              ],
              Expanded(
                child: controller.isSearchFocused
                    ? ExploreSearchSuggestions(
                        recentSearches: controller.recentSearches,
                        suggestions: controller.suggestions,
                        onSelectSuggestion: controller.selectSuggestion,
                        onClearRecent: controller.clearRecentSearches,
                      )
                    : controller.isLoading
                        ? _buildLoadingState(controller.isStoresTab)
                        : controller.isStoresTab
                            ? _buildStoresList(controller)
                            : controller.products.isEmpty
                                ? _buildEmptyState(controller)
                                : _buildProductsGrid(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(ExploreController controller) {
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: controller.applyFilters,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        itemCount: controller.products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return ExploreProductCard(
            product: product,
            index: index,
            onTap: () {},
            onFavoriteTap: () => controller.toggleFavorite(product.id),
            onAddToCart: () {},
          );
        },
      ),
    );
  }

  Widget _buildStoresList(ExploreController controller) {
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: controller.applyFilters,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: controller.stores.length,
        itemBuilder: (context, index) {
          final store = controller.stores[index];
          return ExploreStoreCard(
            store: store,
            index: index,
            onTap: () {},
            onFollowTap: () {},
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
              decoration: const BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
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
                side: const BorderSide(color: AppColor.primaryColor),
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
        decoration: const BoxDecoration(
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
                      ? const Icon(Icons.check_circle_rounded, color: AppColor.primaryColor)
                      : const Icon(Icons.circle_outlined, color: AppColor.greyBorder),
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
