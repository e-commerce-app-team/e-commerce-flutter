import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/controller/buyer/buyer_orders_controller.dart';
import 'package:e_commerce/view/widget/buyer/orders/buyer_order_card.dart';
import 'package:e_commerce/view/widget/buyer/orders/buyer_orders_filter_sheet.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({Key? key}) : super(key: key);

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BuyerOrdersFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: GetBuilder<BuyerOrdersController>(
          builder: (ctrl) => RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: ctrl.refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _BuyerOrdersSliverAppBar(
                  selectedTabIndex: ctrl.selectedTabIndex,
                  filterCount: ctrl.activeFilterCount,
                  onTabSelected: ctrl.changeTab,
                  onFilterTap: () => _openFilterSheet(context),
                ),
                if (ctrl.isLoading)
                  const _OrdersShimmer()
                else if (ctrl.loadError != null)
                  _OrdersError(onRetry: ctrl.refresh, message: ctrl.loadError!)
                else if (ctrl.filteredOrders.isEmpty)
                  const _EmptyOrders()
                else
                  _OrdersSliverList(controller: ctrl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BuyerOrdersSliverAppBar extends StatelessWidget {
  final int selectedTabIndex;
  final int filterCount;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onFilterTap;

  const _BuyerOrdersSliverAppBar({
    required this.selectedTabIndex,
    required this.filterCount,
    required this.onTabSelected,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColor.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(gradient: AppColor.headerGradient),
        ),
      ),
      title: Text('my_orders_title'.tr, style: AppTextStyle.appBarTitle),
      centerTitle: false,
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onFilterTap,
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
              tooltip: 'buyer_orders_filter_title'.tr,
            ),
            if (filterCount > 0)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$filterCount',
                    style: AppTextStyle.badge.copyWith(
                      color: AppColor.primaryColor,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
      bottom: _OrderTabsBar(
        selectedIndex: selectedTabIndex,
        onSelect: onTabSelected,
      ),
    );
  }
}

class _OrderTabsBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _OrderTabsBar({required this.selectedIndex, required this.onSelect});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        itemCount: BuyerOrdersController.tabLabelKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? Colors.white.withOpacity(0.75)
                      : Colors.white.withOpacity(0.38),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                BuyerOrdersController.tabLabelKeys[i].tr,
                style: AppTextStyle.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrdersSliverList extends StatelessWidget {
  final BuyerOrdersController controller;

  const _OrdersSliverList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, i) {
          final order = controller.filteredOrders[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: BuyerOrderCard(
              order: order,
              onTap: () =>
                  Get.toNamed(AppRoute.buyerOrderDetail, arguments: order.id),
              onTrackTap: () =>
                  Get.toNamed(AppRoute.buyerOrderDetail, arguments: order.id),
            ),
          );
        }, childCount: controller.filteredOrders.length),
      ),
    );
  }
}

class _OrdersShimmer extends StatelessWidget {
  const _OrdersShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: _OrderCardSkeleton(),
        ),
      ),
    );
  }
}

class _OrderCardSkeleton extends StatefulWidget {
  const _OrderCardSkeleton();

  @override
  State<_OrderCardSkeleton> createState() => _OrderCardSkeletonState();
}

class _OrderCardSkeletonState extends State<_OrderCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColor.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColor.secondBackground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColor.secondBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 11,
                    width: 160,
                    decoration: BoxDecoration(
                      color: AppColor.secondBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 12,
                    width: 90,
                    decoration: BoxDecoration(
                      color: AppColor.secondBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 50,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'buyer_orders_empty_title'.tr,
                style: AppTextStyle.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'buyer_orders_empty_body'.tr,
                style: AppTextStyle.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersError extends StatelessWidget {
  final Future<void> Function() onRetry;
  final String message;

  const _OrdersError({required this.onRetry, required this.message});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 58,
                color: AppColor.error,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium,
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => onRetry(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text('retry'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
