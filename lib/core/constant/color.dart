import 'package:flutter/material.dart';

class AppColor {
  static const Color black = Color(0xff000000);
  static const Color grey = Color(0xff8e8e8e);

  static const Color backgroundcolor = Color(0xffffffff);

  static const Color secondBackground = Color(0xffF8F9FD);

  static const Color primaryColor = Color(0xffff6300);

  static const Color primaryLight = Color(0xffff8c42);

  static const Color primaryDark = Color(0xffcc4f00);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryLight,
      primaryColor,
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xffffffff),
      Color(0xfffff0e6),
    ],
  );
  //************
  static const Color snackbarSuccessBg = Color(0xFFF1FDF5);
  static const Color snackbarSuccessText = Color(0xFF2E7D32);
  static const Color snackbarErrorBg = Color(0xFFFFF4F4);
  static const Color snackbarErrorText = Color(0xFFD32F2F);
}
