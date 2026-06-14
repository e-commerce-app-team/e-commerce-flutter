import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_orders_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/orders_models.dart';

class OrderCard extends StatefulWidget {
  final SubOrderModel order;
  final int           index;
  final VoidCallback  onTap;

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
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 70), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final order  = widget.order;
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
                width: order.isPending ? 1.2 : 0.8,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
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
                            Row(children: [
                              Text(order.subOrderId,
                                  style: AppTextStyle.orderNumber),
                              if (order.isPending) ...[
                                const SizedBox(width: 6),
                                _PulseDot(),
                              ],
                            ]),
                            const SizedBox(height: 3),
                            Text(order.buyerName,
                                style: AppTextStyle.bodySmall
                                    .copyWith(fontSize: 12)),
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: AppColor.grey),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  order.shippingAddress,
                                  style: AppTextStyle.labelSmall
                                      .copyWith(fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(order.formattedTotal,
                              style: AppTextStyle.price.copyWith(fontSize: 14)),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: config.bg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(config.labelKey.tr,
                                style: AppTextStyle.chip.copyWith(
                                  color: config.text,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                          const SizedBox(height: 4),
                          Text(order.createdAt,
                              style: AppTextStyle.timestamp
                                  .copyWith(fontSize: 10)),
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
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColor.secondBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 14, color: AppColor.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.items
                                .map((i) => '${i.name} ×${i.qty}')
                                .join(' · '),
                            style: AppTextStyle.labelSmall
                                .copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ),
                  ),

                if (order.isPending)
                  _PendingActions(order: order),

                if (order.isProcessing)
                  _QRHint(order: order),

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
      case 'pending':    return Icons.hourglass_top_rounded;
      case 'processing': return Icons.inventory_2_outlined;
      case 'shipped':    return Icons.local_shipping_outlined;
      case 'delivered':  return Icons.check_circle_outline_rounded;
      case 'cancelled':  return Icons.cancel_outlined;
      case 'returned':   return Icons.undo_rounded;
      default:           return Icons.receipt_long_outlined;
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
      child: Row(children: [
        // رفض
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showRejectDialog(context, ctrl),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: const BorderSide(color: AppColor.greyBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
            child: Text('رفض'.tr,
                style: AppTextStyle.buttonSmall.copyWith(
                    color: AppColor.grey, fontSize: 13)),
          ),
        ),
        const SizedBox(width: 10),
        // قبول
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _showAcceptDialog(context, ctrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text('قبول الطلب'.tr, style: AppTextStyle.buttonSmall),
            ]),
          ),
        ),
      ]),
    );
  }

  void _showAcceptDialog(
      BuildContext context, SellerOrdersController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AcceptOrderDialog(
        order: order,
        onConfirm: (minutes) => ctrl.acceptOrder(order,
            estimatedMinutes: minutes),
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, SellerOrdersController ctrl) {
    showDialog(
      context: context,
      builder: (_) => RejectOrderDialog(
        order: order,
        onConfirm: (reason) => ctrl.rejectOrder(order, reason),
      ),
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
        child: Row(children: [
          const Icon(Icons.qr_code_2_rounded,
              size: 22, color: AppColor.statOrders),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عرض رمز QR للمندوب',
                    style: AppTextStyle.labelLarge.copyWith(
                        color: AppColor.statOrders, fontSize: 12)),
                Text('اضغط لعرض الرمز عند استلام البضاعة',
                    style: AppTextStyle.labelSmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: AppColor.statOrders),
        ]),
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
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
    child: Container(
      width: 7, height: 7,
      decoration: const BoxDecoration(
        color: AppColor.primaryColor, shape: BoxShape.circle),
    ),
  );
}


class AcceptOrderDialog extends StatefulWidget {
  final SubOrderModel order;
  final void Function(int minutes) onConfirm;
  const AcceptOrderDialog({
    super.key, required this.order, required this.onConfirm,
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
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(
            color: AppColor.primarySurface, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline_rounded,
              color: AppColor.primaryColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text('قبول الطلب', style: AppTextStyle.heading3),
        const SizedBox(height: 4),
        Text(widget.order.subOrderId,
            style: AppTextStyle.labelMedium
                .copyWith(color: AppColor.primaryColor)),
        const SizedBox(height: 16),
        Text('وقت التجهيز المتوقع',
            style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
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
                      ? AppColor.primaryColor : AppColor.secondBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.primaryColor : AppColor.greyBorder,
                  ),
                ),
                child: Text(
                  m < 60 ? '$m دقيقة' : '${m ~/ 60} ساعة',
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
        Row(children: [
          Expanded(
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text('إلغاء',
                  style: AppTextStyle.buttonSmall
                      .copyWith(color: AppColor.grey)),
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
                backgroundColor: AppColor.primaryColor, elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('تأكيد القبول', style: AppTextStyle.buttonMedium),
            ),
          ),
        ]),
      ]),
    ),
  );
}


class RejectOrderDialog extends StatefulWidget {
  final SubOrderModel order;
  final void Function(String reason) onConfirm;
  const RejectOrderDialog({
    super.key, required this.order, required this.onConfirm,
  });
  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  String? _selected;
  final _otherCtrl = TextEditingController();
  final _reasons = [
    'نفد المخزون',
    'المنتج غير متاح مؤقتاً',
    'لا أستطيع التوصيل لهذه المنطقة',
    'سبب آخر',
  ];

  @override
  void dispose() { _otherCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppColor.errorLight, shape: BoxShape.circle),
          child: const Icon(Icons.cancel_outlined,
              color: AppColor.error, size: 28),
        ),
        const SizedBox(height: 12),
        Text('رفض الطلب', style: AppTextStyle.heading3),
        const SizedBox(height: 4),
        Text('سيتم إعادة المبلغ للمشتري تلقائياً',
            style: AppTextStyle.bodySmall
                .copyWith(color: AppColor.grey, fontSize: 12),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ..._reasons.map((r) => GestureDetector(
          onTap: () => setState(() => _selected = r),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: _selected == r
                  ? AppColor.errorLight : AppColor.secondBackground,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: _selected == r
                    ? AppColor.error : AppColor.greyBorder,
              ),
            ),
            child: Text(r,
                style: AppTextStyle.labelLarge.copyWith(
                  color: _selected == r ? AppColor.error : AppColor.black,
                  fontSize: 13,
                )),
          ),
        )),
        if (_selected == 'سبب آخر') ...[
          TextField(
            controller: _otherCtrl,
            maxLines: 2,
            style: AppTextStyle.inputText,
            decoration: InputDecoration(
              hintText: 'اكتب السبب...',
              hintStyle: AppTextStyle.inputHint,
              filled: true, fillColor: AppColor.secondBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: AppColor.greyBorder),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(children: [
          Expanded(
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text('إلغاء',
                  style: AppTextStyle.buttonSmall
                      .copyWith(color: AppColor.grey)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selected == null ? null : () {
                final reason = _selected == 'سبب آخر'
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('تأكيد الرفض', style: AppTextStyle.buttonMedium),
            ),
          ),
        ]),
      ]),
    ),
  );
}
