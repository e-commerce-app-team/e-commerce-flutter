import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/format_price.dart';
import 'package:e_commerce/data/models/buyer/cart_models.dart';

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
        Row(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 19,
              color: AppColor.primaryColor,
            ),
            const SizedBox(width: 7),
            Text('shipping_options'.tr, style: AppTextStyle.labelLarge),
          ],
        ),
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
                    duration: const Duration(milliseconds: 180),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                  if (option.etaLabel(isArabic).isNotEmpty)
                                    Text(
                                      option.etaLabel(isArabic),
                                      style: AppTextStyle.labelSmall,
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              option.isCostPending
                                  ? (isArabic
                                        ? 'يحدد بعد القبول'
                                        : 'Set after acceptance')
                                  : option.cost! <= 0
                                  ? 'free'.tr
                                  : '${formatPrice(option.cost!)} ${'currency'.tr}',
                              style: AppTextStyle.price.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                        if (option.isCostPending) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 15,
                                color: AppColor.info,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  isArabic
                                      ? 'سيتم تأكيد تكلفة الشحن قبل الدفع.'
                                      : 'Shipping cost is confirmed before payment.',
                                  style: AppTextStyle.labelSmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (option.id == 'pickup' && option.hasStoreLocation)
                          _PickupLocation(
                            option: option,
                            storeName: group.storeName,
                            isArabic: isArabic,
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

class _PickupLocation extends StatelessWidget {
  final ShippingOption option;
  final String storeName;
  final bool isArabic;

  const _PickupLocation({
    required this.option,
    required this.storeName,
    required this.isArabic,
  });

  Future<void> _openMap() async {
    final query = '${option.storeLatitude},${option.storeLongitude}';
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final buyer = Get.find<CartController>().selectedAddress.value;
    final distance = buyer?.latitude == null || buyer?.longitude == null
        ? null
        : _kilometers(
            buyer!.latitude!,
            buyer.longitude!,
            option.storeLatitude!,
            option.storeLongitude!,
          );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.cardBackground.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'الاستلام من' : 'Pickup from',
            style: AppTextStyle.labelSmall,
          ),
          const SizedBox(height: 2),
          Text(storeName, style: AppTextStyle.labelLarge),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColor.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  option.storeAddress!,
                  style: AppTextStyle.bodySmall,
                ),
              ),
            ],
          ),
          if (distance != null) ...[
            const SizedBox(height: 4),
            Text(
              isArabic
                  ? '${distance.toStringAsFixed(1)} كم عن موقعك'
                  : '${distance.toStringAsFixed(1)} km from your location',
              style: AppTextStyle.labelSmall.copyWith(
                color: AppColor.primaryColor,
              ),
            ),
          ],
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _openMap,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(isArabic ? 'عرض الموقع' : 'View location'),
            ),
          ),
        ],
      ),
    );
  }

  double _kilometers(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371.0;
    final dLat = _radians(lat2 - lat1);
    final dLng = _radians(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _radians(double degrees) => degrees * math.pi / 180;
}
