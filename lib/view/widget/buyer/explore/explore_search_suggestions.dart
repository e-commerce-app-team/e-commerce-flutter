import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';

class ExploreSearchSuggestions extends StatelessWidget {
  final List<String> recentSearches;
  final List<String> suggestions;
  final ValueChanged<String> onSelectSuggestion;
  final VoidCallback onClearRecent;

  const ExploreSearchSuggestions({
    Key? key,
    required this.recentSearches,
    required this.suggestions,
    required this.onSelectSuggestion,
    required this.onClearRecent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      children: [
        if (suggestions.isEmpty && recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Text('explore_recent_searches'.tr, style: AppTextStyle.heading3),
              const Spacer(),
              GestureDetector(
                onTap: onClearRecent,
                child: Text(
                  'explore_clear'.tr,
                  style: AppTextStyle.labelMedium.copyWith(color: AppColor.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: recentSearches.map((term) {
              return GestureDetector(
                onTap: () => onSelectSuggestion(term),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColor.secondBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColor.greyBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded, size: 15, color: AppColor.grey),
                      const SizedBox(width: 6),
                      Text(term, style: AppTextStyle.labelMedium),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ] else if (suggestions.isNotEmpty) ...[
          Text('explore_suggestions_title'.tr, style: AppTextStyle.heading3),
          const SizedBox(height: 8),
          ...suggestions.map(
            (suggestion) => ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => onSelectSuggestion(suggestion),
              leading: const Icon(Icons.search_rounded, color: AppColor.grey, size: 20),
              title: Text(
                suggestion,
                style: AppTextStyle.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.call_made_rounded, color: AppColor.greyLight, size: 16),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                const Icon(Icons.search_rounded, size: 56, color: AppColor.greyBorder),
                const SizedBox(height: 14),
                Text(
                  'explore_search_empty_hint'.tr,
                  style: AppTextStyle.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
