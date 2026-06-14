import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class InventoryFilterSheet extends StatefulWidget {
  final ProductFilter currentFilter;
  final List<CategoryModel> categories;
  final void Function(ProductFilter) onApply;
  final VoidCallback onReset;
  final ScrollController scrollCtrl;

  const InventoryFilterSheet({
    super.key,
    required this.currentFilter,
    required this.categories,
    required this.onApply,
    required this.onReset,
    required this.scrollCtrl,
  });

  @override
  State<InventoryFilterSheet> createState() => _InventoryFilterSheetState();
}

class _InventoryFilterSheetState extends State<InventoryFilterSheet> {
  late ProductFilter _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50, height: 4,
              decoration: BoxDecoration(
                color: AppColor.greyBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('filter_products'.tr, style: AppTextStyle.heading3),
                TextButton(
                  onPressed: () {
                    setState(() => _temp = const ProductFilter());
                  },
                  child: Text(
                    'reset_filter'.tr,
                    style: AppTextStyle.labelMedium.copyWith(color: AppColor.primaryColor),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _SectionLabel(label: 'category'.tr),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'all'.tr,
                        isSelected: _temp.categoryId == null,
                        onTap: () => setState(() => _temp = _temp.copyWith(clearCategory: true)),
                      ),
                      ...widget.categories.map((cat) => _FilterChip(
                        label: '${cat.name} (${cat.productCount})',
                        isSelected: _temp.categoryId == cat.id,
                        onTap: () => setState(() => _temp = _temp.copyWith(categoryId: cat.id)),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _SectionLabel(label: 'status'.tr),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'all'.tr,
                        isSelected: _temp.status == null,
                        onTap: () => setState(() => _temp = _temp.copyWith(clearStatus: true)),
                      ),
                      _FilterChip(
                        label: 'status_active'.tr,
                        isSelected: _temp.status == 'active',
                        color: AppColor.success,
                        onTap: () => setState(() => _temp = _temp.copyWith(status: 'active')),
                      ),
                      _FilterChip(
                        label: 'status_draft'.tr,
                        isSelected: _temp.status == 'draft',
                        color: AppColor.grey,
                        onTap: () => setState(() => _temp = _temp.copyWith(status: 'draft')),
                      ),
                      _FilterChip(
                        label: 'status_hidden'.tr,
                        isSelected: _temp.status == 'hidden',
                        color: AppColor.warning,
                        onTap: () => setState(() => _temp = _temp.copyWith(status: 'hidden')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _SectionLabel(label: 'stock_level'.tr),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'all'.tr,
                        isSelected: _temp.stock == null,
                        onTap: () => setState(() => _temp = _temp.copyWith(clearStock: true)),
                      ),
                      _FilterChip(
                        label: 'stock_low'.tr,
                        isSelected: _temp.stock == 'low',
                        color: AppColor.warning,
                        onTap: () => setState(() => _temp = _temp.copyWith(stock: 'low')),
                      ),
                      _FilterChip(
                        label: 'stock_out'.tr,
                        isSelected: _temp.stock == 'out',
                        color: AppColor.error,
                        onTap: () => setState(() => _temp = _temp.copyWith(stock: 'out')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _SectionLabel(label: 'sort_by'.tr),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'sort_latest'.tr,
                        isSelected: _temp.sort == 'latest',
                        onTap: () => setState(() => _temp = _temp.copyWith(sort: 'latest')),
                      ),
                      _FilterChip(
                        label: 'sort_price_asc'.tr,
                        isSelected: _temp.sort == 'price_asc',
                        onTap: () => setState(() => _temp = _temp.copyWith(sort: 'price_asc')),
                      ),
                      _FilterChip(
                        label: 'sort_price_desc'.tr,
                        isSelected: _temp.sort == 'price_desc',
                        onTap: () => setState(() => _temp = _temp.copyWith(sort: 'price_desc')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(

              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    widget.onApply(_temp);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('apply_filter'.tr, style: AppTextStyle.buttonMedium.copyWith(fontSize: 15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: AppTextStyle.labelLarge.copyWith(color: AppColor.black, fontWeight: FontWeight.bold),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColor.primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? activeColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? activeColor : AppColor.greyBorder,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected ? AppColor.cardShadow : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: AppTextStyle.chip.copyWith(
                color: isSelected ? Colors.white : AppColor.grey,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}