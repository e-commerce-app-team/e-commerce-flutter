import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import '../shared/buyer_network_image.dart';
import '../shared/gradient_hairline.dart';

/// NEXUS Categories — Glassmorphism scrolling pills.
///
/// Unlike the standard round-icon approach, each category is a wide
/// horizontal pill card with:
///   • A unique tinted gradient background per category
///   • Large icon centered in a frosted container
///   • Category name below
///   • Selected state: orange glow border + scale animation
///
/// This creates a horizontal "magazine shelf" feel — each category feels
/// like its own brand identity rather than a generic icon list.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const GradientHairline(width: 16, height: 3),
              const SizedBox(width: 8),
              Text(
                'تسوّق حسب الفئة',
                style: AppTextStyle.labelMedium.copyWith(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == selectedId;
              return _CategoryPill(
                category: category,
                isSelected: isSelected,
                onTap: onSelected == null ? null : () => onSelected!(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final BuyerCategoryItem category;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryPill({
    required this.category,
    required this.isSelected,
    this.onTap,
  });

  /// Parse hex color string (#RRGGBB) → Color, fallback to primaryColor
  Color _parseColor(String? hex) {
    if (hex == null || hex.length < 7) return AppColor.primaryColor;
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return AppColor.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _parseColor(category.colorHex);
    final lightColor = baseColor.withOpacity(0.12);
    final midColor = baseColor.withOpacity(0.07);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 78,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isSelected ? baseColor.withOpacity(0.18) : lightColor,
              isSelected ? baseColor.withOpacity(0.08) : midColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? baseColor : baseColor.withOpacity(0.25),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppColor.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? baseColor : baseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BuyerNetworkImage(url: category.imageUrl!),
                    )
                  : Icon(
                      category.icon ?? Icons.category_outlined,
                      size: 24,
                      color: isSelected ? Colors.white : baseColor,
                    ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyle.labelMedium.copyWith(
                color: isSelected ? baseColor : AppColor.black,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
