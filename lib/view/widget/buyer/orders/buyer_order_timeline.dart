import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/utils/buyer_format_utils.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';

class BuyerOrderTimeline extends StatelessWidget {
  final List<BuyerTimelineStep> steps;
  final bool compact;

  const BuyerOrderTimeline({
    Key? key,
    required this.steps,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;
        return _TimelineRow(step: step, isLast: isLast, compact: compact);
      }).toList(),
    );
  }
}

class _TimelineRow extends StatefulWidget {
  final BuyerTimelineStep step;
  final bool isLast;
  final bool compact;

  const _TimelineRow({
    required this.step,
    required this.isLast,
    required this.compact,
  });

  @override
  State<_TimelineRow> createState() => _TimelineRowState();
}

class _TimelineRowState extends State<_TimelineRow>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseCtrl;

  @override
  void initState() {
    super.initState();
    if (widget.step.isCurrent) {
      _pulseCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    super.dispose();
  }

  Color get _accent {
    if (widget.step.isCurrent) return AppColor.primaryColor;
    if (widget.step.isDone) return AppColor.deliveredText;
    return AppColor.greyLight;
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.compact ? 20.0 : 26.0;

    Widget dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: widget.step.isDone || widget.step.isCurrent ? _accent : Colors.white,
        shape: BoxShape.circle,
        border: widget.step.isDone || widget.step.isCurrent
            ? null
            : Border.all(color: AppColor.greyBorder, width: 2),
        boxShadow: widget.step.isCurrent
            ? [
                BoxShadow(
                  color: _accent.withOpacity(0.45),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: widget.step.isDone
          ? Icon(Icons.check_rounded, size: dotSize * 0.55, color: Colors.white)
          : widget.step.isCurrent
              ? Icon(Icons.circle, size: dotSize * 0.35, color: Colors.white)
              : null,
    );

    if (_pulseCtrl != null) {
      dot = ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.08).animate(
          CurvedAnimation(parent: _pulseCtrl!, curve: Curves.easeInOut),
        ),
        child: dot,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: dotSize + 4,
          child: Column(
            children: [
              dot,
              if (!widget.isLast)
                Container(
                  width: 2,
                  height: widget.compact ? 28 : 36,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.step.isDone
                        ? _accent.withOpacity(0.45)
                        : AppColor.greyBorder,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 16, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stepLabel(widget.step),
                  style: AppTextStyle.labelLarge.copyWith(
                    color: widget.step.isCurrent
                        ? AppColor.primaryColor
                        : widget.step.isDone
                            ? AppColor.black
                            : AppColor.greyText,
                    fontWeight: widget.step.isCurrent || widget.step.isDone
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: widget.compact ? 13 : 14,
                  ),
                ),
                if (widget.step.time != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _formatTime(widget.step.time!),
                    style: AppTextStyle.timestamp.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _stepLabel(BuyerTimelineStep step) {
    if (step.title.isNotEmpty && !step.title.contains('_')) {
      return step.title;
    }
    final key = 'timeline_${step.status}';
    final translated = key.tr;
    return translated != key ? translated : step.status;
  }

  String _formatTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}

class BuyerOrderStatusChip extends StatelessWidget {
  final BuyerOrderStatus status;

  const BuyerOrderStatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.labelKey.tr,
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
}

class BuyerSubOrderTile extends StatelessWidget {
  final BuyerSubOrderModel subOrder;

  const BuyerSubOrderTile({Key? key, required this.subOrder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.greyBorder.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 18,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subOrder.storeName,
                  style: AppTextStyle.labelLarge.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BuyerOrderStatusChip(status: subOrder.status),
            ],
          ),
          const SizedBox(height: 10),
          ...subOrder.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.name}',
                      style: AppTextStyle.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${formatBuyerPrice(item.price * item.quantity)} ${'currency'.tr}',
                    style: AppTextStyle.labelSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              '${'store_total'.tr}: ${formatBuyerPrice(subOrder.totalPrice)} ${'currency'.tr}',
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
