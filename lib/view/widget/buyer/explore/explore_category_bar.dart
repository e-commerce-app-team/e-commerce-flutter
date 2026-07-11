import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/explore/explore_models.dart';

class ExploreCategoryBar extends StatelessWidget {
  final List<ExploreCategoryModel> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const ExploreCategoryBar({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: selected ? AppColor.mainGradient : null,
                color: selected ? null : AppColor.backgroundcolor,
                borderRadius: BorderRadius.circular(30),
                border: selected ? null : Border.all(color: AppColor.greyBorder, width: 1.2),
                boxShadow: selected ? AppColor.primaryShadow : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 17,
                    color: selected ? Colors.white : AppColor.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name.tr,
                    style: selected ? AppTextStyle.buttonSmall : AppTextStyle.labelMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExploreSubCategoryBar extends StatelessWidget {
  final List<ExploreSubCategoryModel> subCategories;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const ExploreSubCategoryBar({
    Key? key,
    required this.subCategories,
    required this.selectedId,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: subCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sub = subCategories[index];
          final selected = sub.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(sub.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? AppColor.primarySurface : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColor.primaryColor : AppColor.greyBorder,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                sub.name.tr,
                style: AppTextStyle.labelSmall.copyWith(
                  color: selected ? AppColor.primaryColor : AppColor.greyText,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
