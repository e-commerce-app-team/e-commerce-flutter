import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/models/buyer/cart_models.dart';
import 'package:e_commerce/view/screen/buyer/cart/address/buyer_address_map_screen.dart';

class BuyerAddressSheet extends GetView<CartController> {
  const BuyerAddressSheet({super.key});

  static Future<void> show() async {
    final ctrl = Get.find<CartController>();
    await ctrl.loadAddresses();
    await Get.bottomSheet(
      const BuyerAddressSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text('saved_addresses'.tr, style: AppTextStyle.heading2),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final draft = await Get.to<BuyerAddress?>(
                      () => const BuyerAddressMapScreen(),
                    );
                    if (draft != null) {
                      await controller.addAddress(draft);
                    }
                  },
                  icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                  label: Text('add_new_address'.tr),
                ),
              ],
            ),
          ),
          Flexible(
            child: Obx(() {
              if (controller.addresses.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 48,
                        color: AppColor.greyLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'no_saved_addresses'.tr,
                        style: AppTextStyle.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: controller.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final address = controller.addresses[index];
                  final selected =
                      controller.selectedAddress.value?.id == address.id;

                  return InkWell(
                    onTap: () async {
                      await controller.selectAddress(address);
                      if (Get.isBottomSheetOpen == true) Get.back();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColor.primarySurface
                            : AppColor.secondBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColor.primaryColor
                              : AppColor.greyBorder,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.grey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      address.title,
                                      style: AppTextStyle.labelLarge,
                                    ),
                                    if (address.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'default_address'.tr,
                                        style: AppTextStyle.chip.copyWith(
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.details,
                                  style: AppTextStyle.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
