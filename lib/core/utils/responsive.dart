import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  // Scaled width relative to standard phone width 375
  static double w(BuildContext context, double size) {
    final screenWidth = width(context);
    final double maxCalculatedWidth = isTablet(context) ? 600 : screenWidth;
    return (size / 375.0) * maxCalculatedWidth;
  }

  // Scaled height relative to standard phone height 812
  static double h(BuildContext context, double size) {
    final screenHeight = height(context);
    return (size / 812.0) * screenHeight;
  }

  // Scaled font size
  static double sp(BuildContext context, double fontSize) {
    final screenWidth = width(context);
    final double baseWidth = isTablet(context) ? 550 : screenWidth;
    return (fontSize / 375.0) * baseWidth;
  }

  // Screen padding helper
  static EdgeInsets screenPadding(BuildContext context) {
    if (isTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: width(context) * 0.15,
        vertical: 24,
      );
    }
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  }
}
