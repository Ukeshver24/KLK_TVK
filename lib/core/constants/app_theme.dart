import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.fontFamilyEnglish,
      fontFamilyFallback: const [AppFonts.fontFamilyTamil, AppFonts.fontFamilyEnglish],
      scaffoldBackgroundColor: const Color(0xFFF9F6F6),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryMaroon,
        secondary: AppColors.goldAccent,
        surface: Colors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryMaroon,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
