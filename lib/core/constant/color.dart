import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColor {
  static ThemeData get _theme => Get.theme;

  // ******** Primary Palette*******************************************************
  static Color get primaryColor => _theme.colorScheme.primary;
  static Color get primaryLight => _theme.colorScheme.primaryContainer;
  static Color get primaryDark => _theme.colorScheme.primary;
  static Color get primarySurface => _theme.colorScheme.primaryContainer;

  // ****** Neutrals ************************************************************
  static Color get black => _theme.colorScheme.onSurface;
  static const Color white = Color(0xffefeaea);
  static Color get grey => _theme.colorScheme.onSurfaceVariant;
  static Color get greyLight => _theme.colorScheme.outline;
  static Color get greyBorder => _theme.dividerColor;

  //*****Backgrounds *************************************************************
  static Color get backgroundcolor => _theme.colorScheme.surface;
  static Color get secondBackground => _theme.scaffoldBackgroundColor;
  static Color get cardBackground => _theme.cardColor;

  // **** Dark Mode Backgrounds******************************************************
  static Color get darkBackground => _theme.colorScheme.surface;
  static Color get darkSecondBackground => _theme.scaffoldBackgroundColor;
  static Color get darkCard => _theme.cardColor;
  static Color get darkBorder => _theme.dividerColor;

  // **** Semantic Colors*************************************************************
  static const Color success = Color(0xff27AE60);
  static const Color successLight = Color(0xffE8F8F0);
  static const Color successDark = Color(0xff1B5E20);

  static const Color warning = Color(0xffF39C12);
  static const Color warningLight = Color(0xffFFF8E1);
  static const Color warningDark = Color(0xffE65100);

  static const Color error = Color(0xffE74C3C);
  static const Color errorLight = Color(0xffFEECEC);
  static const Color errorDark = Color(0xffB71C1C);

  static const Color info = Color(0xff185FA5);
  static const Color infoLight = Color(0xffE6F1FB);
  static const Color infoDark = Color(0xff0D47A1);

  //  ##Stats Card Colors &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  static const Color statRevenue = Color(0xffFF6300);
  static const Color statRevenueLight = Color(0xffFFF0E6);

  static const Color statOrders = Color(0xff553C9A);
  static const Color statOrdersLight = Color(0xffEEEDFE);

  static const Color statViews = Color(0xff185FA5);
  static const Color statViewsLight = Color(0xffE6F1FB);

  static const Color statAvg = Color(0xff27AE60);
  static const Color statAvgLight = Color(0xffE8F8F0);

  // %%%%% Gradients%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  static LinearGradient get mainGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryColor],
  );

  static LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryColor, primaryDark],
    stops: [0.0, 0.55, 1.0],
  );

  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_theme.colorScheme.surface, primarySurface],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [Color(0xffEBEBF4), Color(0xffF4F4F4), Color(0xffEBEBF4)],
    stops: [0.0, 0.5, 1.0],
  );

  // ############### Shadows %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColor.black.withOpacity(0.05),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get bottomNavShadow => [
    BoxShadow(
      color: AppColor.black.withOpacity(0.05),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, -4),
    ),
  ];

  //  ********************Snackbar##################
  static const Color snackbarSuccessBg = Color(0xFFF1FDF5);
  static const Color snackbarSuccessText = Color(0xFF2E7D32);
  static const Color snackbarErrorBg = Color(0xFFFFF4F4);
  static const Color snackbarErrorText = Color(0xFFD32F2F);

  // ألوان حالات الطلب
  static const Color pendingBg = Color(0xffFFF3E0);
  static const Color pendingText = Color(0xffE65100);

  static const Color processingBg = Color(0xffE3F2FD);
  static const Color processingText = Color(0xff1565C0);

  static const Color shippedBg = Color(0xffEEEDFE);
  static const Color shippedText = Color(0xff553C9A);

  static const Color deliveredBg = Color(0xffE8F8F0);
  static const Color deliveredText = Color(0xff1B5E20);

  static const Color cancelledBg = Color(0xffFEECEC);
  static const Color cancelledText = Color(0xffB71C1C);

  static const Color returnedBg = Color(0xffFFF8E1);
  static const Color returnedText = Color(0xffF39C12);

  //*************************
  static Color get textPrimary => _theme.colorScheme.onSurface;
  static const Color danger = Color(0xFFEF4444);
  static Color get shadow => _theme.brightness == Brightness.dark
      ? Colors.black.withOpacity(0.25)
      : const Color(0x0D000000);
  static Color get greyText => _theme.colorScheme.onSurfaceVariant;
  static Color get backgroundScaffold => _theme.scaffoldBackgroundColor;
}
