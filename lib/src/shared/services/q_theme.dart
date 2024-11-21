import 'package:flutter/material.dart';

class QTheme {
  static var isDark = ThemeData.dark()
      .copyWith(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue));
  static var isLight = ThemeData.light()
      .copyWith(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue));
}
