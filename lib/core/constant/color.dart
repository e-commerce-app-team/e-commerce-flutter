import 'package:flutter/material.dart';

class AppColor {
  // ******** Primary Palette*******************************************************
  static const Color primaryColor = Color(0xffcc5813);
  static const Color primaryLight = Color(0xffFF8C42);
  static const Color primaryDark  = Color(0xffCC4F00);
  static const Color primarySurface = Color(0xffFFF0E6);

  // ****** Neutrals ************************************************************
  static const Color black      = Color(0xff1A1A1A);
  static const Color white      = Color(0xffefeaea);
  static const Color grey       = Color(0xff8E8E8E);
  static const Color greyLight  = Color(0xffC7C7CC);
  static const Color greyBorder = Color(0xffE5E5EA);

  //*****Backgrounds *************************************************************
  static const Color backgroundcolor  = Color(0xffFFFFFF);
  static const Color secondBackground = Color(0xffF8F9FD);
  static const Color cardBackground   = Color(0xffFFFFFF);

  // **** Dark Mode Backgrounds******************************************************
  static const Color darkBackground      = Color(0xff121212);
  static const Color darkSecondBackground = Color(0xff1E1E1E);
  static const Color darkCard            = Color(0xff252525);
  static const Color darkBorder         = Color(0xff333333);

  // **** Semantic Colors*************************************************************
  static const Color success      = Color(0xff27AE60);
  static const Color successLight = Color(0xffE8F8F0);
  static const Color successDark  = Color(0xff1B5E20);

  static const Color warning      = Color(0xffF39C12);
  static const Color warningLight = Color(0xffFFF8E1);
  static const Color warningDark  = Color(0xffE65100);

  static const Color error      = Color(0xffE74C3C);
  static const Color errorLight = Color(0xffFEECEC);
  static const Color errorDark  = Color(0xffB71C1C);

  static const Color info      = Color(0xff185FA5);
  static const Color infoLight = Color(0xffE6F1FB);
  static const Color infoDark  = Color(0xff0D47A1);


  //  ##Stats Card Colors &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  static const Color statRevenue      = Color(0xffFF6300);
  static const Color statRevenueLight = Color(0xffFFF0E6);

  static const Color statOrders      = Color(0xff553C9A);
  static const Color statOrdersLight = Color(0xffEEEDFE);

  static const Color statViews      = Color(0xff185FA5);
  static const Color statViewsLight = Color(0xffE6F1FB);

  static const Color statAvg      = Color(0xff27AE60);
  static const Color statAvgLight = Color(0xffE8F8F0);

  // %%%%% Gradients%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryColor],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xffd67128), Color(0xffe36a23), Color(0xfff86506)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xffFFFFFF), Color(0xffFFF0E6)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0xffEBEBF4),
      Color(0xffF4F4F4),
      Color(0xffEBEBF4),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ############### Shadows %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color:AppColor.black.withOpacity(0.05),
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
      color:AppColor.black.withOpacity(0.05),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, -4),
    ),
  ];

  //  ********************Snackbar##################
  static const Color snackbarSuccessBg   = Color(0xFFF1FDF5);
  static const Color snackbarSuccessText = Color(0xFF2E7D32);
  static const Color snackbarErrorBg     = Color(0xFFFFF4F4);
  static const Color snackbarErrorText   = Color(0xFFD32F2F);

  // ألوان حالات الطلب
  static const Color pendingBg      = Color(0xffFFF3E0);
  static const Color pendingText    = Color(0xffE65100);

  static const Color processingBg   = Color(0xffE3F2FD);
  static const Color processingText = Color(0xff1565C0);

  static const Color shippedBg      = Color(0xffEEEDFE);
  static const Color shippedText    = Color(0xff553C9A);

  static const Color deliveredBg    = Color(0xffE8F8F0);
  static const Color deliveredText  = Color(0xff1B5E20);

  static const Color cancelledBg    = Color(0xffFEECEC);
  static const Color cancelledText  = Color(0xffB71C1C);

  static const Color returnedBg     = Color(0xffFFF8E1);
  static const Color returnedText   = Color(0xffF39C12);

  //*************************
  static const Color textPrimary = Color(0xFF111827);
  static const Color danger        = Color(0xFFEF4444);
  static const Color shadow        = Color(0x0D000000);
  static const Color greyText      = Color(0xFF6B7280);
  static const Color backgroundScaffold = Color(0xFFF9FAFB);
}