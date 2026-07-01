import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_coupons_controller.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/imgaeasset.dart';
import 'package:e_commerce/data/model/seller/coupon_models.dart';
import 'package:e_commerce/view/screen/seller/dashboard/drawer/seller_coupon_form_sheet.dart';
import 'package:e_commerce/view/widget/seller/empty_state_widget.dart';
import 'package:e_commerce/view/widget/seller/loading_state_widget.dart';
import 'package:e_commerce/core/class/status_request.dart';

class SellerCouponsScreen extends StatelessWidget {
  const SellerCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerCouponsController>(
      init: SellerCouponsController(),
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.backgroundScaffold,
        body: ctrl.statusRequest == StatusRequest.loading
            ? const LoadingStateWidget()
            : RefreshIndicator(
                color: AppColor.primaryColor,
                onRefresh: ctrl.refreshCoupons,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(ctrl),
                    SliverToBoxAdapter(child: _buildStatsRow(ctrl)),
                    SliverToBoxAdapter(child: _buildTabsRow(ctrl)),
                    ctrl.displayedCoupons.isEmpty
                        ? SliverFillRemaining(
                            child: EmptyStateWidget(
                              icon: AppImageAsset.emptyCoupons,
                              title: 'no_coupons'.tr,
                              subtitle: 'no_coupons_sub'.tr,
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _CouponCard(
                                    coupon: ctrl.displayedCoupons[i],
                                    ctrl: ctrl,
                                  ),
                                ),
                                childCount: ctrl.displayedCoupons.length,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
        floatingActionButton: _buildFab(ctrl),
      ),
    );
  }

  Widget _buildAppBar(SellerCouponsController ctrl) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      stretch: true,
      backgroundColor: AppColor.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColor.primaryColor, AppColor.primaryDark],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30, left: -30,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -20, right: 60,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('coupons'.tr,
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  )),
              Text('coupons_sub'.tr,
                  style: TextStyle(
                    color: AppColor.white.withOpacity(0.75),
                    fontSize: 11,
                  )),
            ],
          ),
        ),
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 14),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.white, size: 20),
        onPressed: Get.back,
      ),
    );
  }

  Widget _buildStatsRow(SellerCouponsController ctrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          _StatChip(label: 'stat_all'.tr,     value: ctrl.totalCount,   color: AppColor.primaryColor),
          const SizedBox(width: 8),
          _StatChip(label: 'stat_active'.tr,  value: ctrl.activeCount,  color: AppColor.success),
          const SizedBox(width: 8),
          _StatChip(label: 'stat_expired'.tr, value: ctrl.expiredCount, color: AppColor.greyLight),
          const SizedBox(width: 8),
          _StatChip(label: 'stat_paused'.tr,  value: ctrl.pausedCount,  color: AppColor.warning),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(Icons.touch_app_rounded, size: 13, color: AppColor.primaryColor),
              const SizedBox(width: 4),
              Text('${ctrl.totalUsage}x', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColor.primaryColor)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsRow(SellerCouponsController ctrl) {
    const tabs = ['tab_all', 'tab_active', 'tab_expired', 'tab_paused'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColor.shadow, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = ctrl.selectedTabIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => ctrl.changeTab(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: active ? AppColor.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[i].tr,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColor.white : AppColor.greyText,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFab(SellerCouponsController ctrl) {
    return FloatingActionButton.extended(
      onPressed: () {
        ctrl.prepareAddForm();
        showCouponFormSheet(ctrl);
      },
      backgroundColor: AppColor.primaryColor,
      icon: Icon(Icons.add_rounded, color: AppColor.white),
      label: Text('add_coupon'.tr,
          style: TextStyle(color: AppColor.white, fontWeight: FontWeight.w700)),
      elevation: 4,
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
      ]),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final SellerCouponsController ctrl;
  const _CouponCard({required this.coupon, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColor.shadow, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(coupon: coupon, ctrl: ctrl),
            _CardBody(coupon: coupon, ctrl: ctrl),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final CouponModel coupon;
  final SellerCouponsController ctrl;
  const _CardHeader({required this.coupon, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: coupon.typeColor.withOpacity(0.07),
        border: Border(bottom: BorderSide(color: coupon.typeColor.withOpacity(0.15), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: coupon.typeLightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon(coupon.type), color: coupon.typeColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(coupon.code,
                      style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColor.textPrimary,
                          letterSpacing: 1.2)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => ctrl.copyCode(coupon.code),
                    child: Icon(Icons.copy_rounded, size: 14, color: AppColor.greyText),
                  ),
                ]),
                const SizedBox(height: 2),
                Text(_typeLabel(coupon),
                    style: TextStyle(fontSize: 11, color: coupon.typeColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _StatusBadge(coupon: coupon),
            const SizedBox(height: 4),
            if (!coupon.isExpired)
              GestureDetector(
                onTap: () => ctrl.toggleStatus(coupon),
                child: Icon(
                  coupon.isActive ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                  color: coupon.isActive ? AppColor.warning : AppColor.success,
                  size: 22,
                ),
              ),
          ]),
        ],
      ),
    );
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'fixed':         return Icons.attach_money_rounded;
      case 'free_shipping': return Icons.local_shipping_rounded;
      default:              return Icons.percent_rounded;
    }
  }

  String _typeLabel(CouponModel c) {
    switch (c.type) {
      case 'fixed':         return '${'discount_fixed'.tr} ${c.value.toInt()} ${'currency'.tr}';
      case 'free_shipping': return 'free_shipping'.tr;
      default:              return '${'discount_pct'.tr} ${c.value.toInt()}%';
    }
  }
}

class _CardBody extends StatelessWidget {
  final CouponModel coupon;
  final SellerCouponsController ctrl;
  const _CardBody({required this.coupon, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          if (coupon.maxUsage != null) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('usage_count'.tr, style: TextStyle(fontSize: 11.5, color: AppColor.greyText)),
              Text('${coupon.usedCount} / ${coupon.maxUsage}',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColor.textPrimary)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: coupon.usageProgress,
                minHeight: 5,
                backgroundColor: AppColor.greyBorder,
                valueColor: AlwaysStoppedAnimation(
                    coupon.isFullyUsed ? AppColor.danger : coupon.typeColor),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(children: [
            _InfoPill(icon: Icons.calendar_today_rounded,
                label: '${ctrl.formatDate(coupon.startDate)} — ${ctrl.formatDate(coupon.endDate)}',
                color: AppColor.greyText),
          ]),
          if (coupon.minOrderAmount > 0) ...[
            const SizedBox(height: 6),
            Row(children: [
              _InfoPill(icon: Icons.shopping_cart_outlined,
                  label: '${'min_order'.tr} ${coupon.minOrderAmount} ${'currency'.tr}',
                  color: AppColor.greyText),
            ]),
          ],
          if (coupon.appliesTo == 'category' && coupon.categoryName != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              _InfoPill(icon: Icons.category_rounded,
                  label: coupon.categoryName!,
                  color: AppColor.primaryColor),
            ]),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _ActionBtn(
                label: 'edit'.tr,
                icon: Icons.edit_rounded,
                color: AppColor.primaryColor,
                onTap: () {
                  ctrl.prepareEditForm(coupon);
                  showCouponFormSheet(ctrl);
                },
              ),
            ),
            const SizedBox(width: 8),
            _ActionBtn(
              label: '',
              icon: Icons.delete_outline_rounded,
              color: AppColor.danger,
              onTap: () => _confirmDelete(context, coupon),
              compact: true,
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CouponModel coupon) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_coupon'.tr, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('${'delete_coupon_confirm'.tr} "${coupon.code}"؟'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.danger),
            onPressed: () => Get.back(result: true),
            child: Text('delete'.tr, style: TextStyle(color: AppColor.white)),
          ),
        ],
      ),
    );
    if (ok == true) ctrl.deleteCoupon(coupon);
  }
}

class _StatusBadge extends StatelessWidget {
  final CouponModel coupon;
  const _StatusBadge({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final label = coupon.isActive ? 'active'.tr : coupon.isExpired ? 'expired'.tr : 'paused'.tr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: coupon.statusLightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: coupon.statusColor)),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11.5, color: color)),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool compact;
  const _ActionBtn({
    required this.label, required this.icon,
    required this.color, required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14, vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 15, color: color),
          if (!compact) ...[const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color))],
        ]),
      ),
    );
  }
}
