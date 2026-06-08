import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/dashboard_models.dart';

class RecentOrderCard extends StatefulWidget {
  final RecentOrderModel order;
  final int index;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RecentOrderCard({
    super.key,
    required this.order,
    required this.index,
    this.onAccept,
    this.onReject,
  });

  @override
  State<RecentOrderCard> createState() => _RecentOrderCardState();
}

class _RecentOrderCardState extends State<RecentOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 + widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }


  static const Map<String, _StatusConfig> _statusMap = {
    'pending':    _StatusConfig(label: 'status_pending',    bg: AppColor.pendingBg,    text: AppColor.pendingText),
    'processing': _StatusConfig(label: 'status_processing', bg: AppColor.processingBg, text: AppColor.processingText),
    'shipped':    _StatusConfig(label: 'status_shipped',    bg: AppColor.shippedBg,    text: AppColor.shippedText),
    'delivered':  _StatusConfig(label: 'status_delivered',  bg: AppColor.deliveredBg,  text: AppColor.deliveredText),
    'cancelled':  _StatusConfig(label: 'status_cancelled',  bg: AppColor.cancelledBg,  text: AppColor.cancelledText),
    'returned':   _StatusConfig(label: 'status_returned',   bg: AppColor.returnedBg,   text: AppColor.returnedText),
  };

  _StatusConfig get _config =>
      _statusMap[widget.order.status] ??
      const _StatusConfig(label: 'status_pending', bg: Color(0xffF5F5F5), text: Color(0xff757575));

  String _formatPrice(int val) {
    if (val >= 1000) return 'SP ${(val / 1000).toStringAsFixed(0)}k';
    return 'SP $val';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColor.cardShadow,
            border: Border.all(
              color: widget.order.status == 'pending'
                  ? AppColor.primaryColor.withOpacity(0.15)
                  : AppColor.greyBorder,
              width: widget.order.status == 'pending' ? 1.2 : 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffFFE4CC), Color(0xffFFCCA0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: AppColor.primaryColor,
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
                            widget.order.subOrderId,
                            style: AppTextStyle.orderNumber.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          if (widget.order.status == 'pending') ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColor.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.order.buyerName,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColor.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(widget.order.total),
                      style: AppTextStyle.price.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _config.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _config.label.tr,
                        style: AppTextStyle.chip.copyWith(
                          color: _config.text,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderActionButtons extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OrderActionButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          // رفض
          Expanded(
            child: TextButton(
              onPressed: onReject,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColor.greyBorder),
                ),
              ),
              child: Text(
                'reject'.tr,
                style: AppTextStyle.buttonSmall.copyWith(
                  color: AppColor.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // قبول
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'accept'.tr,
                style: AppTextStyle.buttonSmall.copyWith(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _StatusConfig {
  final String label;
  final Color bg;
  final Color text;
  const _StatusConfig({
    required this.label,
    required this.bg,
    required this.text,
  });
}
