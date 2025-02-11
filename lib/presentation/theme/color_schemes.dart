import 'package:flutter/material.dart';

class ColorSchemes {
  static const Color primaryPurple = Color.fromARGB(255, 120, 53, 237);
  static const Color secondaryPurple = Color.fromARGB(255, 47, 0, 255);
  static const Color accentPurple = Color(0xFFE1BEE7);
  static const Color surfaceDark = Color.fromARGB(255, 55, 5, 255);
  static const Color cardDark = Color(0xFF2D2D2D);

  static ColorScheme darkColorScheme = ColorScheme.dark(
    primary: primaryPurple,
    secondary: accentPurple,
    surface: surfaceDark,
    background: Colors.black,
    onBackground: Colors.white70,
    onSurface: Colors.white,
    tertiary: secondaryPurple,
  );

  static LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black,
      secondaryPurple.withOpacity(0.3),
      primaryPurple.withOpacity(0.1),
    ],
  );
}