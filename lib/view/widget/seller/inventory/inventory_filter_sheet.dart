import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class InventoryFilterSheet extends StatefulWidget {
  final ProductFilter currentFilter;
  final List<CategoryModel> categoryTree;
  final void Function(ProductFilter) onApply;
  final VoidCallback onReset;
  final ScrollController scrollCtrl;

  const InventoryFilterSheet({
    super.key,
    required this.currentFilter,
    required this.categoryTree,
    required this.onApply,
    required this.onReset,
    required this.scrollCtrl,
  });

  @override
  State<InventoryFilterSheet> createState() => _InventoryFilterSheetState();
}

class _InventoryFilterSheetState extends State<InventoryFilterSheet> {
  late ProductFilter _temp;
  final List<CategoryModel> _navStack = [];

  @override
  void initState() {
    super.initState();
    _temp = widget.currentFilter;
  }

  List<CategoryModel> get _currentLevel =>
      _navStack.isEmpty ? widget.categoryTree : _navStack.last.children;

  CategoryModel? _findById(int id, List<CategoryModel> cats) {
    for (final cat in cats) {
      if (cat.id == id) return cat;
      final found = _findById(id, cat.children);
      if (found != null) return found;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCat = _temp.categoryId != null
        ? _findById(_temp.categoryId!, widget.categoryTree)
        : null;

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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Text('filter_products'.tr, style: AppTextStyle.heading3),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _temp = const ProductFilter();
                    _navStack.clear();
                  }),
                  child: Text('reset_filter'.tr,
                      style: AppTextStyle.labelMedium
                          .copyWith(color: AppColor.primaryColor)),
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
                  _CategoryDrillDown(
                    navStack: _navStack,
                    currentLevel: _currentLevel,
                    selectedCat: selectedCat,
                    onPush: (cat) {
                      if (cat.isLeaf) {
                        setState(() => _temp = _temp.copyWith(categoryId: cat.id));
                      } else {
                        setState(() => _navStack.add(cat));
                      }
                    },
                    onPop: () => setState(() => _navStack.removeLast()),
                    onClear: () => setState(() {
                      _temp = _temp.copyWith(clearCategory: true);
                    }),
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel(label: 'status'.tr),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _FChip(label: 'all'.tr, isSelected: _temp.status == null, onTap: () => setState(() => _temp = _temp.copyWith(clearStatus: true))),
                    _FChip(label: 'status_active'.tr, isSelected: _temp.status == 'active', color: AppColor.success, onTap: () => setState(() => _temp = _temp.copyWith(status: 'active'))),
                    _FChip(label: 'status_draft'.tr, isSelected: _temp.status == 'draft', color: AppColor.grey, onTap: () => setState(() => _temp = _temp.copyWith(status: 'draft'))),
                    _FChip(label: 'status_hidden'.tr, isSelected: _temp.status == 'hidden', color: AppColor.warning, onTap: () => setState(() => _temp = _temp.copyWith(status: 'hidden'))),
                  ]),
                  const SizedBox(height: 16),
                  _SectionLabel(label: 'stock_level'.tr),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _FChip(label: 'all'.tr, isSelected: _temp.stock == null, onTap: () => setState(() => _temp = _temp.copyWith(clearStock: true))),
                    _FChip(label: 'stock_low'.tr, isSelected: _temp.stock == 'low', color: AppColor.warning, onTap: () => setState(() => _temp = _temp.copyWith(stock: 'low'))),
                    _FChip(label: 'stock_out'.tr, isSelected: _temp.stock == 'out', color: AppColor.error, onTap: () => setState(() => _temp = _temp.copyWith(stock: 'out'))),
                  ]),
                  const SizedBox(height: 16),
                  _SectionLabel(label: 'sort_by'.tr),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _FChip(label: 'sort_latest'.tr, isSelected: _temp.sort == 'latest', onTap: () => setState(() => _temp = _temp.copyWith(sort: 'latest'))),
                    _FChip(label: 'sort_price_asc'.tr, isSelected: _temp.sort == 'price_asc', onTap: () => setState(() => _temp = _temp.copyWith(sort: 'price_asc'))),
                    _FChip(label: 'sort_price_desc'.tr, isSelected: _temp.sort == 'price_desc', onTap: () => setState(() => _temp = _temp.copyWith(sort: 'price_desc'))),
                  ]),
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
                width: double.infinity, height: 50,
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
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('apply_filter'.tr, style: AppTextStyle.buttonMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDrillDown extends StatelessWidget {
  final List<CategoryModel> navStack;
  final List<CategoryModel> currentLevel;
  final CategoryModel? selectedCat;
  final void Function(CategoryModel) onPush;
  final VoidCallback onPop;
  final VoidCallback onClear;

  const _CategoryDrillDown({
    required this.navStack,
    required this.currentLevel,
    required this.selectedCat,
    required this.onPush,
    required this.onPop,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.secondBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (navStack.isNotEmpty) ...[
            InkWell(
              onTap: onPop,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_rounded, size: 12, color: AppColor.primaryColor),
                    const SizedBox(width: 6),
                    ...navStack.map((c) => Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(c.name, style: AppTextStyle.labelSmall.copyWith(color: AppColor.primaryColor, fontSize: 11)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 3), child: Icon(Icons.chevron_right_rounded, size: 12, color: AppColor.greyLight)),
                    ])),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColor.greyBorder),
          ],
          if (selectedCat != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Wrap(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColor.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_rounded, size: 11, color: AppColor.primaryColor),
                    const SizedBox(width: 4),
                    Text(selectedCat!.name, style: AppTextStyle.chip.copyWith(color: AppColor.primaryColor, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    GestureDetector(onTap: onClear, child: const Icon(Icons.close_rounded, size: 11, color: AppColor.primaryColor)),
                  ]),
                ),
              ]),
            ),
          if (currentLevel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: currentLevel.map((cat) {
                  final isSelected = cat.id == selectedCat?.id;
                  return GestureDetector(
                    onTap: () => onPush(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColor.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColor.primaryColor : AppColor.greyBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(cat.name, style: AppTextStyle.chip.copyWith(
                          color: isSelected ? Colors.white : AppColor.black,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        )),
                        if (cat.productCount > 0 && !cat.hasChildren) ...[
                          const SizedBox(width: 4),
                          Text('${cat.productCount}', style: AppTextStyle.badge.copyWith(color: isSelected ? Colors.white70 : AppColor.greyLight, fontSize: 9)),
                        ],
                        if (cat.hasChildren) ...[
                          const SizedBox(width: 3),
                          Icon(Icons.chevron_right_rounded, size: 13, color: isSelected ? Colors.white70 : AppColor.greyLight),
                        ],
                      ]),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('no_subcategories'.tr,
                    style: AppTextStyle.bodySmall.copyWith(color: AppColor.greyLight)),
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
  Widget build(BuildContext context) => Text(label,
      style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.bold));
}

class _FChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;
  const _FChip({required this.label, required this.isSelected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final ac = color ?? AppColor.primaryColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected ? ac : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? ac : AppColor.greyBorder, width: isSelected ? 1.5 : 1),
        boxShadow: isSelected ? AppColor.cardShadow : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(label, style: AppTextStyle.chip.copyWith(
              color: isSelected ? Colors.white : AppColor.grey,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            )),
          ),
        ),
      ),
    );
  }
}