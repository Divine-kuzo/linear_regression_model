import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoboColors {
  static const coral = Color(0xFFFF8A6B);
  static const coralDark = Color(0xFFE8734F);
  static const teal = Color(0xFF5FC6B8);
  static const tealDark = Color(0xFF3FA396);
  static const background = Color(0xFFFFF8F0);
  static const cardBackground = Color(0xFFFFFFFF);
  static const softCoral = Color(0xFFFFE4D9);
  static const softTeal = Color(0xFFDFF5F1);
  static const textDark = Color(0xFF4A3F3A);
}

ThemeData buildBoboTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: BoboColors.coral,
      primary: BoboColors.coral,
      secondary: BoboColors.teal,
      surface: BoboColors.cardBackground,
    ),
    scaffoldBackgroundColor: BoboColors.background,
    textTheme: GoogleFonts.nunitoTextTheme(),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: BoboColors.textDark, displayColor: BoboColors.textDark),
    cardTheme: CardThemeData(
      color: BoboColors.cardBackground,
      elevation: 0,
      shadowColor: BoboColors.coral.withValues(alpha: 0.18),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BoboColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: GoogleFonts.nunito(color: BoboColors.textDark.withValues(alpha: 0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BoboColors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BoboColors.coralDark, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BoboColors.coral,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: BoboColors.coral.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: BoboColors.background,
      foregroundColor: BoboColors.textDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.nunito(
        color: BoboColors.textDark,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
