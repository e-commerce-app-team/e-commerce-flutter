import 'package:e_commerce/core/constant/apptheme.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  static const String themeLight = 'orange_light';
  static const String themeDark = 'orange_dark';
  static final List<String> availableThemeKeys = appThemeOptions
      .map((option) => option.key)
      .toList();

  Locale? language;

  MyServices myServices = Get.find();

  ThemeData appTheme = themeEnglish;
  String themeKey = themeLight;

  AppThemeOption get selectedTheme => appThemeOptions.firstWhere(
    (option) => option.key == themeKey,
    orElse: () => appThemeOptions.first,
  );

  bool get isDarkMode => selectedTheme.isDark;

  ThemeData get getCurrentTheme {
    String? lang =
        language?.languageCode ??
        myServices.sharedPreferences.getString("lang") ??
        Get.deviceLocale!.languageCode;
    return buildAppTheme(
      option: selectedTheme,
      fontFamily: lang == "ar" ? "Cairo" : "PlayfairDisplay",
    );
  }

  changeLang(String langcode) {
    Locale locale = Locale(langcode);
    myServices.sharedPreferences.setString("lang", langcode);
    appTheme = getCurrentTheme;
    Get.changeTheme(appTheme);
    Get.updateLocale(locale);
    update();
  }

  void applyTheme(String key) {
    if (!availableThemeKeys.contains(key)) return;
    themeKey = key;
    myServices.sharedPreferences.setString("themeKey", key);
    appTheme = getCurrentTheme;
    Get.changeTheme(appTheme);
    update();
  }

  @override
  void onInit() {
    final savedThemeKey = myServices.sharedPreferences.getString("themeKey");
    if (savedThemeKey != null && availableThemeKeys.contains(savedThemeKey)) {
      themeKey = savedThemeKey;
    } else {
      final legacyIsDark =
          myServices.sharedPreferences.getBool("isDarkMode") ?? false;
      final legacyTheme = myServices.sharedPreferences.getString("themeKey");
      themeKey = legacyTheme == "dark" || legacyIsDark ? themeDark : themeLight;
    }

    String? sharedPrefLang = myServices.sharedPreferences.getString("lang");
    if (sharedPrefLang == "ar") {
      language = const Locale("ar");
    } else if (sharedPrefLang == "en") {
      language = const Locale("en");
    } else {
      final deviceLang = Get.deviceLocale?.languageCode;
      language = deviceLang == "ar" ? const Locale("ar") : const Locale("en");
    }
    appTheme = getCurrentTheme;
    super.onInit();
  }
}
