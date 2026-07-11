import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/gradient_hairline.dart';

/// Horizontal department shortcuts under the hero banner. The selected
/// category gets a filled ring and a small copper hairline underline —
/// the same accent used for section eyebrows — instead of a generic
/// solid-fill chip, so the selection state feels like part of the same
/// visual language rather than a bolted-on Material default.
class CategoriesBar extends StatelessWidget {
  final List<BuyerCategoryItem> categories;
  final String? selectedId;
  final ValueChanged<BuyerCategoryItem>? onSelected;

  const CategoriesBar({
    Key? key,
    required this.categories,
    this.selectedId,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedId;
          return GestureDetector(
            onTap: onSelected == null ? null : () => onSelected!(category),
            child: SizedBox(
              width: 66,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColor.primarySurface
                          : AppColor.secondBackground,
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primaryColor
                            : Colors.transparent,
                        width: 1.6,
                      ),
                    ),
                    child: Icon(
                      category.icon,
                      size: 26,
                      color: isSelected ? AppColor.primaryColor : AppColor.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: isSelected
                        ? AppTextStyle.labelMedium.copyWith(
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.w700,
                          )
                        : AppTextStyle.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  if (isSelected) const GradientHairline(width: 14, height: 2.5),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
