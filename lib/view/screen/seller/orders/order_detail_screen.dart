import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/orders_models.dart';
import 'package:e_commerce/controller/seller/seller_orders_controller.dart';
import 'package:e_commerce/view/widget/seller/orders/order_card.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as SubOrderModel;
    final config = OrderStatusConfig.of(order.status);

    return Scaffold(
      backgroundColor: AppColor.secondBackground,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(children: [
          Text(order.subOrderId,
              style: AppTextStyle.appBarTitle.copyWith(fontSize: 15)),
          Text(order.createdAt,
              style: AppTextStyle.timestamp
                  .copyWith(color: Colors.white70, fontSize: 11)),
        ]),
        centerTitle: true,
        actions: [
          if (order.isProcessing)
            IconButton(
              icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
              onPressed: () => Get.to(
                () => const QRScreen(),
                arguments: order,
                transition: Transition.downToUp,
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                _StatusCard(order: order, config: config),
                const SizedBox(height: 14),

                if (order.timeline.isNotEmpty) ...[
                  _OrderTimeline(steps: order.timeline),
                  const SizedBox(height: 14),
                ],

                _InfoCard(
                  title: 'معلومات المشتري',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _InfoRow(
                        icon: Icons.person,
                        label: 'الاسم',
                        value: order.buyerName),
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'الهاتف',
                        value: order.buyerPhone),
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'العنوان',
                        value: order.shippingAddress),
                  ],
                ),
                const SizedBox(height: 14),

                _InfoCard(
                  title: 'المنتجات المطلوبة',
                  icon: Icons.shopping_bag_outlined,
                  children: [
                    ...order.items.map((item) => _ProductRow(item: item)),
                  ],
                ),
                const SizedBox(height: 14),

                _PriceBreakdown(order: order),
                const SizedBox(height: 14),

                if (order.isDelivered && order.escrowReleaseAt != null)
                  _EscrowCard(releaseAt: order.escrowReleaseAt!),

                if (order.isProcessing) ...[
                  const SizedBox(height: 4),
                  _QRButton(order: order),
                ],

                if (order.isPending) ...[
                  const SizedBox(height: 4),
                  _DetailActions(order: order),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final SubOrderModel      order;
  final OrderStatusConfig  config;
  const _StatusCard({required this.order, required this.config});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
      border: Border.all(
          color: config.accent.withOpacity(0.2), width: 1),
    ),
    child: Row(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: config.bg,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(_statusIcon(order.status),
            size: 24, color: config.accent),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(config.labelKey.tr,
              style: AppTextStyle.heading3.copyWith(
                  color: config.accent, fontSize: 15)),
          Text(_statusDesc(order.status),
              style: AppTextStyle.bodySmall.copyWith(fontSize: 12)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: config.bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(config.labelKey.tr,
            style: AppTextStyle.chip.copyWith(
              color: config.text,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            )),
      ),
    ]),
  );

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending':    return Icons.hourglass_top_rounded;
      case 'processing': return Icons.inventory_2_outlined;
      case 'shipped':    return Icons.local_shipping_outlined;
      case 'delivered':  return Icons.check_circle_outline_rounded;
      case 'cancelled':  return Icons.cancel_outlined;
      default:           return Icons.receipt_long_outlined;
    }
  }

  String _statusDesc(String s) {
    switch (s) {
      case 'pending':    return 'في انتظار موافقتك على الطلب';
      case 'processing': return 'الطلب قيد التجهيز — اعرض QR للمندوب';
      case 'shipped':    return 'المندوب في الطريق للمشتري';
      case 'delivered':  return 'تم التسليم — المبلغ محجوز بالضمان';
      case 'cancelled':  return 'تم إلغاء الطلب وإعادة المبلغ';
      default:           return '';
    }
  }
}

class _OrderTimeline extends StatelessWidget {
  final List<TimelineStep> steps;
  const _OrderTimeline({required this.steps});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.timeline_rounded,
              size: 18, color: AppColor.primaryColor),
          const SizedBox(width: 8),
          Text('مراحل الطلب', style: AppTextStyle.heading3.copyWith(fontSize: 14)),
        ]),
        const SizedBox(height: 14),
        ...steps.asMap().entries.map((e) {
          final isLast = e.key == steps.length - 1;
          return _TimelineRow(step: e.value, isLast: isLast);
        }),
      ],
    ),
  );
}

class _TimelineRow extends StatelessWidget {
  final TimelineStep step;
  final bool isLast;
  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 24,
        child: Column(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: step.isDone
                  ? AppColor.primaryColor : AppColor.greyLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.isDone ? Icons.check_rounded : Icons.circle_outlined,
              size: 12, color: Colors.white,
            ),
          ),
          if (!isLast)
            Container(
              width: 2, height: 32,
              color: step.isDone
                  ? AppColor.primaryColor.withOpacity(0.25)
                  : AppColor.greyBorder,
            ),
        ]),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(step.step,
                  style: AppTextStyle.labelLarge.copyWith(
                    fontSize: 13,
                    color: step.isDone ? AppColor.black : AppColor.greyLight,
                  )),
              Text(step.time, style: AppTextStyle.timestamp),
            ],
          ),
        ),
      ),
    ],
  );
}

class _InfoCard extends StatelessWidget {
  final String   title;
  final IconData icon;
  final List<Widget> children;
  const _InfoCard({
    required this.title, required this.icon, required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: AppColor.primaryColor),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyle.heading3.copyWith(fontSize: 14)),
      ]),
      const Divider(height: 16, color: AppColor.greyBorder),
      ...children,
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _InfoRow({
    required this.icon, required this.label, required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: AppColor.grey),
      const SizedBox(width: 8),
      SizedBox(
        width: 60,
        child: Text(label,
            style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
      ),
      Expanded(
        child: Text(value,
            style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
      ),
    ]),
  );
}

class _ProductRow extends StatelessWidget {
  final OrderItemModel item;
  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColor.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.inventory_2_outlined,
            size: 18, color: AppColor.primaryColor),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name,
              style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
          if (item.variant != null)
            Text(item.variant!,
                style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
        ]),
      ),
      Text('×${item.qty}',
          style: AppTextStyle.labelMedium.copyWith(
              color: AppColor.grey, fontSize: 13)),
      const SizedBox(width: 12),
      Text('SP ${item.price ~/ 1000}k',
          style: AppTextStyle.price.copyWith(fontSize: 13)),
    ]),
  );
}

class _PriceBreakdown extends StatelessWidget {
  final SubOrderModel order;
  const _PriceBreakdown({required this.order});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(children: [
      Row(children: [
        const Icon(Icons.receipt_outlined,
            size: 18, color: AppColor.primaryColor),
        const SizedBox(width: 8),
        Text('ملخص المبالغ',
            style: AppTextStyle.heading3.copyWith(fontSize: 14)),
      ]),
      const Divider(height: 16, color: AppColor.greyBorder),
      _PriceRow(label: 'إجمالي المنتجات',
          value: 'SP ${order.itemsTotal ~/ 1000}k'),
      _PriceRow(label: 'رسوم الشحن',
          value: 'SP ${order.shippingFee ~/ 1000}k'),
      if (order.discount > 0)
        _PriceRow(label: 'الخصم',
            value: '- SP ${order.discount ~/ 1000}k',
            valueColor: AppColor.success),
      const Divider(height: 14, color: AppColor.greyBorder),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('الإجمالي',
            style: AppTextStyle.heading3.copyWith(fontSize: 14)),
        Text('SP ${order.subtotal ~/ 1000}k',
            style: AppTextStyle.priceLarge.copyWith(fontSize: 18)),
      ]),
    ]),
  );
}

class _PriceRow extends StatelessWidget {
  final String  label;
  final String  value;
  final Color?  valueColor;
  const _PriceRow({
    required this.label, required this.value, this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.bodyMedium.copyWith(fontSize: 13)),
        Text(value,
            style: AppTextStyle.labelLarge.copyWith(
              color: valueColor ?? AppColor.black,
              fontSize: 13,
            )),
      ],
    ),
  );
}

class _EscrowCard extends StatelessWidget {
  final String releaseAt;
  const _EscrowCard({required this.releaseAt});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColor.successLight,
          AppColor.statAvgLight,
        ],
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: AppColor.success.withOpacity(0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.lock_clock_outlined,
          size: 22, color: AppColor.success),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المبلغ محجوز في الضمان',
                style: AppTextStyle.labelLarge.copyWith(
                    color: AppColor.successDark, fontSize: 13)),
            Text('سيُحرَّر تلقائياً $releaseAt',
                style: AppTextStyle.labelSmall
                    .copyWith(color: AppColor.successDark, fontSize: 11)),
          ],
        ),
      ),
    ]),
  );
}

class _QRButton extends StatelessWidget {
  final SubOrderModel order;
  const _QRButton({required this.order});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      onPressed: () => Get.to(
        () => const QRScreen(),
        arguments: order,
        transition: Transition.downToUp,
      ),
      icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
      label: Text('عرض رمز QR للمندوب',
          style: AppTextStyle.buttonLarge),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.statOrders,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class _DetailActions extends StatelessWidget {
  final SubOrderModel order;
  const _DetailActions({required this.order});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SellerOrdersController>();
    return Row(children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => RejectOrderDialog(
              order: order,
              onConfirm: (reason) {
                ctrl.rejectOrder(order, reason);
                Get.back();
              },
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
            side: const BorderSide(color: AppColor.greyBorder),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('رفض الطلب',
              style: AppTextStyle.buttonMedium
                  .copyWith(color: AppColor.grey)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AcceptOrderDialog(
              order: order,
              onConfirm: (minutes) {
                ctrl.acceptOrder(order, estimatedMinutes: minutes);
                Get.back();
              },
            ),
          ),
          icon: const Icon(Icons.check_rounded,
              color: Colors.white, size: 18),
          label: Text('قبول الطلب',
              style: AppTextStyle.buttonMedium),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ]);
  }
}


class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as SubOrderModel;

    return Scaffold(
      backgroundColor: const Color(0xff1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: Colors.white, size: 24),
          onPressed: () => Get.back(),
        ),
        title: Text('رمز QR الاستلام',
            style: AppTextStyle.appBarTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'اعرض هذا الرمز للمندوب عند استلامه البضاعة منك',
                      style: AppTextStyle.bodySmall.copyWith(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ]),
              ),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: order.qrToken ?? order.subOrderId,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xff1A1A1A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xff1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(order.subOrderId,
                  style: AppTextStyle.heading2.copyWith(
                      color: Colors.white, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(order.buyerName,
                  style: AppTextStyle.bodyMedium.copyWith(
                      color: Colors.white60)),
              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 14, color: Colors.white38),
                    const SizedBox(width: 6),
                    Text(
                      'رمز مشفر · صالح لمرة واحدة فقط',
                      style: AppTextStyle.labelSmall.copyWith(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
