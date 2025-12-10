import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _slate900 = Color(0xFF0F172A);
  static const _slate800 = Color(0xFF1E293B);
  static const _indigo500 = Color(0xFF6366F1);
  static const _emerald500 = Color(0xFF10B981);
  static const _textWhite = Color.fromRGBO(255, 255, 255, 0.9);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _slate900,
    colorScheme: const ColorScheme.dark(
      primary: _indigo500,
      secondary: _emerald500,
      surface: _slate800,
      onPrimary: Colors.white,
      onSurface: _textWhite,
      onSecondary: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: _textWhite,
      displayColor: _textWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _slate900,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(color: _textWhite, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1),
      iconTheme: IconThemeData(color: _textWhite),
    ),
    cardTheme: CardThemeData(
      color: _slate800.withValues(alpha: 0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    ),
  );
}
