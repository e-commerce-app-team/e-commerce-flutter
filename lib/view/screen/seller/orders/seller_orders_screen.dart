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
        appBar: _OrdersAppBar(ctrl: ctrl),
        body: ctrl.statusRequest == StatusRequest.loading
            ? const _OrdersShimmer()
            : RefreshIndicator(
                onRefresh: ctrl.refreshOrders,
                color: AppColor.primaryColor,
                backgroundColor: Colors.white,
                child: ctrl.searchResults.isEmpty
                    ? _EmptyOrders(
                        hasSearch: ctrl.searchQuery.isNotEmpty)
                    : _OrdersList(ctrl: ctrl),
              ),
      ),
    );
  }
}


class _OrdersAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerOrdersController ctrl;
  const _OrdersAppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(150);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColor.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              Text('الطلبات', style: AppTextStyle.appBarTitle),
              const Spacer(),
              if (ctrl.pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_active_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${ctrl.pendingCount} جديد',
                        style: AppTextStyle.chip.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: _OrderSearchBar(ctrl: ctrl),
          ),

          _OrdersTabs(ctrl: ctrl),
        ]),
      ),
    );
  }
}

class _OrderSearchBar extends StatelessWidget {
  final SellerOrdersController ctrl;
  const _OrderSearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      onChanged: ctrl.onSearch,
      textAlignVertical: TextAlignVertical.center,
      style: AppTextStyle.inputText.copyWith(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'رقم الطلب أو اسم المشتري...',
        hintStyle: AppTextStyle.inputHint.copyWith(fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColor.grey, size: 18),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    ),
  );
}

class _OrdersTabs extends StatelessWidget {
  final SellerOrdersController ctrl;
  const _OrdersTabs({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _Tab(label: 'الكل',         count: null),
      _Tab(label: 'جديد',         count: ctrl.pendingCount,
          alert: ctrl.pendingCount > 0),
      _Tab(label: 'قيد التجهيز',  count: ctrl.processingCount),
      _Tab(label: 'تم الشحن',     count: ctrl.shippedCount),
      _Tab(label: 'مكتمل',        count: ctrl.deliveredCount),
      _Tab(label: 'ملغى',         count: null),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final isActive = ctrl.selectedTab == i;
          final t = tabs[i];
          return GestureDetector(
            onTap: () => ctrl.changeTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  t.label,
                  style: AppTextStyle.chip.copyWith(
                    color: isActive
                        ? AppColor.primaryColor : Colors.white,
                    fontWeight: isActive
                        ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11.5,
                  ),
                ),
                if (t.count != null && t.count! > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: t.alert
                          ? AppColor.primaryColor
                          : (isActive
                              ? AppColor.primaryColor
                              : Colors.white.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${t.count}',
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'PlayfairDisplay'),
                    ),
                  ),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _Tab {
  final String label;
  final int?   count;
  final bool   alert;
  const _Tab({required this.label, this.count, this.alert = false});
}

class _OrdersList extends StatelessWidget {
  final SellerOrdersController ctrl;
  const _OrdersList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final orders = ctrl.searchResults;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      itemCount: orders.length,
      itemBuilder: (_, i) => OrderCard(
        order: orders[i],
        index: i,
        onTap: () => Get.to(
          () => const OrderDetailScreen(),
          arguments: orders[i],
          transition: Transition.cupertino,
        ),
      ),
    );
  }
}


class _EmptyOrders extends StatelessWidget {
  final bool hasSearch;
  const _EmptyOrders({required this.hasSearch});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(
        hasSearch
            ? Icons.search_off_rounded
            : Icons.shopping_cart_outlined,
        size: 60, color: AppColor.greyLight,
      ),
      const SizedBox(height: 14),
      Text(
        hasSearch ? 'لا توجد نتائج' : 'لا توجد طلبات بعد',
        style: AppTextStyle.heading3.copyWith(color: AppColor.grey),
      ),
      const SizedBox(height: 6),
      Text(
        hasSearch
            ? 'جرّب البحث بكلمات مختلفة'
            : 'ستظهر الطلبات هنا عند وصولها',
        style: AppTextStyle.bodyMedium,
        textAlign: TextAlign.center,
      ),
    ]),
  );
}


class _OrdersShimmer extends StatelessWidget {
  const _OrdersShimmer();
  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    itemCount: 5,
    itemBuilder: (_, __) => Container(
      height: 88,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
      ),
      child: Row(children: [
        const ShimmerBox(width: 44, height: 44, radius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ShimmerBox(width: 100, height: 12),
              SizedBox(height: 7),
              ShimmerBox(width: 140, height: 10),
              SizedBox(height: 7),
              ShimmerBox(width: 80,  height: 9),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            ShimmerBox(width: 60, height: 14),
            SizedBox(height: 8),
            ShimmerBox(width: 50, height: 20, radius: 10),
          ],
        ),
      ]),
    ),
  );
}
