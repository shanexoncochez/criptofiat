import 'package:flutter/material.dart';
import 'color_schemes.dart';

class WidgetThemes {
  static CardTheme get cardTheme => CardTheme(
    color: ColorSchemes.cardDark,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: ColorSchemes.cardDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ColorSchemes.accentPurple),
    ),
  );

  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: ColorSchemes.surfaceDark,
    foregroundColor: Colors.white,
    elevation: 0,
  );
}