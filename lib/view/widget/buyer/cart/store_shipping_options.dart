import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/models/buyer/cart_models.dart';
import 'package:e_commerce/core/functions/format_price.dart';

class StoreShippingOptions extends GetView<CartController> {
  final StoreCartGroup group;

  const StoreShippingOptions({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    if (group.shippingOptions.isEmpty) return const SizedBox.shrink();

    final isArabic = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('shipping_options'.tr, style: AppTextStyle.labelLarge),
        const SizedBox(height: 8),
        Obx(() {
          final selectedId =
              controller.selectedShipping[group.sellerId] ??
                  group.shippingOptions.first.id;

          return Column(
            children: group.shippingOptions.map((option) {
              final isSelected = option.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () =>
                      controller.selectShipping(group.sellerId, option.id),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primarySurface
                          : AppColor.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primaryColor
                            : AppColor.greyBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? AppColor.primaryColor
                              : AppColor.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label(isArabic),
                                style: AppTextStyle.labelLarge,
                              ),
                              Text(
                                option.etaLabel(isArabic),
                                style: AppTextStyle.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          option.cost <= 0
                              ? 'free'.tr
                              : '${formatPrice(option.cost)} ${'currency'.tr}',
                          style: AppTextStyle.price.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
