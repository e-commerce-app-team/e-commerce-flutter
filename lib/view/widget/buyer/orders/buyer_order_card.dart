// lib/view/widget/buyer/orders/buyer_order_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/utils/buyer_format_utils.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';

/// A single order card with a subtle entrance animation.
///
/// The card structure:
///   ┌──────────────────────────────────────────┐
///   │ [STATUS ICON]  #ORD-XXXXX    [STATUS CHIP]│
///   │               اسم المتجر                 │
///   │               125,000 ل.س    📅 01/01/24  │
///   ├──────────────────────────────────────────┤
///   │ 🛍️ 2 منتج • سماعات لاسلكية، شاحن USB-C   │
///   ├──────────────────────────────────────────┤
///   │          [ACTION BUTTON – FULL WIDTH]     │
///   └──────────────────────────────────────────┘
///
/// Action buttons rendered per status:
///   • pending    → outlined "إلغاء الطلب"   (AppColor.error accent)
///   • shipped    → filled   "تتبع الطلب"   (mainGradient)
///   • delivered / cancelled / returned
///                → outlined "إعادة الطلب"  (primaryColor accent)
///   • processing → no button (item is being prepared)
class BuyerOrderCard extends StatefulWidget {
  final BuyerOrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onCancelTap;
  final VoidCallback? onTrackTap;
  final VoidCallback? onReorderTap;

  const BuyerOrderCard({
    Key? key,
    required this.order,
    this.onTap,
    this.onCancelTap,
    this.onTrackTap,
    this.onReorderTap,
  }) : super(key: key);

  @override
  State<BuyerOrderCard> createState() => _BuyerOrderCardState();
}

class _BuyerOrderCardState extends State<BuyerOrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _OrderCardBody(
          order: widget.order,
          onTap: widget.onTap,
          onCancelTap: widget.onCancelTap,
          onTrackTap: widget.onTrackTap,
          onReorderTap: widget.onReorderTap,
        ),
      ),
    );
  }
}

// ─── Card body ────────────────────────────────────────────────────────────────

class _OrderCardBody extends StatelessWidget {
  final BuyerOrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onCancelTap;
  final VoidCallback? onTrackTap;
  final VoidCallback? onReorderTap;

  const _OrderCardBody({
    required this.order,
    this.onTap,
    this.onCancelTap,
    this.onTrackTap,
    this.onReorderTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColor.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildHairline(),
            _buildItemsRow(),
            _buildActionRow(),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusIconCircle(status: order.status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order number row + status chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.orderNumber}',
                        style: AppTextStyle.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _OrderStatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 5),

                // Store name
                Text(
                  order.storeName,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColor.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Price + date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${formatBuyerPrice(order.totalAmount)} ${'currency'.tr}',
                      style: AppTextStyle.price,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 12,
                      color: AppColor.grey,
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
    );
  }

  // ── Divider ─────────────────────────────────────────────────────────────────

  Widget _buildHairline() => const Divider(
        height: 1,
        thickness: 1,
        indent: 14,
        endIndent: 14,
        color: AppColor.greyBorder,
      );

  // ── Items preview row ────────────────────────────────────────────────────────

  Widget _buildItemsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
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
              // TODO: TRANSLATIONS — 'order_items_count' → ar: 'منتج'  en: 'item(s)'
              '${order.itemsCount} ${'order_items_count'.tr} • ${order.itemsPreview}',
              style: AppTextStyle.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action row ───────────────────────────────────────────────────────────────

  Widget _buildActionRow() {
    final button = _resolveActionButton();
    if (button == null) return const SizedBox(height: 10);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: button,
    );
  }

  Widget? _resolveActionButton() {
    switch (order.status) {
      case BuyerOrderStatus.pending:
        // TODO: TRANSLATIONS — 'cancel_order' → ar: 'إلغاء الطلب'  en: 'Cancel Order'
        return _OrderActionButton.outlined(
          label: 'cancel_order'.tr,
          icon: Icons.close_rounded,
          accentColor: AppColor.error,
          onTap: onCancelTap,
        );
      case BuyerOrderStatus.shipped:
        // TODO: TRANSLATIONS — 'track_order' → ar: 'تتبع الطلب'  en: 'Track Order'
        return _OrderActionButton.filled(
          label: 'track_order'.tr,
          icon: Icons.location_on_outlined,
          onTap: onTrackTap,
        );
      case BuyerOrderStatus.delivered:
      case BuyerOrderStatus.cancelled:
      case BuyerOrderStatus.returned:
        // TODO: TRANSLATIONS — 'reorder' → ar: 'إعادة الطلب'  en: 'Reorder'
        return _OrderActionButton.outlined(
          label: 'reorder'.tr,
          icon: Icons.replay_rounded,
          accentColor: AppColor.primaryColor,
          onTap: onReorderTap,
        );
      default:
        // processing — no action while the store is preparing the order
        return null;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

// ─── Status icon circle ───────────────────────────────────────────────────────

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
      case BuyerOrderStatus.pending:    return AppColor.pendingBg;
      case BuyerOrderStatus.processing: return AppColor.processingBg;
      case BuyerOrderStatus.shipped:    return AppColor.shippedBg;
      case BuyerOrderStatus.delivered:  return AppColor.deliveredBg;
      case BuyerOrderStatus.cancelled:  return AppColor.cancelledBg;
      case BuyerOrderStatus.returned:   return AppColor.returnedBg;
    }
  }

  Color get _fgColor {
    switch (status) {
      case BuyerOrderStatus.pending:    return AppColor.pendingText;
      case BuyerOrderStatus.processing: return AppColor.processingText;
      case BuyerOrderStatus.shipped:    return AppColor.shippedText;
      case BuyerOrderStatus.delivered:  return AppColor.deliveredText;
      case BuyerOrderStatus.cancelled:  return AppColor.cancelledText;
      case BuyerOrderStatus.returned:   return AppColor.returnedText;
    }
  }

  IconData get _icon {
    switch (status) {
      case BuyerOrderStatus.pending:    return Icons.schedule_rounded;
      case BuyerOrderStatus.processing: return Icons.inventory_2_outlined;
      case BuyerOrderStatus.shipped:    return Icons.local_shipping_outlined;
      case BuyerOrderStatus.delivered:  return Icons.check_circle_outline_rounded;
      case BuyerOrderStatus.cancelled:  return Icons.cancel_outlined;
      case BuyerOrderStatus.returned:   return Icons.assignment_return_outlined;
    }
  }
}

// ─── Status chip ──────────────────────────────────────────────────────────────

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
      case BuyerOrderStatus.pending:    return AppColor.pendingBg;
      case BuyerOrderStatus.processing: return AppColor.processingBg;
      case BuyerOrderStatus.shipped:    return AppColor.shippedBg;
      case BuyerOrderStatus.delivered:  return AppColor.deliveredBg;
      case BuyerOrderStatus.cancelled:  return AppColor.cancelledBg;
      case BuyerOrderStatus.returned:   return AppColor.returnedBg;
    }
  }

  Color get _fgColor {
    switch (status) {
      case BuyerOrderStatus.pending:    return AppColor.pendingText;
      case BuyerOrderStatus.processing: return AppColor.processingText;
      case BuyerOrderStatus.shipped:    return AppColor.shippedText;
      case BuyerOrderStatus.delivered:  return AppColor.deliveredText;
      case BuyerOrderStatus.cancelled:  return AppColor.cancelledText;
      case BuyerOrderStatus.returned:   return AppColor.returnedText;
    }
  }

  /// Uses existing translation keys where they match the buyer context.
  String get _labelKey {
    switch (status) {
      case BuyerOrderStatus.pending:    return 'status_pending';
      case BuyerOrderStatus.processing: return 'status_processing';
      case BuyerOrderStatus.shipped:    return 'status_shipped';
      case BuyerOrderStatus.delivered:  return 'status_delivered';
      case BuyerOrderStatus.cancelled:  return 'status_cancelled';
      case BuyerOrderStatus.returned:   return 'status_returned';
    }
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

/// Two named constructors drive the two visual variants:
///   • [_OrderActionButton.filled]   — gradient background (primary action)
///   • [_OrderActionButton.outlined] — border only (secondary / destructive)
class _OrderActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool _isFilled;
  final Color? _accentColor;
  final VoidCallback? onTap;

  const _OrderActionButton.filled({
    required this.label,
    required this.icon,
    this.onTap,
  })  : _isFilled = true,
        _accentColor = null;

  const _OrderActionButton.outlined({
    required this.label,
    required this.icon,
    required Color accentColor,
    this.onTap,
  })  : _isFilled = false,
        _accentColor = accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _isFilled ? _filledBody() : _outlinedBody(),
    );
  }

  Widget _filledBody() {
    return Container(
      height: 40,
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
          Icon(icon, size: 15, color: AppColor.backgroundcolor),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyle.buttonSmall),
        ],
      ),
    );
  }

  Widget _outlinedBody() {
    final color = _accentColor!;
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.45), width: 1.2),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyle.buttonSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

