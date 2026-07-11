import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';

class ExploreToolbar extends StatelessWidget {
  final bool isStoresTab;
  final int resultCount;
  final ValueChanged<bool> onTabChanged;
  final VoidCallback onSortTap;

  const ExploreToolbar({
    Key? key,
    required this.isStoresTab,
    required this.resultCount,
    required this.onTabChanged,
    required this.onSortTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColor.secondBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _SegmentButton(
                  label: 'explore_tab_products'.tr,
                  selected: !isStoresTab,
                  onTap: () => onTabChanged(false),
                ),
                _SegmentButton(
                  label: 'explore_tab_stores'.tr,
                  selected: isStoresTab,
                  onTap: () => onTabChanged(true),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '$resultCount ${'explore_results_count'.tr}',
            style: AppTextStyle.bodySmall,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSortTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.backgroundcolor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.greyBorder),
              ),
              child: const Icon(Icons.swap_vert_rounded, size: 20, color: AppColor.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColor.backgroundcolor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? AppColor.cardShadow : null,
        ),
        child: Text(
          label,
          style: AppTextStyle.labelMedium.copyWith(
            color: selected ? AppColor.primaryColor : AppColor.grey,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ExploreActiveFilterChips extends StatelessWidget {
  final List<Map<String, String>> chips;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const ExploreActiveFilterChips({
    Key? key,
    required this.chips,
    required this.onRemove,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ...chips.map(
            (chip) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _resolveLabel(chip['label'] ?? ''),
                      style: AppTextStyle.labelSmall.copyWith(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => onRemove(chip['key'] ?? ''),
                      child: const Icon(Icons.close_rounded, size: 15, color: AppColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onClearAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Text(
                'reset_filter'.tr,
                style: AppTextStyle.labelSmall.copyWith(
                  color: AppColor.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveLabel(String raw) {
    if (raw.endsWith('+')) return raw;
    return raw.tr;
  }
}
