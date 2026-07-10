import 'package:e_commerce/core/constant/apptheme.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {

  static const String themeLight = 'light';
  static const String themeDark  = 'dark';
  static const List<String> availableThemeKeys = [themeLight, themeDark];

  Locale? language;

  MyServices myServices = Get.find();

  ThemeData appTheme = themeEnglish;
  String themeKey = themeLight;

  bool get isDarkMode => themeKey == themeDark;

  ThemeData get getCurrentTheme {
    String? lang = language?.languageCode ?? myServices.sharedPreferences.getString("lang") ?? Get.deviceLocale!.languageCode;
    if (lang == "ar") {
      return isDarkMode ? themeArabicDark : themeArabic;
    } else {
      return isDarkMode ? themeEnglishDark : themeEnglish;
    }
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
      final legacyIsDark = myServices.sharedPreferences.getBool("isDarkMode") ?? false;
      themeKey = legacyIsDark ? themeDark : themeLight;
    }

    String? sharedPrefLang = myServices.sharedPreferences.getString("lang");
    if (sharedPrefLang == "ar") {
      language = const Locale("ar");
    } else if (sharedPrefLang == "en") {
      language = const Locale("en");
    } else {
      language = Locale(Get.deviceLocale!.languageCode);
    }
    appTheme = getCurrentTheme;
    super.onInit();
  }
}