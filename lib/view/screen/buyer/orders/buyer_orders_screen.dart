// lib/view/screen/buyer/orders/buyer_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/controller/buyer/buyer_orders_controller.dart';
import 'package:e_commerce/view/widget/buyer/orders/buyer_order_card.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: GetBuilder<BuyerOrdersController>(
          init: BuyerOrdersController(),
          builder: (ctrl) => RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: ctrl.refresh,
            child: CustomScrollView(
              // AlwaysScrollable ensures RefreshIndicator fires even when the
              // list is too short to scroll naturally.
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _BuyerOrdersSliverAppBar(
                  selectedTabIndex: ctrl.selectedTabIndex,
                  onTabSelected: ctrl.changeTab,
                ),
                if (ctrl.filteredOrders.isEmpty)
                  const _EmptyOrders()
                else
                  _OrdersSliverList(
                    controller: ctrl,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sliver App Bar ───────────────────────────────────────────────────────────

class _BuyerOrdersSliverAppBar extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;

  const _BuyerOrdersSliverAppBar({
    required this.selectedTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      // AppColor.primaryColor shows through the tab-bar area below the
      // flexibleSpace gradient — both are orange, so the header reads as one
      // unified band.
      backgroundColor: AppColor.primaryColor,
      flexibleSpace: const FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(gradient: AppColor.headerGradient),
        ),
      ),
      title: Text(
        // TODO: TRANSLATIONS — 'my_orders_title' → ar: 'طلباتي'  en: 'My Orders'
        'my_orders_title'.tr,
        style: AppTextStyle.appBarTitle,
      ),
      centerTitle: false,
      bottom: _OrderTabsBar(
        selectedIndex: selectedTabIndex,
        onSelect: onTabSelected,
      ),
    );
  }
}

// ─── Tab filter bar ───────────────────────────────────────────────────────────

/// Horizontal chip-style tab bar embedded in [SliverAppBar.bottom].
/// Index order MUST stay in sync with [BuyerOrdersController.tabStatusFilters].
class _OrderTabsBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const List<String> _tabKeys = [
    'tab_all',
    'buyer_tab_pending',  // TODO: TRANSLATIONS — ar: 'قيد الانتظار'  en: 'Pending'
    'tab_processing',
    'tab_shipped',
    'tab_delivered',
    'tab_cancelled',
  ];

  const _OrderTabsBar({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        itemCount: _tabKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
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
                _tabKeys[i].tr,
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

// ─── Orders list ──────────────────────────────────────────────────────────────

class _OrdersSliverList extends StatelessWidget {
  final BuyerOrdersController controller;

  const _OrdersSliverList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final order = controller.filteredOrders[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: BuyerOrderCard(
                order: order,
                onTap: () {
                  // TODO: Get.toNamed(AppRoute.buyerOrderDetails, arguments: order)
                },
                onCancelTap: () => controller.cancelOrder(order.id),
                onTrackTap: () {
                  // TODO: Get.toNamed(AppRoute.buyerOrderTracking, arguments: order)
                },
                onReorderTap: () => controller.reorder(order.id),
              ),
            );
          },
          childCount: controller.filteredOrders.length,
        ),
      ),
    );
  }
}

// ─── Loading shimmer ──────────────────────────────────────────────────────────

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

/// Animated pulsing skeleton that mirrors the real [BuyerOrderCard] shape.
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
    _opacity = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(w: 46, h: 46, r: 23), // status icon
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _bone(w: 120, h: 14),
                          const Spacer(),
                          _bone(w: 66, h: 22, r: 11),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _bone(w: 150, h: 11),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _bone(w: 90, h: 14),
                          const Spacer(),
                          _bone(w: 72, h: 11),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColor.greyBorder),
            const SizedBox(height: 12),
            // Items row
            _bone(w: double.infinity, h: 11),
            const SizedBox(height: 10),
            // Action button
            _bone(w: double.infinity, h: 40, r: 12),
          ],
        ),
      ),
    );
  }

  Widget _bone({required double w, required double h, double r = 6}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

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
                decoration: const BoxDecoration(
                  color: AppColor.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 50,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                // TODO: TRANSLATIONS — 'buyer_orders_empty_title'
                //   ar: 'لا توجد طلبات بعد'  en: 'No orders yet'
                'buyer_orders_empty_title'.tr,
                style: AppTextStyle.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                // TODO: TRANSLATIONS — 'buyer_orders_empty_body'
                //   ar: 'ستظهر طلباتك هنا عند إتمام أول عملية شراء'
                //   en: 'Your orders will appear here after your first purchase'
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

