import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/localization/changelocal.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

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
          title: Text('acct_lang_screen_title'.tr, style: AppTextStyle.appBarTitle),
          centerTitle: true,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'acct_lang_screen_sub'.tr,
              style: AppTextStyle.bodyMedium.copyWith(fontSize: 12.5, height: 1.6),
            ),
            const SizedBox(height: 18),
            _LangCard(
              flag: '🇸🇾',
              title: 'acct_lang_arabic'.tr,
              nativeLabel: 'acct_lang_arabic_native'.tr,
              isSelected: (ctrl.language?.languageCode ?? 'ar') == 'ar',
              onTap: () => _apply(ctrl, 'ar'),
            ),
            const SizedBox(height: 12),
            _LangCard(
              flag: '🇬🇧',
              title: 'acct_lang_english'.tr,
              nativeLabel: 'acct_lang_english_native'.tr,
              isSelected: ctrl.language?.languageCode == 'en',
              onTap: () => _apply(ctrl, 'en'),
            ),
          ],
        ),
      ),
    );
  }

  void _apply(LocaleController ctrl, String code) {
    if (ctrl.language?.languageCode == code) return;
    ctrl.changeLang(code);
    Get.snackbar(
      'acct_lang_applied'.tr,
      '',
      backgroundColor: AppColor.successLight,
      colorText: AppColor.successDark,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}

class _LangCard extends StatelessWidget {
  final String flag, title, nativeLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangCard({
    required this.flag,
    required this.title,
    required this.nativeLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
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
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : AppColor.secondBackground,
            shape: BoxShape.circle,
          ),
          child: Text(flag, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nativeLabel,
                  style: AppTextStyle.labelLarge.copyWith(
                    fontSize: 15,
                    color: isSelected ? AppColor.primaryColor : AppColor.black,
                  )),
              const SizedBox(height: 2),
              Text(title, style: AppTextStyle.labelSmall),
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
