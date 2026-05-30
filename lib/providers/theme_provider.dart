import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages and persists visual themes mapping Light, Dark, or System configurations.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  /// Toggle themes dynamically.
  void toggleTheme(bool isDarkMode) {
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// Reset configuration to follow user device OS setups.
  void setSystemTheme() {
    state = ThemeMode.system;
  }
}

/// Global theme manager provider shortcut.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
