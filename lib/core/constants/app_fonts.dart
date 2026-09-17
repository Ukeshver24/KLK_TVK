import 'package:flutter/material.dart';

/// AppFonts provides ultra-modern, crisp typography bundled directly inside the app assets.
/// 100% Offline with ZERO network calls and ZERO lag.
/// English uses Plus Jakarta Sans.
/// Tamil uses Noto Sans Tamil.
/// Automatically balances font-weights so Tamil text never gets excessively bold/blotchy.
class AppFonts {
  static const String fontFamilyEnglish = 'PlusJakartaSans';
  static const String fontFamilyTamil = 'NotoSansTamil';

  /// Check if string contains Tamil Unicode characters
  static bool containsTamil(String? text) {
    if (text == null || text.isEmpty) return false;
    return RegExp(r'[\u0B80-\u0BFF]').hasMatch(text);
  }

  /// Create a TextStyle dynamically based on language / script
  static TextStyle style({
    String? text,
    bool? isTamil,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    final bool isTamilScript = isTamil ?? containsTamil(text);

    // For Tamil, clamp overly thick font weights (w800/w900 -> w700/w600) to keep glyph loops clean
    FontWeight resolvedWeight = fontWeight ?? FontWeight.normal;
    if (isTamilScript) {
      if (resolvedWeight == FontWeight.w900 || resolvedWeight == FontWeight.w800) {
        resolvedWeight = FontWeight.w700;
      } else if (resolvedWeight == FontWeight.bold) {
        resolvedWeight = FontWeight.w600;
      }
    }

    // When Tamil font is requested, scale fontSize slightly so it matches English optical sizing
    double? resolvedFontSize = fontSize;
    if (isTamilScript && fontSize != null) {
      if (fontSize >= 20) {
        resolvedFontSize = fontSize - 1.5;
      } else if (fontSize >= 14) {
        resolvedFontSize = fontSize - 0.5;
      }
    }

    return TextStyle(
      fontFamily: isTamilScript ? fontFamilyTamil : fontFamilyEnglish,
      fontFamilyFallback: const [fontFamilyTamil, fontFamilyEnglish],
      fontSize: resolvedFontSize,
      fontWeight: resolvedWeight,
      color: color,
      height: height ?? (isTamilScript ? 1.35 : 1.25),
      letterSpacing: letterSpacing ?? (isTamilScript ? 0.0 : 0.2),
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  /// Modern Heading Style
  static TextStyle heading({
    bool isTamil = false,
    double fontSize = 22,
    FontWeight? fontWeight,
    Color color = const Color(0xFF1E1E1E),
    double? height,
    double? letterSpacing,
  }) {
    return style(
      isTamil: isTamil,
      fontSize: fontSize,
      fontWeight: fontWeight ?? (isTamil ? FontWeight.w700 : FontWeight.w800),
      color: color,
      height: height ?? (isTamil ? 1.3 : 1.2),
      letterSpacing: letterSpacing ?? (isTamil ? 0.0 : 0.3),
    );
  }

  /// Modern Subheading Style
  static TextStyle subheading({
    bool isTamil = false,
    double fontSize = 14,
    FontWeight? fontWeight,
    Color color = const Color(0xFF6E6E6E),
    double? height,
  }) {
    return style(
      isTamil: isTamil,
      fontSize: fontSize,
      fontWeight: fontWeight ?? (isTamil ? FontWeight.w500 : FontWeight.w600),
      color: color,
      height: height ?? (isTamil ? 1.4 : 1.3),
    );
  }

  /// Modern Body Text Style
  static TextStyle body({
    bool isTamil = false,
    double fontSize = 13,
    FontWeight? fontWeight,
    Color color = const Color(0xFF4A3A3A),
    double? height,
  }) {
    return style(
      isTamil: isTamil,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      height: height ?? (isTamil ? 1.45 : 1.35),
    );
  }

  /// Modern Badge / Label Style
  static TextStyle label({
    bool isTamil = false,
    double fontSize = 11,
    FontWeight? fontWeight,
    Color color = const Color(0xFF8E7E7E),
    double? letterSpacing,
  }) {
    return style(
      isTamil: isTamil,
      fontSize: fontSize,
      fontWeight: fontWeight ?? (isTamil ? FontWeight.w600 : FontWeight.bold),
      color: color,
      letterSpacing: letterSpacing ?? (isTamil ? 0.2 : 0.8),
    );
  }
}
