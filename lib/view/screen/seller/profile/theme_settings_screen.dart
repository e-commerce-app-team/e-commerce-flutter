import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/localization/changelocal.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(
      builder: (ctrl) => Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColor.darkSecondBackground : AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('acct_theme_screen_title'.tr, style: AppTextStyle.appBarTitle),
          centerTitle: true,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'acct_theme_screen_sub'.tr,
              style: AppTextStyle.bodyMedium.copyWith(fontSize: 12.5, height: 1.6),
            ),
            const SizedBox(height: 18),
            _ThemeCard(
              title: 'acct_theme_light'.tr,
              desc: 'acct_theme_light_desc'.tr,
              icon: Icons.light_mode_rounded,
              previewColors: const [Colors.white, Color(0xffF8F9FD)],
              accentIconColor: const Color(0xffF39C12),
              isSelected: !ctrl.isDarkMode,
              onTap: () => ctrl.applyTheme(LocaleController.themeLight),
            ),
            const SizedBox(height: 12),
            _ThemeCard(
              title: 'acct_theme_dark'.tr,
              desc: 'acct_theme_dark_desc'.tr,
              icon: Icons.dark_mode_rounded,
              previewColors: const [Color(0xff121212), Color(0xff252525)],
              accentIconColor: const Color(0xff8E8E8E),
              isSelected: ctrl.isDarkMode,
              onTap: () => ctrl.applyTheme(LocaleController.themeDark),
            ),
            const SizedBox(height: 26),
            Text('acct_theme_more_soon'.tr,
                style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
            const SizedBox(height: 4),
            Text('acct_theme_more_soon_desc'.tr,
                style: AppTextStyle.labelSmall.copyWith(fontSize: 11.5)),
            const SizedBox(height: 12),
            Row(children: [
              _ThemePlaceholder(colors: const [Color(0xff6d18d5), Color(0xff8d0ea8)]),
              const SizedBox(width: 10),
              _ThemePlaceholder(colors: const [Color(0xff185FA5), Color(0xff0D47A1)]),
              const SizedBox(width: 10),
              _ThemePlaceholder(colors: const [Color(0xff27AE60), Color(0xff1B5E20)]),
            ]),
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
            ? AppColor.primarySurface
            : (Get.isDarkMode ? AppColor.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColor.primaryColor : AppColor.greyBorder,
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: AppColor.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: previewColors.map((c) => Expanded(child: Container(color: c))).toList(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 15, color: accentIconColor),
                const SizedBox(width: 6),
                Text(title,
                    style: AppTextStyle.labelLarge.copyWith(
                      fontSize: 14,
                      color: isSelected ? AppColor.primaryColor : AppColor.black,
                    )),
              ]),
              const SizedBox(height: 3),
              Text(desc, style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primaryColor : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColor.primaryColor : AppColor.greyBorder,
              width: 1.6,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
              : null,
        ),
      ]),
    ),
  );
}

class _ThemePlaceholder extends StatelessWidget {
  final List<Color> colors;
  const _ThemePlaceholder({required this.colors});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Opacity(
      opacity: 0.45,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.greyBorder),
        ),
        child: const Center(
          child: Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
        ),
      ),
    ),
  );
}
