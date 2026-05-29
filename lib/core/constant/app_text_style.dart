import 'package:flutter/material.dart';
import 'package:e_commerce/core/constant/color.dart';

import 'color.dart';


class AppTextStyle {

  static const String _fontEn = "PlayfairDisplay";

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColor.black,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColor.black,
    height: 1.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColor.black,
    height: 1.4,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColor.black,
    height: 1.4,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColor.black,
    height: 1.4,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColor.black,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColor.black,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColor.grey,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColor.grey,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColor.black,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColor.grey,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColor.grey,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle statNumber = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColor.black,
    fontFamily: _fontEn,
    height: 1.2,
  );

  static const TextStyle statNumberSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColor.black,
    fontFamily: _fontEn,
    height: 1.2,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColor.grey,
    height: 1.4,
  );

  static const TextStyle statChange = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle navLabelActive = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColor.black,
    height: 1.5,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColor.greyLight,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColor.grey,
  );

  static const TextStyle inputError = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColor.error,
  );

  static const TextStyle orderNumber = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColor.black,
    fontFamily: _fontEn,
    letterSpacing: 0.3,
  );

  static const TextStyle price = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColor.primaryColor,
    fontFamily: _fontEn,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColor.primaryColor,
    fontFamily: _fontEn,
  );

  static const TextStyle timestamp = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColor.grey,
  );
}