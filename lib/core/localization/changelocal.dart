import 'package:e_commerce/core/constant/apptheme.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {

  Locale? language;

  MyServices myServices = Get.find();

  ThemeData appTheme = themeEnglish;
  bool isDarkMode = false;

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
  }

  void changeThemeMode() {
    isDarkMode = !isDarkMode;
    myServices.sharedPreferences.setBool("isDarkMode", isDarkMode);
    appTheme = getCurrentTheme;
    Get.changeTheme(appTheme);
    update();
  }

  @override
  void onInit() {
    isDarkMode = myServices.sharedPreferences.getBool("isDarkMode") ?? false;
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