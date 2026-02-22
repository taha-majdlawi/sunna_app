import 'package:flutter/material.dart';

// ================= LIGHT THEME =================
ThemeData lightTheme() {
  const primaryColor = Color(0xFFE0A458); // برتقالي هادئ
  const backgroundColor = Color(0xFFFFF8EE); // خلفية كريمية مريحة

  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    secondary: const Color(0xFFC48A3A),
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: backgroundColor,
    onBackground: Colors.black87,
    surface: Colors.white,
    onSurface: Colors.black87,
    surfaceVariant: const Color(0xFFFFEBD6),
    onSurfaceVariant: Colors.black87,
    outline: Colors.grey,
    shadow: Colors.black,
    inverseSurface: Colors.black,
    onInverseSurface: Colors.white,
    inversePrimary: primaryColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: "Arial",
    appBarTheme: const AppBarTheme(elevation: 0),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

// ================= DARK THEME =================
ThemeData darkTheme() {
  const backgroundColor = Color(0xFF1E1E1E);
  const surfaceColor = Color(0xFF2A2A2A);
  const primaryGray = Color(0xFF3A3A3A);

  final colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryGray,
    onPrimary: Colors.white,
    secondary: const Color(0xFF555555),
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.black,
    background: backgroundColor,
    onBackground: const Color(0xFFE5E5E5),
    surface: surfaceColor,
    onSurface: const Color(0xFFE5E5E5),
    surfaceVariant: const Color(0xFF333333),
    onSurfaceVariant: Colors.white70,
    outline: Colors.grey,
    shadow: Colors.black,
    inverseSurface: Colors.white,
    onInverseSurface: Colors.black,
    inversePrimary: primaryGray,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: "Arial",
    appBarTheme: const AppBarTheme(elevation: 0),
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}