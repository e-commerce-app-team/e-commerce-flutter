import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_orders_controller.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/orders_models.dart';
import 'package:e_commerce/view/screen/seller/orders/order_detail_screen.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';
import 'package:e_commerce/view/widget/seller/orders/order_card.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerOrdersController());
    return GetBuilder<SellerOrdersController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: RefreshIndicator(
          onRefresh: ctrl.refreshOrders,
          color: AppColor.primaryColor,
          backgroundColor: Colors.white,
          displacement: 80,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _OrdersSliverAppBar(ctrl: ctrl),
              if (ctrl.statusRequest == StatusRequest.loading)
                const SliverFillRemaining(
                  child: _OrdersShimmer(),
                )
              else if (ctrl.searchResults.isEmpty)
                SliverFillRemaining(
                  child: _EmptyOrders(
                    hasSearch: ctrl.searchQuery.isNotEmpty,
                    isFiltered: ctrl.selectedTab != 0,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (_, i) => OrderCard(
                        order: ctrl.searchResults[i],
                        index: i,
                        onTap: () => Get.to(
                              () => const OrderDetailScreen(),
                          arguments: ctrl.searchResults[i],
                          transition: Transition.cupertino,
                        ),
                      ),
                      childCount: ctrl.searchResults.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersSliverAppBar extends StatelessWidget {
  final SellerOrdersController ctrl;
  const _OrdersSliverAppBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 108,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(gradient: AppColor.headerGradient),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    'orders_title'.tr,
                    style: AppTextStyle.appBarTitle
                        .copyWith(fontSize: 22),
                  ),
                  const Spacer(),
                  if (ctrl.pendingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.notifications_active_outlined,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${ctrl.pendingCount} ${'orders_new_badge'.tr}',
                            style: AppTextStyle.chip.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

      bottom: _OrdersAppBarBottom(ctrl: ctrl),
    );
  }
}

class _OrdersAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  final SellerOrdersController ctrl;
  const _OrdersAppBarBottom({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(104);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColor.headerGradient),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _SearchBar(ctrl: ctrl),
          ),
          _FilterTabs(ctrl: ctrl),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final SellerOrdersController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: ctrl.onSearch,
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyle.inputText.copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'orders_search_hint'.tr,
          hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 12),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColor.grey,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final SellerOrdersController ctrl;
  const _FilterTabs({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabData(labelKey: 'tab_all', count: null),
      _TabData(
        labelKey: 'tab_pending',
        count: ctrl.pendingCount,
        hasAlert: ctrl.pendingCount > 0,
      ),
      _TabData(labelKey: 'tab_processing', count: ctrl.processingCount),
      _TabData(labelKey: 'tab_shipped', count: ctrl.shippedCount),
      _TabData(labelKey: 'tab_delivered', count: ctrl.deliveredCount),
      _TabData(labelKey: 'tab_cancelled', count: null),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final isActive = ctrl.selectedTab == i;
          final tab = tabs[i];
          return GestureDetector(
            onTap: () => ctrl.changeTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.labelKey.tr,
                    style: AppTextStyle.chip.copyWith(
                      color: isActive
                          ? AppColor.primaryColor
                          : Colors.white,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (tab.count != null && tab.count! > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: tab.hasAlert
                            ? AppColor.primaryColor
                            : (isActive
                            ? AppColor.primaryColor
                            : Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tab.count}',
                        style: AppTextStyle.badge.copyWith(
                          fontSize: 9.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabData {
  final String labelKey;
  final int? count;
  final bool hasAlert;
  const _TabData({
    required this.labelKey,
    this.count,
    this.hasAlert = false,
  });
}

class _EmptyOrders extends StatelessWidget {
  final bool hasSearch;
  final bool isFiltered;

  const _EmptyOrders({
    required this.hasSearch,
    required this.isFiltered,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.shopping_cart_outlined,
                size: 34,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'orders_empty_search'.tr
                  : 'orders_empty_title'.tr,
              style:
              AppTextStyle.heading3.copyWith(color: AppColor.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'orders_empty_search_body'.tr
                  : 'orders_empty_body'.tr,
              style: AppTextStyle.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersShimmer extends StatelessWidget {
  const _OrdersShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 108,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 42, height: 42, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  ShimmerBox(width: 110, height: 12),
                  SizedBox(height: 7),
                  ShimmerBox(width: 150, height: 10),
                  SizedBox(height: 7),
                  ShimmerBox(width: 90, height: 9),
                  SizedBox(height: 10),
                  ShimmerBox(width: double.infinity, height: 8),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                ShimmerBox(width: 55, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 50, height: 22, radius: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}