import 'package:flutter/material.dart';

class AppColors {
  // TVK Primary Brand Colors
  static const Color primaryMaroon = Color(0xFF6B0000);
  static const Color darkMaroon = Color(0xFF280000);
  static const Color deepRed = Color(0xFF8C0000);
  static const Color brightRed = Color(0xFFD32F2F);
  
  // Metallic Gold Accents
  static const Color goldAccent = Color(0xFFE5B537);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);

  // Background Gradients
  static const Gradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF750000),
      Color(0xFF4A0000),
      Color(0xFF260000),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Neutral Tones
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF2A0808);
  static const Color textMuted = Color(0xFFD4AF37);
}
