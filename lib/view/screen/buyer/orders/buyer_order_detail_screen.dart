import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/utils/buyer_format_utils.dart';
import 'package:e_commerce/controller/buyer/buyer_orders_controller.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';
import 'package:e_commerce/view/widget/buyer/orders/buyer_order_rating_sheet.dart';
import 'package:e_commerce/view/widget/buyer/orders/buyer_order_timeline.dart';
import 'package:e_commerce/view/widget/buyer/orders/buyer_return_request_sheet.dart';

class BuyerOrderDetailScreen extends StatelessWidget {
  const BuyerOrderDetailScreen({Key? key}) : super(key: key);

  BuyerOrderModel? _resolveOrder() {
    final arg = Get.arguments;
    final ctrl = Get.find<BuyerOrdersController>();
    if (arg is BuyerOrderModel) return arg;
    if (arg is String) return ctrl.findOrder(arg);
    return null;
  }

  Future<void> _confirmDelivery(BuildContext context, BuyerOrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('buyer_confirm_delivery_title'.tr, style: AppTextStyle.heading3),
        content: Text('buyer_confirm_delivery_body'.tr, style: AppTextStyle.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('confirm'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ctrl = Get.find<BuyerOrdersController>();
    final ok = await ctrl.confirmDelivery(order.id);
    if (!ok) return;

    final updated = ctrl.findOrder(order.id);
    if (updated != null && updated.canRate) {
      await BuyerOrderRatingSheet.show(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BuyerOrdersController>(
      builder: (ctrl) {
        final order = _resolveOrder();
        if (order == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppColor.primaryColor),
            body: Center(child: Text('buyer_order_not_found'.tr)),
          );
        }

        return Scaffold(
          backgroundColor: AppColor.secondBackground,
          appBar: AppBar(
            backgroundColor: AppColor.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            title: Column(
              children: [
                Text('#${order.orderNumber}', style: AppTextStyle.appBarTitle.copyWith(fontSize: 15)),
                Text(
                  _formatDate(order.createdAt),
                  style: AppTextStyle.timestamp.copyWith(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SummaryCard(order: order),
                    const SizedBox(height: 14),
                    _SectionCard(
                      icon: Icons.timeline_rounded,
                      title: 'section_order_timeline'.tr,
                      child: BuyerOrderTimeline(steps: order.effectiveTimeline),
                    ),
                    if (order.escrowAutoReleaseAt != null) ...[
                      const SizedBox(height: 14),
                      _EscrowNoteCard(releaseAt: order.escrowAutoReleaseAt!),
                    ],
                    const SizedBox(height: 14),
                    _SectionCard(
                      icon: Icons.storefront_outlined,
                      title: 'buyer_order_stores_section'.tr,
                      child: Column(
                        children: order.subOrders
                            .map((s) => BuyerSubOrderTile(subOrder: s))
                            .toList(),
                      ),
                    ),
                    if (order.returnRequest != null) ...[
                      const SizedBox(height: 14),
                      _ReturnTimelineCard(request: order.returnRequest!),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BottomActions(
            order: order,
            onConfirm: () => _confirmDelivery(context, order),
            onReport: () => BuyerReturnRequestSheet.show(order),
            onRate: () => BuyerOrderRatingSheet.show(order),
            onEscalate: () => ctrl.escalateReturn(order.id),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class _SummaryCard extends StatelessWidget {
  final BuyerOrderModel order;
  const _SummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColor.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuyerOrderStatusChip(status: order.status),
                const SizedBox(height: 8),
                Text(
                  '${formatBuyerPrice(order.totalAmount)} ${'currency'.tr}',
                  style: AppTextStyle.price.copyWith(fontSize: 18),
                ),
                if (order.paymentStatus != null)
                  Text(
                    '${'buyer_payment_status'.tr}: ${order.paymentStatus!}',
                    style: AppTextStyle.labelSmall.copyWith(color: AppColor.greyText),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EscrowNoteCard extends StatelessWidget {
  final DateTime releaseAt;
  const _EscrowNoteCard({required this.releaseAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColor.primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'buyer_escrow_auto_release'.trParams({
                'date': '${releaseAt.day}/${releaseAt.month}/${releaseAt.year}',
              }),
              style: AppTextStyle.bodySmall.copyWith(color: AppColor.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnTimelineCard extends StatelessWidget {
  final BuyerReturnRequest request;
  const _ReturnTimelineCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.assignment_return_outlined,
      title: 'buyer_return_timeline_title'.tr,
      child: BuyerOrderTimeline(
        steps: request.timeline.isNotEmpty
            ? request.timeline
            : [
                BuyerTimelineStep(
                  status: request.status.name,
                  title: request.status.name,
                  isDone: true,
                  isCurrent: true,
                ),
              ],
        compact: true,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColor.primaryColor),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyle.heading3.copyWith(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final BuyerOrderModel order;
  final VoidCallback onConfirm;
  final VoidCallback onReport;
  final VoidCallback onRate;
  final VoidCallback onEscalate;

  const _BottomActions({
    required this.order,
    required this.onConfirm,
    required this.onReport,
    required this.onRate,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColor.backgroundcolor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (order.canConfirmDelivery)
            _PrimaryBtn(
              label: 'buyer_confirm_delivery_btn'.tr,
              icon: Icons.check_circle_outline_rounded,
              onTap: onConfirm,
            ),
          if (order.canRate) ...[
            if (order.canConfirmDelivery) const SizedBox(height: 8),
            _PrimaryBtn(
              label: 'buyer_rate_order_btn'.tr,
              icon: Icons.star_outline_rounded,
              onTap: onRate,
            ),
          ],
          if (order.canReportProblem) ...[
            const SizedBox(height: 8),
            _OutlineBtn(
              label: 'buyer_report_problem'.tr,
              icon: Icons.report_problem_outlined,
              onTap: onReport,
            ),
          ],
          if (order.returnRequest?.status == BuyerReturnStatus.rejected) ...[
            const SizedBox(height: 8),
            _OutlineBtn(
              label: 'buyer_escalate_admin'.tr,
              icon: Icons.gavel_outlined,
              onTap: onEscalate,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: AppTextStyle.buttonMedium),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.error,
          side: BorderSide(color: AppColor.error.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
