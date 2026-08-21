import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/utils/buyer_format_utils.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';
import 'package:e_commerce/view/widget/buyer/orders/buyer_order_timeline.dart';

class BuyerOrderCard extends StatefulWidget {
  final BuyerOrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onTrackTap;

  const BuyerOrderCard({
    Key? key,
    required this.order,
    this.onTap,
    this.onTrackTap,
  }) : super(key: key);

  @override
  State<BuyerOrderCard> createState() => _BuyerOrderCardState();
}

class _BuyerOrderCardState extends State<BuyerOrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColor.cardShadow,
              border: Border.all(color: AppColor.greyBorder.withOpacity(0.35)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusIconCircle(status: order.status),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '#${order.orderNumber}',
                                    style: AppTextStyle.orderNumber,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _OrderStatusChip(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (order.subOrders.length == 1)
                              Text(
                                order.primaryStoreName,
                                style: AppTextStyle.bodyMedium.copyWith(
                                  color: AppColor.greyText,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            else
                              Text(
                                'buyer_orders_multi_stores'.trParams({
                                  'count': '${order.subOrders.length}',
                                }),
                                style: AppTextStyle.bodySmall.copyWith(
                                  color: AppColor.greyText,
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  '${formatBuyerPrice(order.totalAmount)} ${'currency'.tr}',
                                  style: AppTextStyle.price,
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 13,
                                  color: AppColor.grey.withOpacity(0.9),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(order.createdAt),
                                  style: AppTextStyle.timestamp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.subOrders.isNotEmpty) ...[
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 14,
                    endIndent: 14,
                    color: AppColor.greyBorder,
                  ),
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 15,
                            color: AppColor.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${order.itemsCount} ${'order_items_count'.tr}',
                              style: AppTextStyle.bodySmall,
                            ),
                          ),
                          Text(
                            _expanded
                                ? 'buyer_hide_details'.tr
                                : 'buyer_show_details'.tr,
                            style: AppTextStyle.labelSmall.copyWith(
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 220),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColor.primaryColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Column(
                        children: order.subOrders
                            .map((s) => _SubOrderTile(subOrder: s))
                            .toList(),
                      ),
                    ),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                  ),
                ],
                if (order.status == BuyerOrderStatus.shipped &&
                    widget.onTrackTap != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: _ActionButton.filled(
                      label: 'track_order'.tr,
                      icon: Icons.local_shipping_outlined,
                      onTap: widget.onTrackTap,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class _StatusIconCircle extends StatelessWidget {
  final BuyerOrderStatus status;
  const _StatusIconCircle({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: _bgColor, shape: BoxShape.circle),
      child: Icon(_icon, size: 22, color: _fgColor),
    );
  }

  Color get _bgColor {
    switch (status) {
      case BuyerOrderStatus.pending:
        return AppColor.pendingBg;
      case BuyerOrderStatus.processing:
        return AppColor.processingBg;
      case BuyerOrderStatus.shipped:
        return AppColor.shippedBg;
      case BuyerOrderStatus.delivered:
        return AppColor.deliveredBg;
      case BuyerOrderStatus.cancelled:
      case BuyerOrderStatus.cancelledReturned:
        return AppColor.cancelledBg;
      case BuyerOrderStatus.returned:
        return AppColor.returnedBg;
    }
  }

  Color get _fgColor {
    switch (status) {
      case BuyerOrderStatus.pending:
        return AppColor.pendingText;
      case BuyerOrderStatus.processing:
        return AppColor.processingText;
      case BuyerOrderStatus.shipped:
        return AppColor.shippedText;
      case BuyerOrderStatus.delivered:
        return AppColor.deliveredText;
      case BuyerOrderStatus.cancelled:
      case BuyerOrderStatus.cancelledReturned:
        return AppColor.cancelledText;
      case BuyerOrderStatus.returned:
        return AppColor.returnedText;
    }
  }

  IconData get _icon {
    switch (status) {
      case BuyerOrderStatus.pending:
        return Icons.schedule_rounded;
      case BuyerOrderStatus.processing:
        return Icons.inventory_2_outlined;
      case BuyerOrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case BuyerOrderStatus.delivered:
        return Icons.check_circle_outline_rounded;
      case BuyerOrderStatus.cancelled:
      case BuyerOrderStatus.cancelledReturned:
        return Icons.cancel_outlined;
      case BuyerOrderStatus.returned:
        return Icons.assignment_return_outlined;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton.filled({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColor.mainGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColor.primaryShadow,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColor.backgroundcolor),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyle.buttonSmall),
          ],
        ),
      ),
    );
  }
}

class _SubOrderTile extends StatelessWidget {
  final BuyerSubOrderModel subOrder;

  const _SubOrderTile({required this.subOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subOrder.storeName,
            style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 15,
                color: AppColor.primaryColor,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  subOrder.shippingCost == null
                      ? 'بانتظار تحديد تكلفة الشحن من التاجر'
                      : '${subOrder.shippingLabel ?? 'الشحن'}: ${formatBuyerPrice(subOrder.shippingCost!)}',
                  style: AppTextStyle.labelSmall.copyWith(
                    color: subOrder.shippingCost == null
                        ? AppColor.info
                        : AppColor.greyText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subOrder.items.length,
            itemBuilder: (_, i) {
              final item = subOrder.items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} x${item.quantity}',
                        style: AppTextStyle.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${formatBuyerPrice(item.price)}',
                      style: AppTextStyle.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  final BuyerOrderStatus status;

  const _OrderStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _labelKey.tr,
        style: AppTextStyle.labelSmall.copyWith(
          color: _fgColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color get _bgColor {
    switch (status) {
      case BuyerOrderStatus.pending:
        return AppColor.pendingBg;
      case BuyerOrderStatus.processing:
        return AppColor.processingBg;
      case BuyerOrderStatus.shipped:
        return AppColor.shippedBg;
      case BuyerOrderStatus.delivered:
        return AppColor.deliveredBg;
      case BuyerOrderStatus.cancelled:
      case BuyerOrderStatus.cancelledReturned:
        return AppColor.cancelledBg;
      case BuyerOrderStatus.returned:
        return AppColor.returnedBg;
    }
  }

  Color get _fgColor {
    switch (status) {
      case BuyerOrderStatus.pending:
        return AppColor.pendingText;
      case BuyerOrderStatus.processing:
        return AppColor.processingText;
      case BuyerOrderStatus.shipped:
        return AppColor.shippedText;
      case BuyerOrderStatus.delivered:
        return AppColor.deliveredText;
      case BuyerOrderStatus.cancelled:
      case BuyerOrderStatus.cancelledReturned:
        return AppColor.cancelledText;
      case BuyerOrderStatus.returned:
        return AppColor.returnedText;
    }
  }

  String get _labelKey {
    switch (status) {
      case BuyerOrderStatus.pending:
        return 'status_pending';
      case BuyerOrderStatus.processing:
        return 'status_processing';
      case BuyerOrderStatus.shipped:
        return 'status_shipped';
      case BuyerOrderStatus.delivered:
        return 'status_delivered';
      case BuyerOrderStatus.cancelled:
      case BuyerOrderStatus.cancelledReturned:
        return 'status_cancelled';
      case BuyerOrderStatus.returned:
        return 'status_returned';
    }
  }
}
