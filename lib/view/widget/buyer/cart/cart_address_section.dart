import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/view/screen/buyer/cart/address/buyer_address_sheet.dart';

class CartAddressSection extends GetView<CartController> {
  const CartAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final address = controller.selectedAddress.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColor.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: AppColor.primaryColor),
                const SizedBox(width: 8),
                Text('delivery_address'.tr, style: AppTextStyle.heading3),
                const Spacer(),
                TextButton(
                  onPressed: () => BuyerAddressSheet.show(),
                  child: Text(
                    address == null ? 'add_address'.tr : 'change'.tr,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            if (address == null)
              Text('no_address_selected'.tr, style: AppTextStyle.bodyMedium)
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(address.title, style: AppTextStyle.labelLarge),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'default_address'.tr,
                              style: AppTextStyle.badge,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(address.details, style: AppTextStyle.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('driver_notes'.tr, style: AppTextStyle.inputLabel),
              const SizedBox(height: 6),
              TextField(
                controller: controller.driverNotesCtrl,
                maxLines: 2,
                style: AppTextStyle.inputText,
                decoration: InputDecoration(
                  hintText: 'driver_notes_hint'.tr,
                  hintStyle: AppTextStyle.inputHint,
                  filled: true,
                  fillColor: AppColor.secondBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
