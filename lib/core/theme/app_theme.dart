import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand palette ──────────────────────────────────────────
  static const Color primary = Color(0xFF0F9D7A);
  static const Color primaryDark = Color(0xFF0B6E5A);
  static const Color primaryLight = Color(0xFF1AB892);
  static const Color secondary = Color(0xFF123B52);
  static const Color accent = Color(0xFF38BFA0);

  // ── Semantic ────────────────────────────────────────────────
  static const Color success = Color(0xFF18A66A);
  static const Color danger = Color(0xFFE85D5D);
  static const Color warning = Color(0xFFF4A63D);
  static const Color info = Color(0xFF3B82F6);

  // ── Surface tokens — Light ──────────────────────────────────
  static const Color lightBg = Color(0xFFF0F4F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2EAF0);
  static const Color lightBorderSoft = Color(0xFFEFF4F7);

  // ── Surface tokens — Dark ───────────────────────────────────
  static const Color darkBg = Color(0xFF0C1B22);
  static const Color darkSurface = Color(0xFF132830);
  static const Color darkSurfaceHigh = Color(0xFF1A3540);
  static const Color darkBorder = Color(0xFF1F3B45);
  static const Color darkBorderSoft = Color(0xFF172F38);

  // ── Text ────────────────────────────────────────────────────
  static const Color textDark = Color(0xFF0F2229);
  static const Color textMuted = Color(0xFF627681);
  static const Color textLightMuted = Color(0xFF8DAAB4);

  // ── Category colors ─────────────────────────────────────────
  static const Color catFood = Color(0xFFF97316);
  static const Color catTransport = Color(0xFF3B82F6);
  static const Color catShopping = Color(0xFFA855F7);
  static const Color catHealth = Color(0xFF10B981);
  static const Color catEntertain = Color(0xFFEC4899);
  static const Color catBills = Color(0xFFF59E0B);
  static const Color catEducation = Color(0xFF6366F1);
  static const Color catTravel = Color(0xFF06B6D4);
  static const Color catHome = Color(0xFF84CC16);
  static const Color catGift = Color(0xFFF43F5E);
  static const Color catSubs = Color(0xFF8B5CF6);
  static const Color catIncome = Color(0xFF0F9D7A);
  static const Color catOther = Color(0xFF6B7280);

  // ── Spacing (8pt grid) ──────────────────────────────────────
  static const double sp4 = 4;
  static const double sp8 = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp32 = 32;
  static const double sp48 = 48;

  // ── Radius ──────────────────────────────────────────────────
  static const double rXS = 8;
  static const double rSM = 12;
  static const double rMD = 16;
  static const double rLG = 20;
  static const double rXL = 24;
  static const double r2XL = 32;

  // ── Gradient helpers ────────────────────────────────────────
  static List<Color> heroGradient(bool isDark) => isDark
      ? const [Color(0xFF0D5E52), Color(0xFF0F7A69)]
      : const [Color(0xFF0F9D7A), Color(0xFF1CB48E)];

  static List<Color> bgGradient(bool isDark) => isDark
      ? const [Color(0xFF0C1B22), Color(0xFF0F2530)]
      : const [Color(0xFFF0F4F7), Color(0xFFE8F2F5)];

  // ── Surface decoration ──────────────────────────────────────
  static BoxDecoration surface(bool isDark, {double radius = r2XL}) {
    return BoxDecoration(
      color: isDark ? darkSurface : lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: isDark ? darkBorder : lightBorder, width: 0.8),
      boxShadow: isDark
          ? []
          : [
              BoxShadow(
                color: const Color(0x0D123B52),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
    );
  }

  // ── ThemeData ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        error: danger,
        surface: lightSurface,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textDark,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r2XL),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBg,
        hintStyle: const TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: secondary,
        suffixIconColor: textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rLG),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rLG),
          borderSide: const BorderSide(color: lightBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rLG),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0x66107A60),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rLG),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: const BorderSide(color: lightBorder, width: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rMD),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F2229),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMD)),
      ),
      dividerColor: lightBorder,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: accent,
        secondary: const Color(0xFF7FD6C2),
        error: danger,
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r2XL),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: const TextStyle(
          color: textLightMuted,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: textLightMuted,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: accent,
        suffixIconColor: textLightMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rLG),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rLG),
          borderSide: const BorderSide(color: darkBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rLG),
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: darkBg,
          disabledBackgroundColor: const Color(0x6638BFA0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rLG),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: darkBorder, width: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rMD),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkSurfaceHigh,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMD)),
      ),
      dividerColor: darkBorder,
    );
  }
}
