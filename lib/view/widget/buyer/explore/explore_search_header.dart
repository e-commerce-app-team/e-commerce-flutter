import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';

class ExploreSearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final int activeFilterCount;
  final bool isSearchFocused;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCancel;

  const ExploreSearchHeader({
    Key? key,
    required this.searchController,
    required this.focusNode,
    required this.activeFilterCount,
    required this.isSearchFocused,
    required this.onFilterTap,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 22),
      decoration: BoxDecoration(
        gradient: AppColor.mainGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: AppColor.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSearchFocused) ...[
            Text(
              'explore_title'.tr,
              style: AppTextStyle.displaySmall.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'explore_subtitle'.tr,
              style: AppTextStyle.bodyMedium.copyWith(color: Colors.white.withOpacity(0.85)),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: AppColor.cardShadow,
                  ),
                  child: TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.search,
                    style: AppTextStyle.inputText,
                    decoration: InputDecoration(
                      hintText: 'explore_search_hint'.tr,
                      hintStyle: AppTextStyle.inputHint,
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColor.primaryColor, size: 24),
                      prefixIconConstraints: const BoxConstraints(minWidth: 46),
                      suffixIcon: searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColor.grey, size: 20),
                              onPressed: () {
                                searchController.clear();
                                onChanged('');
                              },
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (isSearchFocused)
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'cancel'.tr,
                    style: AppTextStyle.buttonMedium.copyWith(color: Colors.white),
                  ),
                )
              else
                GestureDetector(
                  onTap: onFilterTap,
                  child: Container(
                    width: 50,
                    height: 50,
                    clipBehavior: Clip.none,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Center(child: Icon(Icons.tune_rounded, color: Colors.white, size: 22)),
                        if (activeFilterCount > 0)
                          Positioned.directional(
                            textDirection: direction,
                            top: -2,
                            end: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColor.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                '$activeFilterCount',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.badge.copyWith(fontSize: 9),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
