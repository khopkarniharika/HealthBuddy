import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const _settingsKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_settingsKey);
    if (data == null) {
      return AppSettings(language: 'en', isDarkMode: true, fontSize: 16.0);
    }
    try {
      return AppSettings.decode(data);
    } catch (_) {
      return AppSettings(language: 'en', isDarkMode: true, fontSize: 16.0);
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, AppSettings.encode(settings));
  }

  ThemeData buildTheme(AppSettings settings) {
    const baseBackground = Color(0xFF1E2A3A);
    const cardColor = Color(0xFF2C3E50);
    final brightness = settings.isDarkMode ? Brightness.dark : Brightness.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.cyan,
      brightness: brightness,
      primary: Colors.cyan,
      secondary: Colors.pinkAccent,
      background: baseBackground,
    );

    final baseTextTheme = ThemeData(brightness: brightness).textTheme;
    
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: baseBackground,
      colorScheme: colorScheme,
      cardColor: cardColor,
      primaryColor: Colors.cyan,
      appBarTheme: const AppBarTheme(
        backgroundColor: baseBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.displayLarge?.fontSize ?? 32) * (settings.fontSize / 16.0),
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.displayMedium?.fontSize ?? 28) * (settings.fontSize / 16.0),
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.displaySmall?.fontSize ?? 24) * (settings.fontSize / 16.0),
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 22) * (settings.fontSize / 16.0),
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 20) * (settings.fontSize / 16.0),
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 18) * (settings.fontSize / 16.0),
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.titleLarge?.fontSize ?? 16) * (settings.fontSize / 16.0),
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.titleMedium?.fontSize ?? 14) * (settings.fontSize / 16.0),
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.titleSmall?.fontSize ?? 12) * (settings.fontSize / 16.0),
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * (settings.fontSize / 16.0),
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * (settings.fontSize / 16.0),
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * (settings.fontSize / 16.0),
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * (settings.fontSize / 16.0),
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * (settings.fontSize / 16.0),
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontSize: (baseTextTheme.labelSmall?.fontSize ?? 10) * (settings.fontSize / 16.0),
        ),
      ),
      useMaterial3: true,
    );
  }
}