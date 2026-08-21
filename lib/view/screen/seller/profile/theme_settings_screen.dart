import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/localization/changelocal.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/constant/apptheme.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'acct_theme_screen_title'.tr,
            style: AppTextStyle.appBarTitle,
          ),
          centerTitle: true,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'acct_theme_screen_sub'.tr,
              style: AppTextStyle.bodyMedium.copyWith(
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            ...appThemeOptions.asMap().entries.expand((entry) {
              final option = entry.value;
              return [
                _ThemeCard(
                  title: option.nameKey.tr,
                  desc: option.descriptionKey.tr,
                  icon: option.icon,
                  previewColors: [
                    option.isDark ? option.lightPreview : Colors.white,
                    option.isDark ? option.darkPreview : option.lightPreview,
                  ],
                  accentIconColor: option.primary,
                  isSelected: ctrl.themeKey == option.key,
                  onTap: () => ctrl.applyTheme(option.key),
                ),
                if (entry.key < appThemeOptions.length - 1)
                  const SizedBox(height: 12),
              ];
            }),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title, desc;
  final IconData icon;
  final List<Color> previewColors;
  final Color accentIconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.previewColors,
    required this.accentIconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? accentIconColor.withOpacity(0.1)
            : (Get.isDarkMode ? AppColor.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? accentIconColor : AppColor.greyBorder,
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: AppColor.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: previewColors
                  .map((c) => Expanded(child: Container(color: c)))
                  .toList(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 15, color: accentIconColor),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: AppTextStyle.labelLarge.copyWith(
                        fontSize: 14,
                        color: isSelected ? accentIconColor : AppColor.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected ? accentIconColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? accentIconColor : AppColor.greyBorder,
                width: 1.6,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : null,
          ),
        ],
      ),
    ),
  );
}
