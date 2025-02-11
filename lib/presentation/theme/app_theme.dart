import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'widget_themes.dart';

class AppTheme {
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorSchemes.darkColorScheme,
      cardTheme: WidgetThemes.cardTheme,
      inputDecorationTheme: WidgetThemes.inputDecorationTheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: WidgetThemes.appBarTheme,
    );
  }
}