import 'package:flutter/material.dart';

class AppThemeOption {
  final String key;
  final String nameKey;
  final String descriptionKey;
  final Color primary;
  final Color lightPreview;
  final Color darkPreview;
  final IconData icon;

  const AppThemeOption({
    required this.key,
    required this.nameKey,
    required this.descriptionKey,
    required this.primary,
    required this.lightPreview,
    required this.darkPreview,
    required this.icon,
  });

  bool get isDark => key.endsWith('_dark');
}

const appThemeOptions = <AppThemeOption>[
  AppThemeOption(
    key: 'orange_light',
    nameKey: 'acct_theme_orange_light',
    descriptionKey: 'acct_theme_orange_light_desc',
    primary: Color(0xffCC5813),
    lightPreview: Color(0xffFFF0E6),
    darkPreview: Color(0xffCC5813),
    icon: Icons.light_mode_rounded,
  ),
  AppThemeOption(
    key: 'orange_dark',
    nameKey: 'acct_theme_orange_dark',
    descriptionKey: 'acct_theme_orange_dark_desc',
    primary: Color(0xffFF8C42),
    lightPreview: Color(0xff252525),
    darkPreview: Color(0xffCC5813),
    icon: Icons.dark_mode_rounded,
  ),
  AppThemeOption(
    key: 'blue_light',
    nameKey: 'acct_theme_blue_light',
    descriptionKey: 'acct_theme_blue_light_desc',
    primary: Color(0xff185FA5),
    lightPreview: Color(0xffE6F1FB),
    darkPreview: Color(0xff185FA5),
    icon: Icons.light_mode_rounded,
  ),
  AppThemeOption(
    key: 'blue_dark',
    nameKey: 'acct_theme_blue_dark',
    descriptionKey: 'acct_theme_blue_dark_desc',
    primary: Color(0xff64B5F6),
    lightPreview: Color(0xff252525),
    darkPreview: Color(0xff185FA5),
    icon: Icons.dark_mode_rounded,
  ),
  AppThemeOption(
    key: 'purple_light',
    nameKey: 'acct_theme_purple_light',
    descriptionKey: 'acct_theme_purple_light_desc',
    primary: Color(0xff553C9A),
    lightPreview: Color(0xffEEEDFE),
    darkPreview: Color(0xff553C9A),
    icon: Icons.light_mode_rounded,
  ),
  AppThemeOption(
    key: 'purple_dark',
    nameKey: 'acct_theme_purple_dark',
    descriptionKey: 'acct_theme_purple_dark_desc',
    primary: Color(0xffB39DDB),
    lightPreview: Color(0xff252525),
    darkPreview: Color(0xff553C9A),
    icon: Icons.dark_mode_rounded,
  ),
  AppThemeOption(
    key: 'green_light',
    nameKey: 'acct_theme_green_light',
    descriptionKey: 'acct_theme_green_light_desc',
    primary: Color(0xff27AE60),
    lightPreview: Color(0xffE8F8F0),
    darkPreview: Color(0xff27AE60),
    icon: Icons.light_mode_rounded,
  ),
  AppThemeOption(
    key: 'green_dark',
    nameKey: 'acct_theme_green_dark',
    descriptionKey: 'acct_theme_green_dark_desc',
    primary: Color(0xff66BB6A),
    lightPreview: Color(0xff252525),
    darkPreview: Color(0xff27AE60),
    icon: Icons.dark_mode_rounded,
  ),
];

ThemeData buildAppTheme({
  required AppThemeOption option,
  required String fontFamily,
}) {
  final brightness = option.isDark ? Brightness.dark : Brightness.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: option.primary,
    brightness: brightness,
  ).copyWith(primary: option.primary);
  final surface = option.isDark ? const Color(0xff1E1E1E) : Colors.white;
  final scaffold = option.isDark
      ? const Color(0xff121212)
      : const Color(0xffF8F9FD);
  final outline = option.isDark
      ? const Color(0xff444444)
      : const Color(0xffE5E5EA);
  final text = option.isDark ? Colors.white : const Color(0xff1A1A1A);
  final secondary = option.isDark ? Colors.white70 : const Color(0xff8E8E8E);

  return ThemeData(
    brightness: brightness,
    fontFamily: fontFamily,
    colorScheme: scheme,
    primaryColor: option.primary,
    scaffoldBackgroundColor: scaffold,
    canvasColor: scaffold,
    cardColor: surface,
    dividerColor: outline,
    dialogBackgroundColor: surface,
    appBarTheme: const AppBarTheme(elevation: 0, foregroundColor: Colors.white),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: option.primary,
      unselectedItemColor: secondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: outline),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: option.primary, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: option.primary,
        foregroundColor: Colors.white,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 26,
        color: text,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: text,
      ),
      bodyLarge: TextStyle(
        height: 2,
        color: secondary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      bodyMedium: TextStyle(height: 2, color: secondary, fontSize: 14),
    ),
  );
}

final themeEnglish = buildAppTheme(
  option: appThemeOptions.first,
  fontFamily: 'PlayfairDisplay',
);
final themeArabic = buildAppTheme(
  option: appThemeOptions.first,
  fontFamily: 'Cairo',
);
final themeEnglishDark = buildAppTheme(
  option: appThemeOptions[1],
  fontFamily: 'PlayfairDisplay',
);
final themeArabicDark = buildAppTheme(
  option: appThemeOptions[1],
  fontFamily: 'Cairo',
);
