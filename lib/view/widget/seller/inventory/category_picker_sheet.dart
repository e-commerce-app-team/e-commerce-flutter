import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class CategoryPickerSheet extends StatefulWidget {
  final List<CategoryModel> categoryTree;
  final int? selectedId;
  final void Function(CategoryModel) onSelect;

  const CategoryPickerSheet({
    super.key,
    required this.categoryTree,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  final List<CategoryModel> _navStack = [];

  List<CategoryModel> get _currentLevel =>
      _navStack.isEmpty ? widget.categoryTree : _navStack.last.children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                if (_navStack.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _navStack.removeLast()),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColor.primarySurface,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded, size: 13, color: AppColor.primaryColor),
                    ),
                  )
                else
                  const SizedBox(width: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: _navStack.isEmpty
                      ? Text('browse_categories_hint'.tr, style: AppTextStyle.heading3)
                      : Row(
                    children: _navStack.asMap().entries.expand((e) => [
                      Text(e.value.name, style: AppTextStyle.labelLarge.copyWith(
                        color: e.key == _navStack.length - 1 ? AppColor.black : AppColor.greyLight,
                        fontSize: 14,
                      )),
                      if (e.key < _navStack.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(Icons.chevron_right_rounded, size: 13, color: AppColor.greyLight),
                        ),
                    ]).toList(),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close_rounded, color: AppColor.grey, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColor.greyBorder),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _currentLevel.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1, indent: 16, endIndent: 16, color: AppColor.greyBorder,
              ),
              itemBuilder: (_, i) {
                final cat = _currentLevel[i];
                final isSelected = cat.id == widget.selectedId;
                return InkWell(
                  onTap: () {
                    if (cat.isLeaf) {
                      widget.onSelect(cat);
                      Get.back();
                    } else {
                      setState(() => _navStack.add(cat));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    color: isSelected ? AppColor.primarySurface : null,
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColor.primaryColor : AppColor.secondBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            cat.hasChildren ? Icons.folder_outlined : Icons.label_outline_rounded,
                            size: 18,
                            color: isSelected ? Colors.white : AppColor.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat.name, style: AppTextStyle.labelLarge.copyWith(
                                color: isSelected ? AppColor.primaryColor : AppColor.black,
                                fontSize: 14,
                              )),
                              if (cat.hasChildren)
                                Text('${cat.children.length} ${'subcategories'.tr}',
                                    style: AppTextStyle.labelSmall.copyWith(fontSize: 11))
                              else if (cat.productCount > 0)
                                Text('${cat.productCount} ${'products_count'.tr}',
                                    style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_rounded, color: AppColor.primaryColor, size: 18)
                        else if (cat.hasChildren)
                          const Icon(Icons.chevron_right_rounded, color: AppColor.greyLight, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}