import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_dashboard_controller.dart';
import 'package:e_commerce/controller/seller/seller_main_controller.dart';
import 'package:e_commerce/core/class/handling_dataview.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/dashboard_models.dart';
import 'package:e_commerce/view/widget/seller/dashboard/dashboard_app_bar.dart';
import 'package:e_commerce/view/widget/seller/dashboard/quick_actions_row.dart';
import 'package:e_commerce/view/widget/seller/dashboard/recent_order_card.dart';
import 'package:e_commerce/view/widget/seller/dashboard/sales_chart_widget.dart';
import 'package:e_commerce/view/widget/seller/dashboard/shimmer_box.dart';
import 'package:e_commerce/view/widget/seller/dashboard/stats_card.dart';

import '../../../widget/seller/seller_drawer.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SellerDashboardController());

    return GetBuilder<SellerDashboardController>(
      builder: (ctrl) {
        final mainCtrl = Get.find<SellerMainController>();

        return Scaffold(
          backgroundColor: AppColor.secondBackground,
          drawer: const SellerDrawer(),

          appBar: DashboardAppBar(
            greeting:          ctrl.greeting,
            storeName:         mainCtrl.sellerName,
            rating:            4.8,
            reviewCount:       312,
            onNotificationTap: () {
              // TODO: Get.toNamed(AppRoute.notifications)
            },
            notificationCount: mainCtrl.newOrdersCount,
          ),

          body: ctrl.statusRequest == StatusRequest.loading
              ? const DashboardShimmer()
              : ctrl.statusRequest == StatusRequest.offlinefailure ||
              ctrl.statusRequest == StatusRequest.serverfailure
              ? HandlingDataView(
            statusRequest: ctrl.statusRequest,
            widget: const SizedBox.shrink(),
          )
              : _DashboardBody(ctrl: ctrl, mainCtrl: mainCtrl),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final SellerDashboardController ctrl;
  final SellerMainController mainCtrl;

  const _DashboardBody({
    required this.ctrl,
    required this.mainCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: ctrl.loadDashboard,
      color: AppColor.primaryColor,
      backgroundColor: Colors.white,
      displacement: 20,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'overview'.tr,
                        style: AppTextStyle.heading3,
                      ),
                      PeriodSelector(
                        selected :  ctrl.selectedPeriod,
                        onChanged: ctrl.changePeriod,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (ctrl.stats != null)
                    _StatsGrid(stats: ctrl.stats!),

                  const SizedBox(height: 16),

                  const QuickActionsRow(),
                  const SizedBox(height: 16),

                  if (ctrl.chartData != null)
                    SalesChartWidget(
                      data:         ctrl.chartData!,
                      totalRevenue: ctrl.chartData!.totalRevenue,
                    ),
                  const SizedBox(height: 16),

                  SectionHeader(
                    title:       'recent_orders'.tr,
                    actionLabel: 'see_all'.tr,
                    onAction:    () => mainCtrl.changeTab(2),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          ctrl.recentOrders.isEmpty
              ? SliverToBoxAdapter(
            child: _EmptyOrders(),
          )
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final order = ctrl.recentOrders[index];
                  return Column(
                    children: [
                      RecentOrderCard(
                        order: order,
                        index: index,
                        onAccept: order.status == 'pending'
                            ? () => ctrl.acceptOrder(order.subOrderId)
                            : null,
                        onReject: order.status == 'pending'
                            ? () => ctrl.rejectOrder(order.subOrderId)
                            : null,
                      ),
                      if (order.status == 'pending')
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft:  Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                              boxShadow: AppColor.cardShadow,
                              border: Border.all(
                                color: AppColor.primaryColor
                                    .withOpacity(0.15),
                              ),
                            ),
                            child: OrderActionButtons(
                              onAccept: () =>
                                  ctrl.acceptOrder(order.subOrderId),
                              onReject: () =>
                                  ctrl.rejectOrder(order.subOrderId),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                childCount: ctrl.recentOrders.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardStatsModel stats;
  const _StatsGrid({required this.stats});

  String _formatVal(int val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}م';
    if (val >= 1000)    return '${(val / 1000).toStringAsFixed(0)}k';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount:  2,
      crossAxisSpacing: 10,
      mainAxisSpacing:  10,
      childAspectRatio: 1.25,
      children: [
        StatsCard(
          label:          'total_revenue'.tr,
          value:          'SP ${_formatVal(stats.revenue)}',
          change:         stats.revenueChange,
          period:         'vs_yesterday'.tr,
          icon:           Icons.account_balance_wallet_outlined,
          accentColor:    AppColor.statRevenue,
          accentLight:    AppColor.statRevenueLight,
          animationDelay: 0,
        ),
        StatsCard(
          label:          'new_orders'.tr,
          value:          stats.ordersNew.toString(),
          change:         stats.revenueChange,
          period:         'vs_yesterday'.tr,
          icon:           Icons.shopping_cart_outlined,
          accentColor:    AppColor.statOrders,
          accentLight:    AppColor.statOrdersLight,
          animationDelay: 80,
        ),
        StatsCard(
          label:          'store_views'.tr,
          value:          _formatVal(stats.storeViews),
          change:         stats.viewsChange,
          period:         'vs_yesterday'.tr,
          icon:           Icons.remove_red_eye_outlined,
          accentColor:    AppColor.statViews,
          accentLight:    AppColor.statViewsLight,
          animationDelay: 160,
        ),
        StatsCard(
          label:          'inventory_value'.tr,
          value:          'SP ${_formatVal(stats.avgOrderValue)}',
          change:         12.0,
          period:         'vs_last_week'.tr,
          icon:           Icons.trending_up_rounded,
          accentColor:    AppColor.statAvg,
          accentLight:    AppColor.statAvgLight,
          animationDelay: 240,
        ),
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 52,
            color: AppColor.greyLight,
          ),
          const SizedBox(height: 12),
          Text(
            'no_orders_yet'.tr,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColor.greyLight,
            ),
          ),
        ],
      ),
    );
  }
}