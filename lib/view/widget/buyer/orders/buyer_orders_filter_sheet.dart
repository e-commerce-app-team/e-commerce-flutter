import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/functions/format_price.dart';
import 'package:e_commerce/controller/buyer/buyer_orders_controller.dart';
import 'package:e_commerce/data/model/buyer/buyer_orders_model.dart';

class BuyerOrdersFilterSheet extends StatefulWidget {
  const BuyerOrdersFilterSheet({Key? key}) : super(key: key);

  @override
  State<BuyerOrdersFilterSheet> createState() => _BuyerOrdersFilterSheetState();
}

class _BuyerOrdersFilterSheetState extends State<BuyerOrdersFilterSheet> {
  final BuyerOrdersController controller = Get.find<BuyerOrdersController>();

  late BuyerOrderSort _sort;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _sort = controller.sortBy;
    _priceRange = controller.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: const BoxDecoration(
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
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('buyer_orders_filter_title'.tr, style: AppTextStyle.heading2),
                      const SizedBox(height: 4),
                      Text(
                        'buyer_orders_filter_sub'.tr,
                        style: AppTextStyle.labelMedium.copyWith(color: AppColor.greyText),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.resetFilters();
                    Navigator.pop(context);
                  },
                  child: Text('reset_filter'.tr),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColor.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColor.greyBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                Text('buyer_orders_sort_by'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SortChip(
                      label: 'buyer_sort_newest'.tr,
                      selected: _sort == BuyerOrderSort.newest,
                      onTap: () => setState(() => _sort = BuyerOrderSort.newest),
                    ),
                    _SortChip(
                      label: 'buyer_sort_oldest'.tr,
                      selected: _sort == BuyerOrderSort.oldest,
                      onTap: () => setState(() => _sort = BuyerOrderSort.oldest),
                    ),
                    _SortChip(
                      label: 'buyer_sort_price_high'.tr,
                      selected: _sort == BuyerOrderSort.priceHigh,
                      onTap: () => setState(() => _sort = BuyerOrderSort.priceHigh),
                    ),
                    _SortChip(
                      label: 'buyer_sort_price_low'.tr,
                      selected: _sort == BuyerOrderSort.priceLow,
                      onTap: () => setState(() => _sort = BuyerOrderSort.priceLow),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('buyer_orders_price_range'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatPrice(_priceRange.start), style: AppTextStyle.labelMedium),
                    Text(formatPrice(_priceRange.end), style: AppTextStyle.labelMedium),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColor.primaryColor,
                    inactiveTrackColor: AppColor.greyBorder,
                    thumbColor: AppColor.primaryColor,
                    overlayColor: AppColor.primaryColor.withOpacity(0.15),
                    rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                    trackHeight: 4,
                  ),
                  child: RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 5000000,
                    divisions: 50,
                    labels: RangeLabels(
                      formatPrice(_priceRange.start),
                      formatPrice(_priceRange.end),
                    ),
                    onChanged: (v) => setState(() => _priceRange = v),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  controller.applyFilterSheet(sort: _sort, price: _priceRange);
                  Navigator.pop(context);
                },
                child: Text('apply_filter'.tr, style: AppTextStyle.buttonMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColor.primarySurface : AppColor.secondBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColor.primaryColor : AppColor.greyBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.labelMedium.copyWith(
            color: selected ? AppColor.primaryColor : AppColor.greyText,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
