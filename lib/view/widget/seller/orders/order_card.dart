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
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 70), () {
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
              border: Border.all(
                color: order.isPending
                    ? config.accent.withOpacity(0.25)
                    : AppColor.greyBorder,
                width: 0.8,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: config.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _statusIcon(order.status),
                          size: 22,
                          color: config.accent,
                        ),
                      ),
                      const SizedBox(width: 12),

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
                              style: AppTextStyle.bodySmall.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: AppColor.grey,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    order.shippingAddress,
                                    style: AppTextStyle.labelSmall.copyWith(
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            order.formattedTotal,
                            style: AppTextStyle.price.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: config.bg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.displayStatusKey.tr,
                              style: AppTextStyle.chip.copyWith(
                                color: config.text,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.createdAt,
                            style: AppTextStyle.timestamp.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (order.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.secondBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 14,
                            color: AppColor.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.items
                                  .map((i) => '${i.name} ×${i.qty}')
                                  .join(' · '),
                              style: AppTextStyle.labelSmall.copyWith(
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${order.itemsCount} ${'order_items_count'.tr}',
                            style: AppTextStyle.labelSmall.copyWith(
                              fontSize: 10,
                              color: AppColor.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 14,
                        color: AppColor.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.shippingLabel ??
                              order.shippingMethod ??
                              'shipping_method_pending'.tr,
                          style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        order.shippingCost == null
                            ? 'shipping_cost_pending'.tr
                            : order.shippingFee == 0
                            ? 'order_free_ship_label'.tr
                            : '${order.shippingFee} ${'currency'.tr}',
                        style: AppTextStyle.labelSmall.copyWith(
                          color: order.shippingCost == null
                              ? AppColor.warning
                              : AppColor.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (order.isPending) _PendingActions(order: order),

                if (order.isProcessing) _QRHint(order: order),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
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
                side: BorderSide(color: AppColor.greyBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Text(
                'seller_cancel_order'.tr,
                style: AppTextStyle.buttonSmall.copyWith(
                  color: AppColor.grey,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: order.shippingCost == null
                ? ElevatedButton.icon(
                    onPressed: () => _showShippingDialog(context, ctrl),
                    icon: const Icon(Icons.local_shipping_outlined, size: 16),
                    label: Text(
                      'seller_set_shipping'.tr,
                      style: AppTextStyle.buttonSmall,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    child: Text(
                      order.shippingApproved
                          ? 'seller_waiting_payment'.tr
                          : 'seller_waiting_buyer_approval'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.labelSmall.copyWith(
                        color: order.shippingApproved
                            ? AppColor.info
                            : AppColor.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showShippingDialog(BuildContext context, SellerOrdersController ctrl) {
    showDialog(
      context: context,
      builder: (_) => SellerShippingQuoteDialog(order: order, ctrl: ctrl),
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

class SellerShippingQuoteDialog extends StatefulWidget {
  final SubOrderModel order;
  final SellerOrdersController ctrl;

  const SellerShippingQuoteDialog({
    super.key,
    required this.order,
    required this.ctrl,
  });

  @override
  State<SellerShippingQuoteDialog> createState() =>
      _SellerShippingQuoteDialogState();
}

class _SellerShippingQuoteDialogState extends State<SellerShippingQuoteDialog> {
  late final TextEditingController costCtrl;
  late final TextEditingController etaCtrl;

  @override
  void initState() {
    super.initState();
    costCtrl = TextEditingController();
    etaCtrl = TextEditingController();
  }

  @override
  void dispose() {
    costCtrl.dispose();
    etaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final method = widget.order.shippingMethod ?? 'standard';
    final methodLabel = widget.order.shippingLabel ?? method;

    return AlertDialog(
      title: Text('seller_shipping_quote_title'.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('seller_buyer_selected_method'.tr),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                methodLabel,
                style: AppTextStyle.labelLarge.copyWith(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: costCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'seller_shipping_cost_label'.tr,
                suffixText: 'currency'.tr,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: etaCtrl,
              decoration: InputDecoration(
                labelText: 'seller_estimated_delivery_label'.tr,
                hintText: 'seller_estimated_delivery_hint'.tr,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        ElevatedButton(
          onPressed: () {
            final cost = double.tryParse(costCtrl.text.trim());
            final eta = etaCtrl.text.trim();
            if (cost == null || cost < 0 || eta.isEmpty) {
              Get.snackbar('error'.tr, 'seller_shipping_quote_invalid'.tr);
              return;
            }
            widget.ctrl.setShippingDetails(
              widget.order,
              method: method,
              cost: cost,
              estimatedDelivery: eta,
            );
            Get.back();
          },
          child: Text('seller_submit_shipping_quote'.tr),
        ),
      ],
    );
  }
}

class _QRHint extends StatelessWidget {
  final SubOrderModel order;
  const _QRHint({required this.order});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
    child: GestureDetector(
      onTap: () => Get.toNamed('/seller/qr', arguments: order),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffEEEDFE), Color(0xffE3F2FD)],
          ),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColor.statOrders.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.qr_code_2_rounded,
              size: 22,
              color: AppColor.statOrders,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'qr_show_driver'.tr,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: AppColor.statOrders,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'qr_card_sub'.tr,
                    style: AppTextStyle.labelSmall.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColor.statOrders,
            ),
          ],
        ),
      ),
    ),
  );
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
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
    child: Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        shape: BoxShape.circle,
      ),
    ),
  );
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

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
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
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColor.primaryColor,
            ),
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
                    horizontal: 14,
                    vertical: 8,
                  ),
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
                    m < 60
                        ? '$m ${'minute_label'.tr}'
                        : '${m ~/ 60} ${'hour_label'.tr}',
                    style: AppTextStyle.chip.copyWith(
                      color: isSelected ? Colors.white : AppColor.grey,
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
                    style: AppTextStyle.buttonSmall.copyWith(
                      color: AppColor.grey,
                    ),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
  final _reasons = [
    'reject_out_stock',
    'reject_not_available',
    'reject_no_delivery',
    'reject_other',
  ];

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
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
          Text('seller_cancel_order_title'.tr, style: AppTextStyle.heading3),
          const SizedBox(height: 4),
          Text(
            'seller_cancel_order_note'.tr,
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColor.grey,
              fontSize: 12,
            ),
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
                  horizontal: 14,
                  vertical: 11,
                ),
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
                  r.tr,
                  style: AppTextStyle.labelLarge.copyWith(
                    color: _selected == r ? AppColor.error : AppColor.black,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          if (_selected == 'reject_other') ...[
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
                  borderSide: BorderSide(color: AppColor.greyBorder),
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
                    style: AppTextStyle.buttonSmall.copyWith(
                      color: AppColor.grey,
                    ),
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
                          final reason = _selected == 'reject_other'
                              ? _otherCtrl.text.trim()
                              : _selected!;
                          Get.back();
                          widget.onConfirm(reason);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.error,
                    disabledBackgroundColor: AppColor.greyLight,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'seller_cancel_order_confirm'.tr,
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
