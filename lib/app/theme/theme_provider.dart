import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(getLightTheme()) {
    _loadTheme();
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      fontFamily: 'OpenSans Bold',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: 'OpenSans Regular',
          ),
          backgroundColor: Colors.orange,
        )
      )
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: 'OpenSans Bold',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: 'OpenSans Regular',
          ),
          backgroundColor: Colors.orange.shade700,
        )
      )
    );
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      if (kDebugMode) {
        print('Loading theme: isDark = $isDark');
      }
      state = isDark ? getDarkTheme() : getLightTheme();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading theme: $e');
      }
      state = getLightTheme();
    }
  }

  Future<void> toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCurrentlyDark = state.brightness == Brightness.dark;
      
      if (kDebugMode) {
        print('Toggling theme from: $isCurrentlyDark to ${!isCurrentlyDark}');
      }
      
      state = isCurrentlyDark ? getLightTheme() : getDarkTheme();
      await prefs.setBool('is_dark_mode', !isCurrentlyDark);
      
      if (kDebugMode) {
        print('Theme saved: is_dark_mode = ${!isCurrentlyDark}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling theme: $e');
      }
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});
