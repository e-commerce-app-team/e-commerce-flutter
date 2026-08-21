import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/controller/buyer/buyer_orders_controller.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';

class BuyerReturnRequestSheet extends StatefulWidget {
  final BuyerOrderModel order;

  const BuyerReturnRequestSheet({Key? key, required this.order}) : super(key: key);

  static Future<void> show(BuyerOrderModel order) {
    return Get.bottomSheet(
      BuyerReturnRequestSheet(order: order),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<BuyerReturnRequestSheet> createState() => _BuyerReturnRequestSheetState();
}

class _BuyerReturnRequestSheetState extends State<BuyerReturnRequestSheet> {
  final _descCtrl = TextEditingController();
  String? _reason;
  bool _submitting = false;

  static const _reasonKeys = [
    'return_reason_damaged',
    'return_reason_wrong_item',
    'return_reason_missing',
    'return_reason_quality',
    'return_reason_other',
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null) {
      Get.snackbar('error'.tr, 'buyer_return_reason_required'.tr);
      return;
    }
    if (_descCtrl.text.trim().length < 10) {
      Get.snackbar('error'.tr, 'buyer_return_desc_required'.tr);
      return;
    }
    if (_submitting) return;
    setState(() => _submitting = true);

    await Get.find<BuyerOrdersController>().submitReturnRequest(
      orderId: widget.order.id,
      reason: _reason!,
      description: _descCtrl.text.trim(),
    );

    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: AppColor.backgroundcolor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('buyer_report_problem'.tr, style: AppTextStyle.heading2),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close_rounded, color: AppColor.grey),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColor.greyBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text('buyer_return_reason_label'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 10),
                ..._reasonKeys.map(
                  (key) => RadioListTile<String>(
                    value: key,
                    groupValue: _reason,
                    activeColor: AppColor.primaryColor,
                    contentPadding: EdgeInsets.zero,
                    title: Text(key.tr, style: AppTextStyle.bodyMedium),
                    onChanged: (v) => setState(() => _reason = v),
                  ),
                ),
                const SizedBox(height: 16),
                Text('buyer_return_desc_label'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'buyer_return_desc_hint'.tr,
                    filled: true,
                    fillColor: AppColor.secondBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('buyer_return_photos_label'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 8),
                Container(
                  height: 88,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.secondBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.greyBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: AppColor.grey),
                      const SizedBox(height: 4),
                      Text(
                        'buyer_return_photos_hint'.tr,
                        style: AppTextStyle.labelSmall.copyWith(color: AppColor.greyText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
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
                    : Text('buyer_submit_return'.tr, style: AppTextStyle.buttonMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
