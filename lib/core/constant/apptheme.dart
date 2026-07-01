import 'package:e_commerce/core/constant/color.dart';

import 'package:flutter/material.dart';

ThemeData themeEnglish = ThemeData(
  fontFamily: "PlayfairDisplay",
  textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 26, color: AppColor.black),

      displayMedium: TextStyle(

          fontWeight: FontWeight.bold, fontSize: 22, color: AppColor.black),

      bodyLarge: TextStyle(

          height: 2,

          color: AppColor.grey,

          fontWeight: FontWeight.bold,

          fontSize: 14),

      bodyMedium: TextStyle(height: 2, color: AppColor.grey, fontSize: 14)),

  primarySwatch: Colors.blue,

);



ThemeData themeArabic = ThemeData(

  fontFamily: "Cairo",

  textTheme: const TextTheme(

      displayLarge: TextStyle(

          fontWeight: FontWeight.bold, fontSize: 26, color: AppColor.black),

      displayMedium: TextStyle(

          fontWeight: FontWeight.bold, fontSize: 22, color: AppColor.black),

      bodyLarge: TextStyle(

          height: 2,

          color: AppColor.grey,

          fontWeight: FontWeight.bold,

          fontSize: 14),

      bodyMedium: TextStyle(height: 2, color: AppColor.grey, fontSize: 14)),

  primarySwatch: Colors.blue,

);

ThemeData themeEnglishDark = ThemeData.dark().copyWith(
  textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white),
      displayMedium: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
      bodyLarge: TextStyle(
          height: 2,
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 14),
      bodyMedium: TextStyle(height: 2, color: Colors.white70, fontSize: 14)),
  primaryColor: Colors.blue,
);

ThemeData themeArabicDark = ThemeData.dark().copyWith(
  textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white, fontFamily: "Cairo"),
      displayMedium: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white, fontFamily: "Cairo"),
      bodyLarge: TextStyle(
          height: 2,
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 14, fontFamily: "Cairo"),
      bodyMedium: TextStyle(height: 2, color: Colors.white70, fontSize: 14, fontFamily: "Cairo")),
  primaryColor: Colors.blue,
);