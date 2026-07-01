import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:e_commerce/controller/seller/seller_orders_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/orders_models.dart';
import 'package:e_commerce/view/widget/seller/orders/order_card.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as SubOrderModel;
    final config = OrderStatusConfig.of(order.status);

    return Scaffold(
      backgroundColor: AppColor.secondBackground,
      appBar: _DetailAppBar(order: order),
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
                _BuyerInfoCard(order: order),
                const SizedBox(height: 14),
                _ItemsCard(order: order),
                const SizedBox(height: 14),
                _PriceCard(order: order),
                const SizedBox(height: 14),
                if (order.isDelivered && order.escrowReleaseAt != null)
                  _EscrowCard(order: order),
                if (order.showQR) ...[
                  const SizedBox(height: 4),
                  _QRActionCard(order: order),
                ],
                if (order.isSelfShipping && order.isProcessing) ...[
                  const SizedBox(height: 4),
                  _SelfShippingCard(),
                ],
                if (order.isPending) ...[
                  const SizedBox(height: 4),
                  _DetailActions(order: order),
                ],
                const SizedBox(height: 12),
                _MessageBuyerButton(order: order),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SubOrderModel order;
  const _DetailAppBar({required this.order});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: Column(
        children: [
          Text(
            order.subOrderId,
            style: AppTextStyle.appBarTitle.copyWith(fontSize: 15),
          ),
          Text(
            order.createdAt,
            style: AppTextStyle.timestamp
                .copyWith(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (order.showQR)
          IconButton(
            icon: const Icon(
              Icons.qr_code_2_rounded,
              color: Colors.white,
            ),
            onPressed: () => _navigateToQR(order),
          ),
      ],
    );
  }

  void _navigateToQR(SubOrderModel order) {
    Get.to(
          () => const QRScreen(),
      arguments: order,
      transition: Transition.downToUp,
    );
  }
}

class _StatusCard extends StatelessWidget {
  final SubOrderModel order;
  final OrderStatusConfig config;

  const _StatusCard({required this.order, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
        border: Border.all(
          color: config.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: config.bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _statusIcon(order.status),
              size: 26,
              color: config.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.labelKey.tr,
                  style: AppTextStyle.heading3.copyWith(
                    color: config.accent,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _statusDesc(order),
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
                ),
                if (order.estimatedReady != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: AppColor.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.estimatedReady!,
                        style:
                        AppTextStyle.labelSmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: config.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              config.labelKey.tr,
              style: AppTextStyle.chip.copyWith(
                color: config.text,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusDesc(SubOrderModel o) {
    switch (o.status) {
      case 'pending':
        return 'status_desc_pending'.tr;
      case 'processing':
        return o.isOurDelivery
            ? 'status_desc_processing_our'.tr
            : 'status_desc_processing_self'.tr;
      case 'shipped':
        return 'status_desc_shipped'.tr;
      case 'delivered':
        return 'status_desc_delivered'.tr;
      case 'cancelled':
        return 'status_desc_cancelled'.tr;
      default:
        return '';
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline_rounded;
      case 'cancelled':
      case 'cancelled_returned':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}

String _timelineStepTranslate(String status, String defaultTitle) {
  switch (status) {
    case 'pending': return 'timeline_pending'.tr;
    case 'processing': return 'timeline_processing'.tr;
    case 'shipped': return 'timeline_shipped'.tr;
    case 'delivered': return 'timeline_delivered'.tr;
    case 'cancelled': 
    case 'cancelled_returned':
      return 'timeline_cancelled'.tr;
    default: return defaultTitle;
  }
}

class _OrderTimeline extends StatelessWidget {
  final List<TimelineStep> steps;
  const _OrderTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.timeline_rounded,
      title: 'section_order_timeline'.tr,
      child: Column(
        children: steps.asMap().entries.map((e) {
          final isLast = e.key == steps.length - 1;
          return _TimelineRow(step: e.value, isLast: isLast);
        }).toList(),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineStep step;
  final bool isLast;
  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: step.isDone
                      ? AppColor.primaryColor
                      : Colors.white,
                  border: step.isDone ? null : Border.all(color: AppColor.greyLight, width: 2),
                  shape: BoxShape.circle,
                  boxShadow: step.isDone ? [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ] : null,
                ),
                child: step.isDone ? const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ) : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: step.isDone
                        ? AppColor.primaryColor.withOpacity(0.4)
                        : AppColor.greyBorder,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _timelineStepTranslate(step.status, step.step),
                    style: AppTextStyle.labelLarge.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: step.isDone
                          ? AppColor.black
                          : AppColor.greyLight,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  step.time, 
                  style: AppTextStyle.timestamp.copyWith(
                    color: step.isDone ? AppColor.grey : AppColor.greyLight,
                    fontWeight: step.isDone ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BuyerInfoCard extends StatelessWidget {
  final SubOrderModel order;
  const _BuyerInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.person_outline_rounded,
      title: 'section_buyer_info'.tr,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person,
            label: 'buyer_name_label'.tr,
            value: order.buyerName,
          ),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'buyer_phone_label'.tr,
            value: order.buyerPhone,
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'buyer_address_label'.tr,
            value: order.shippingAddress,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final SubOrderModel order;
  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.shopping_bag_outlined,
      title: 'section_order_items'.tr,
      child: Column(
        children: order.items.map((item) => _ProductRow(item: item)).toList(),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final OrderItemModel item;
  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: AppColor.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyle.labelLarge.copyWith(fontSize: 13),
                ),
                if (item.variant != null)
                  Text(
                    item.variant!,
                    style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
          Text(
            '×${item.qty}',
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColor.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.price >= 1000 ? 'SP ${item.price ~/ 1000}k' : 'SP ${item.price}',
            style: AppTextStyle.price.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final SubOrderModel order;
  const _PriceCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.receipt_outlined,
      title: 'section_price_summary'.tr,
      child: Column(
        children: [
          _PriceRow(
            label: 'price_items_total'.tr,
            value: order.itemsTotal >= 1000 ? 'SP ${order.itemsTotal ~/ 1000}k' : 'SP ${order.itemsTotal}',
          ),
          _PriceRow(
            label: 'price_shipping'.tr,
            value: order.shippingFee == 0
                ? 'order_free_ship_label'.tr
                : (order.shippingFee >= 1000 ? 'SP ${order.shippingFee ~/ 1000}k' : 'SP ${order.shippingFee}'),
            valueColor: order.shippingFee == 0
                ? AppColor.success
                : null,
          ),
          if (order.discount > 0) ...[
            _PriceRow(
              label: _discountLabel(order),
              value: order.discount >= 1000 ? '- SP ${order.discount ~/ 1000}k' : '- SP ${order.discount}',
              valueColor: AppColor.success,
            ),
            if (order.discountInfo != null)
              _DiscountSourceChip(info: order.discountInfo!),
          ],
          const Divider(height: 16, color: AppColor.greyBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'price_total'.tr,
                style: AppTextStyle.heading3.copyWith(fontSize: 14),
              ),
              Text(
                order.subtotal >= 1000 ? 'SP ${order.subtotal ~/ 1000}k' : 'SP ${order.subtotal}',
                style: AppTextStyle.priceLarge.copyWith(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _discountLabel(SubOrderModel o) {
    if (o.discountInfo == null) return 'price_discount'.tr;
    if (o.discountInfo!.isCoupon) {
      return '${'price_discount'.tr} — ${o.discountInfo!.couponCode ?? ""}';
    }
    if (o.discountInfo!.isSpinWheel) {
      return '${'price_discount'.tr} — ${'order_spin_label'.tr}';
    }
    return 'price_discount'.tr;
  }
}

class _DiscountSourceChip extends StatelessWidget {
  final DiscountInfo info;
  const _DiscountSourceChip({required this.info});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color, bg) = info.isCoupon
        ? (
    Icons.local_offer_rounded,
    '${info.couponCode}',
    AppColor.statOrders,
    AppColor.statOrdersLight
    )
        : info.isSpinWheel
        ? (
    Icons.casino_outlined,
    'order_spin_label'.tr,
    AppColor.warning,
    AppColor.warningLight
    )
        : (
    Icons.local_shipping_outlined,
    'order_free_ship_label'.tr,
    AppColor.success,
    AppColor.successLight
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
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
          ),
        ],
      ),
    );
  }
}

class _EscrowCard extends StatelessWidget {
  final SubOrderModel order;
  const _EscrowCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final releaseNote = order.isOurDelivery
        ? 'escrow_release_scan'.tr
        : 'escrow_release_buyer'.tr;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.successLight, AppColor.statAvgLight],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_clock_outlined,
            size: 22,
            color: AppColor.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'escrow_held_title'.tr,
                  style: AppTextStyle.labelLarge.copyWith(
                    color: AppColor.successDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order.escrowReleaseAt != null
                      ? '${'escrow_auto_release'.tr} ${order.escrowReleaseAt}'
                      : releaseNote,
                  style: AppTextStyle.labelSmall.copyWith(
                    color: AppColor.successDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QRActionCard extends StatelessWidget {
  final SubOrderModel order;
  const _QRActionCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () => Get.to(
              () => const QRScreen(),
          arguments: order,
          transition: Transition.downToUp,
        ),
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xffEEEDFE), Color(0xffE3F2FD)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColor.statOrders.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColor.statOrdersLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 24,
                  color: AppColor.statOrders,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'qr_show_driver'.tr,
                      style: AppTextStyle.labelLarge.copyWith(
                        color: AppColor.statOrders,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'qr_card_sub'.tr,
                      style: AppTextStyle.labelSmall.copyWith(
                        fontSize: 10.5,
                      ),
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
}

class _SelfShippingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.infoLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.info.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_car_outlined,
            size: 22,
            color: AppColor.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'order_shipping_self'.tr,
                  style: AppTextStyle.labelLarge.copyWith(
                    color: AppColor.infoDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'escrow_release_buyer'.tr,
                  style: AppTextStyle.labelSmall.copyWith(
                    color: AppColor.infoDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  final SubOrderModel order;
  const _DetailActions({required this.order});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SellerOrdersController>();
    return Row(
      children: [
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
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'order_reject_title'.tr,
              style:
              AppTextStyle.buttonMedium.copyWith(color: AppColor.grey),
            ),
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
            icon: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              'order_accept_btn'.tr,
              style: AppTextStyle.buttonMedium,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBuyerButton extends StatelessWidget {
  final SubOrderModel order;
  const _MessageBuyerButton({required this.order});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SellerOrdersController>();
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => ctrl.messageBuyer(order),
        icon: const Icon(
          Icons.chat_bubble_outline_rounded,
          size: 18,
          color: AppColor.primaryColor,
        ),
        label: Text(
          'order_message_buyer'.tr,
          style: AppTextStyle.buttonMedium.copyWith(
            color: AppColor.primaryColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColor.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
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
              Text(
                title,
                style: AppTextStyle.heading3.copyWith(fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColor.greyBorder),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColor.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.labelLarge.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.bodyMedium.copyWith(fontSize: 13),
          ),
          Text(
            value,
            style: AppTextStyle.labelLarge.copyWith(
              color: valueColor ?? AppColor.black,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
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
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('qr_screen_title'.tr, style: AppTextStyle.appBarTitle),
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'qr_instruction'.tr,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
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
              Text(
                order.subOrderId,
                style: AppTextStyle.heading2.copyWith(
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                order.buyerName,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'qr_encrypted_note'.tr,
                      style: AppTextStyle.labelSmall.copyWith(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
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