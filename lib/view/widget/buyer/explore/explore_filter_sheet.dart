import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/functions/format_price.dart';
import 'package:e_commerce/controller/buyer/explore_controller.dart';

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({Key? key}) : super(key: key);

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  final ExploreController controller = Get.find<ExploreController>();

  late RangeValues _priceRange;
  late double _minRating;
  late bool _freeShippingOnly;
  late bool _discountedOnly;
  late bool _inStockOnly;
  late bool _openNowOnly;
  late bool _hasProductsOnly;
  late bool _nearbyOnly;
  late double _radiusKm;

  @override
  void initState() {
    super.initState();
    _priceRange = controller.priceRange;
    _minRating = controller.minRating;
    _freeShippingOnly = controller.freeShippingOnly;
    _discountedOnly = controller.discountedOnly;
    _inStockOnly = controller.inStockOnly;
    _openNowOnly = controller.openNowOnly;
    _hasProductsOnly = controller.hasProductsOnly;
    _nearbyOnly = controller.nearbyOnly;
    _radiusKm = controller.radiusKm;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
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
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('explore_filter_title'.tr, style: AppTextStyle.heading2),
                      const SizedBox(height: 4),
                      Text(
                        controller.isProductsMode
                            ? 'explore_choose_products_body'.tr
                            : 'explore_choose_stores_body'.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.labelMedium.copyWith(color: AppColor.greyText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: AppColor.grey),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColor.greyBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: [
                if (controller.isProductsMode) ...[
                  Text('explore_price_range'.tr, style: AppTextStyle.heading3),
                  const SizedBox(height: 10),
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
                      max: 3000000,
                      divisions: 30,
                      labels: RangeLabels(
                        formatPrice(_priceRange.start),
                        formatPrice(_priceRange.end),
                      ),
                      onChanged: (values) => setState(() => _priceRange = values),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PriceTag(label: formatPrice(_priceRange.start)),
                      _PriceTag(label: formatPrice(_priceRange.end)),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
                Text('explore_category_filter'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(controller.categories.length, (index) {
                    final category = controller.categories[index];
                    final selected = controller.selectedCategoryIndex == index;
                    return ChoiceChip(
                      selected: selected,
                      onSelected: (_) => setState(() {
                        controller.selectedCategoryIndex = index;
                      }),
                      label: Text(
                        category.id == 'all' ? 'all_categories'.tr : category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selectedColor: AppColor.primarySurface,
                      backgroundColor: AppColor.secondBackground,
                      labelStyle: AppTextStyle.labelSmall.copyWith(
                        color: selected ? AppColor.primaryColor : AppColor.greyText,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: selected ? AppColor.primaryColor : AppColor.greyBorder,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                Text('explore_rating_label'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [4, 3, 2, 1].map((stars) {
                    final selected = _minRating == stars.toDouble();
                    return GestureDetector(
                      onTap: () => setState(() => _minRating = selected ? 0 : stars.toDouble()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColor.primarySurface : AppColor.secondBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? AppColor.primaryColor : AppColor.greyBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$stars',
                              style: AppTextStyle.labelMedium.copyWith(
                                color: selected ? AppColor.primaryColor : AppColor.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: selected ? AppColor.primaryColor : AppColor.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'explore_rating_and_up'.tr,
                              style: AppTextStyle.labelSmall.copyWith(
                                color: selected ? AppColor.primaryColor : AppColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                Text('explore_quick_filters'.tr, style: AppTextStyle.heading3),
                const SizedBox(height: 12),
                if (controller.isProductsMode) ...[
                  _SwitchRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'free_shipping'.tr,
                    value: _freeShippingOnly,
                    onChanged: (v) => setState(() => _freeShippingOnly = v),
                  ),
                  Divider(height: 28, color: AppColor.greyBorder),
                  _SwitchRow(
                    icon: Icons.local_offer_outlined,
                    label: 'explore_discount_only'.tr,
                    value: _discountedOnly,
                    onChanged: (v) => setState(() => _discountedOnly = v),
                  ),
                  Divider(height: 28, color: AppColor.greyBorder),
                  _SwitchRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'explore_in_stock_only'.tr,
                    value: _inStockOnly,
                    onChanged: (v) => setState(() => _inStockOnly = v),
                  ),
                ] else ...[
                  _SwitchRow(
                    icon: Icons.storefront_outlined,
                    label: 'explore_open_now_only'.tr,
                    value: _openNowOnly,
                    onChanged: (v) => setState(() => _openNowOnly = v),
                  ),
                  Divider(height: 28, color: AppColor.greyBorder),
                  _SwitchRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'explore_has_products_only'.tr,
                    value: _hasProductsOnly,
                    onChanged: (v) => setState(() => _hasProductsOnly = v),
                  ),
                  Divider(height: 28, color: AppColor.greyBorder),
                  _SwitchRow(
                    icon: Icons.near_me_outlined,
                    label: 'explore_nearby_only'.tr,
                    value: _nearbyOnly,
                    onChanged: (v) => setState(() => _nearbyOnly = v),
                  ),
                  if (_nearbyOnly) ...[
                    const SizedBox(height: 14),
                    Text(
                      '${'explore_radius'.tr}: ${_radiusKm.toStringAsFixed(0)} ${'km_away'.tr}',
                      style: AppTextStyle.labelMedium,
                    ),
                    Slider(
                      value: _radiusKm,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      activeColor: AppColor.primaryColor,
                      onChanged: (value) => setState(() => _radiusKm = value),
                    ),
                  ],
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            decoration: BoxDecoration(
              color: AppColor.backgroundcolor,
              boxShadow: AppColor.bottomNavShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _priceRange = const RangeValues(0, 3000000);
                        _minRating = 0;
                        _freeShippingOnly = false;
                        _discountedOnly = false;
                        _inStockOnly = false;
                        _openNowOnly = false;
                        _hasProductsOnly = false;
                        _nearbyOnly = false;
                        _radiusKm = 10;
                      });
                      controller.resetFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColor.greyBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'reset_filter'.tr,
                      style: AppTextStyle.buttonMedium.copyWith(color: AppColor.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColor.mainGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColor.primaryShadow,
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        controller.applyFilterValues(
                          newPriceRange: _priceRange,
                          newMinRating: _minRating,
                          newFreeShippingOnly: _freeShippingOnly,
                          newDiscountedOnly: _discountedOnly,
                          newInStockOnly: _inStockOnly,
                          newOpenNowOnly: _openNowOnly,
                          newHasProductsOnly: _hasProductsOnly,
                          newNearbyOnly: _nearbyOnly,
                          newRadiusKm: _radiusKm,
                        );
                        Navigator.pop(context);
                      },
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('apply_filter'.tr, style: AppTextStyle.buttonLarge),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  final String label;
  const _PriceTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label ${'currency'.tr}',
        style: AppTextStyle.labelMedium.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColor.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyle.bodyLarge)),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColor.primaryColor,
        ),
      ],
    );
  }
}
