import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:business_assistant/config/constants/secure_storage_keys.dart';
import 'package:business_assistant/theme/theme_color.dart';

typedef ThemeChangeCallback = void Function(ThemeMode themeMode);

/// Singleton that manages and persists the current theme mode (light / dark).
///
/// The selected theme is stored in FlutterSecureStorage under the 'theme_mode'
/// key so it survives app restarts.
///
/// main.dart registers an onThemeChanged callback that calls setState() on MyApp,
/// which causes MaterialApp.router to pick up the new ThemeConfig().currentTheme.
///
/// Usage:
///   // Switch to dark mode
///   ThemeConfig().changeTheme(ThemeMode.dark);
///
///   // Read current mode
///   ThemeMode mode = ThemeConfig().currentTheme;
class ThemeConfig {
  ThemeChangeCallback? onThemeChanged;

  /// In-memory current theme — updated by changeTheme() and loaded on startup.
  ThemeMode currentTheme = ThemeMode.light;

  static final ThemeConfig _themeConfig = ThemeConfig._internal();

  factory ThemeConfig() => _themeConfig;
  ThemeConfig._internal();

  /// Changes the active theme, persists it, and notifies the widget tree.
  void changeTheme(ThemeMode themeMode) {
    currentTheme = themeMode;
    saveTheme(currentTheme);
    _themeConfig.onThemeChanged?.call(themeMode);
  }

  /// Reads the persisted theme from secure storage and returns it.
  /// Called once in main.dart on app startup before the first frame.
  Future<ThemeMode> initThemeConfig() async {
    currentTheme = await loadTheme();
    return currentTheme;
  }

  Future<void> saveTheme(ThemeMode mode) async {
    try {
      const storage = FlutterSecureStorage();
      // ThemeMode.name gives 'light', 'dark', or 'system'
      await storage.write(key: SecureStorageKeys.themeMode, value: mode.name);
    } catch (e) {
      debugPrint('Error in saveTheme: $e');
    }
  }

  Future<ThemeMode> loadTheme() async {
    try {
      const storage = FlutterSecureStorage();
      String? value = await storage.read(key: SecureStorageKeys.themeMode);
      if (value == ThemeMode.dark.name) return ThemeMode.dark;
    } catch (e) {
      debugPrint('Error in loadTheme: $e');
      return ThemeMode.light;
    }
    return ThemeMode.light;
  }

  /// Convenience getter for reading the current ThemeColor extension directly.
  ThemeColor get themeColor =>
      currentTheme == ThemeMode.dark ? darkThemeColors : lightThemeColors;
}

/// Top-level instance used in landing_page.dart for concise access.
ThemeConfig themeConfig = ThemeConfig();
