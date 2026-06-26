import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_orders_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/orders_models.dart';

class OrderCard extends StatefulWidget {
  final SubOrderModel order;
  final int index;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.index,
    required this.onTap,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final config = OrderStatusConfig.of(order.status);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColor.cardShadow,
              border: Border(
                right: BorderSide(
                  color: config.accent,
                  width: 3.5,
                ),
                left: BorderSide(color: AppColor.greyBorder, width: 0.5),
                top: BorderSide(color: AppColor.greyBorder, width: 0.5),
                bottom: BorderSide(color: AppColor.greyBorder, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(order: order, config: config),
                const Divider(height: 1, color: AppColor.greyBorder),
                _CardBody(order: order),
                _DiscountAndShippingRow(order: order),
                if (order.isPending) _PendingActions(order: order),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final SubOrderModel order;
  final OrderStatusConfig config;

  const _CardHeader({required this.order, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: config.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _statusIcon(order.status),
              size: 20,
              color: config.accent,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.subOrderId,
                      style: AppTextStyle.orderNumber,
                    ),
                    if (order.isPending) ...[
                      const SizedBox(width: 6),
                      _PulseDot(),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  order.buyerName,
                  style:
                      AppTextStyle.bodySmall.copyWith(color: AppColor.black),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: AppColor.grey,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        order.shippingAddress,
                        style: AppTextStyle.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: config.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  config.labelKey.tr,
                  style: AppTextStyle.chip.copyWith(
                    color: config.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                order.createdAt,
                style: AppTextStyle.timestamp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'returned':
        return Icons.undo_rounded;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}

class _CardBody extends StatelessWidget {
  final SubOrderModel order;
  const _CardBody({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 14,
            color: AppColor.grey,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              order.items.map((i) => '${i.name} ×${i.qty}').join(' · '),
              style: AppTextStyle.labelSmall.copyWith(fontSize: 11.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            order.formattedTotal,
            style: AppTextStyle.price.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _DiscountAndShippingRow extends StatelessWidget {
  final SubOrderModel order;
  const _DiscountAndShippingRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (order.discountInfo != null) {
      final info = order.discountInfo!;
      if (info.isCoupon && info.couponCode != null) {
        chips.add(_InfoChip(
          icon: Icons.local_offer_rounded,
          label:
              '${'order_coupon_label'.tr} ${info.couponCode}',
          color: AppColor.statOrders,
          bgColor: AppColor.statOrdersLight,
        ));
      } else if (info.isSpinWheel) {
        chips.add(_InfoChip(
          icon: Icons.casino_outlined,
          label: 'order_spin_label'.tr,
          color: AppColor.warning,
          bgColor: AppColor.warningLight,
        ));
      } else if (info.isFreeShipping) {
        chips.add(_InfoChip(
          icon: Icons.local_shipping_outlined,
          label: 'order_free_ship_label'.tr,
          color: AppColor.success,
          bgColor: AppColor.successLight,
        ));
      }
    }

    chips.add(_InfoChip(
      icon: order.isOurDelivery
          ? Icons.delivery_dining_rounded
          : Icons.directions_car_outlined,
      label: order.isOurDelivery
          ? 'order_shipping_our'.tr
          : 'order_shipping_self'.tr,
      color: order.isOurDelivery ? AppColor.info : AppColor.grey,
      bgColor: order.isOurDelivery ? AppColor.infoLight : AppColor.greyBorder,
    ));

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: chips,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyle.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingActions extends StatelessWidget {
  final SubOrderModel order;
  const _PendingActions({required this.order});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SellerOrdersController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showRejectDialog(context, ctrl),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: AppColor.greyBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Text(
                'order_reject_btn'.tr,
                style: AppTextStyle.buttonSmall
                    .copyWith(color: AppColor.grey, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _showAcceptDialog(context, ctrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'order_accept_btn'.tr,
                    style: AppTextStyle.buttonSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, SellerOrdersController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AcceptOrderDialog(
        order: order,
        onConfirm: (minutes) =>
            ctrl.acceptOrder(order, estimatedMinutes: minutes),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, SellerOrdersController ctrl) {
    showDialog(
      context: context,
      builder: (_) => RejectOrderDialog(
        order: order,
        onConfirm: (reason) => ctrl.rejectOrder(order, reason),
      ),
    );
  }
}

class AcceptOrderDialog extends StatefulWidget {
  final SubOrderModel order;
  final void Function(int minutes) onConfirm;

  const AcceptOrderDialog({
    super.key,
    required this.order,
    required this.onConfirm,
  });

  @override
  State<AcceptOrderDialog> createState() => _AcceptOrderDialogState();
}

class _AcceptOrderDialogState extends State<AcceptOrderDialog> {
  int selectedMinutes = 30;
  final options = [15, 30, 45, 60, 90, 120];

  String _label(int m) => m < 60
      ? '$m ${'minute_label'.tr}'
      : '${m ~/ 60} ${'hour_label'.tr}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColor.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text('order_accept_title'.tr, style: AppTextStyle.heading3),
            const SizedBox(height: 4),
            Text(
              widget.order.subOrderId,
              style: AppTextStyle.labelMedium
                  .copyWith(color: AppColor.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'order_prep_time'.tr,
              style: AppTextStyle.labelLarge.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((m) {
                final isSelected = selectedMinutes == m;
                return GestureDetector(
                  onTap: () => setState(() => selectedMinutes = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primaryColor
                          : AppColor.secondBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primaryColor
                            : AppColor.greyBorder,
                      ),
                    ),
                    child: Text(
                      _label(m),
                      style: AppTextStyle.chip.copyWith(
                        color:
                            isSelected ? Colors.white : AppColor.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: AppTextStyle.buttonSmall
                          .copyWith(color: AppColor.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      widget.onConfirm(selectedMinutes);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'order_accept_confirm'.tr,
                      style: AppTextStyle.buttonMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RejectOrderDialog extends StatefulWidget {
  final SubOrderModel order;
  final void Function(String reason) onConfirm;

  const RejectOrderDialog({
    super.key,
    required this.order,
    required this.onConfirm,
  });

  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  String? _selected;
  final _otherCtrl = TextEditingController();

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  List<String> get _reasons => [
        'reject_out_stock'.tr,
        'reject_not_available'.tr,
        'reject_no_delivery'.tr,
        'reject_other'.tr,
      ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColor.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: AppColor.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text('order_reject_title'.tr, style: AppTextStyle.heading3),
            const SizedBox(height: 4),
            Text(
              'order_reject_refund_note'.tr,
              style: AppTextStyle.bodySmall
                  .copyWith(color: AppColor.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ..._reasons.map(
              (r) => GestureDetector(
                onTap: () => setState(() => _selected = r),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: _selected == r
                        ? AppColor.errorLight
                        : AppColor.secondBackground,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: _selected == r
                          ? AppColor.error
                          : AppColor.greyBorder,
                    ),
                  ),
                  child: Text(
                    r,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: _selected == r
                          ? AppColor.error
                          : AppColor.black,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            if (_selected == 'reject_other'.tr) ...[
              TextField(
                controller: _otherCtrl,
                maxLines: 2,
                style: AppTextStyle.inputText,
                decoration: InputDecoration(
                  hintText: 'reject_write'.tr,
                  hintStyle: AppTextStyle.inputHint,
                  filled: true,
                  fillColor: AppColor.secondBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide:
                        const BorderSide(color: AppColor.greyBorder),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: AppTextStyle.buttonSmall
                          .copyWith(color: AppColor.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selected == null
                        ? null
                        : () {
                            final reason =
                                _selected == 'reject_other'.tr
                                    ? _otherCtrl.text.trim()
                                    : _selected!;
                            Get.back();
                            widget.onConfirm(reason);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.error,
                      disabledBackgroundColor: AppColor.greyLight,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'order_reject_confirm'.tr,
                      style: AppTextStyle.buttonMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColor.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
