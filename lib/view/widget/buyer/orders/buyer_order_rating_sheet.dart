import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/controller/buyer/buyer_orders_controller.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';

class BuyerOrderRatingSheet extends StatefulWidget {
  final BuyerOrderModel order;

  const BuyerOrderRatingSheet({Key? key, required this.order}) : super(key: key);

  static Future<void> show(BuyerOrderModel order) {
    return Get.bottomSheet(
      BuyerOrderRatingSheet(order: order),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }


  @override
  State<BuyerOrderRatingSheet> createState() => _BuyerOrderRatingSheetState();
}

class _BuyerOrderRatingSheetState extends State<BuyerOrderRatingSheet> {
  final _commentCtrl = TextEditingController();
  double _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final ctrl = Get.find<BuyerOrdersController>();
    final storeId = widget.order.subOrders.isNotEmpty
        ? widget.order.subOrders.first.sellerId
        : '';

    final ok = await ctrl.submitRating(
      orderId: widget.order.id,
      storeId: storeId,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
    );

    if (ok && mounted) Get.back();
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColor.backgroundcolor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.greyBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('buyer_rate_order_title'.tr, style: AppTextStyle.heading2),
            const SizedBox(height: 6),
            Text(
              'buyer_rate_order_sub'.tr,
              style: AppTextStyle.bodyMedium.copyWith(color: AppColor.greyText),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = star.toDouble()),
                    icon: Icon(
                      star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColor.primaryColor,
                      size: 36,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'buyer_rate_comment_hint'.tr,
                filled: true,
                fillColor: AppColor.secondBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'buyer_rate_photos_optional'.tr,
              style: AppTextStyle.labelSmall.copyWith(color: AppColor.greyText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('buyer_submit_rating'.tr, style: AppTextStyle.buttonMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
