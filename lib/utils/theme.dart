import 'package:flutter/material.dart';

class AppTheme {
  // Primary Color Palette (Safety-focused: Purple/Blue)
  static const Color purplePrimary = Color(0xFF6A11CB);
  static const Color bluePrimary = Colors.blue;

  static const Color primaryLight = Color(0xFF9D4EDD);
  static const Color primaryDark = Color(0xFF4A0D9C);

  // Secondary Color Palette
  static const Color secondaryColor = Color(0xFF2575FC);
  static const Color secondaryLight = Color(0xFF6A98FF);

  // Status Colors
  static const Color successColor = Color(0xFF34A853);
  static const Color warningColor = Color(0xFFFBBC05);
  static const Color errorColor = Color(0xFFEA4335);
  static const Color infoColor = Color(0xFF4285F4);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // SOS/Emergency Colors
  static const Color sosRed = Color(0xFFD32F2F);
  static const Color sosRedLight = Color(0xFFFFCDD2);
  static const Color sosRedDark = Color(0xFFB71C1C);

  static ThemeData getTheme(bool isBlueTheme) {
    final Color primary = isBlueTheme ? bluePrimary : purplePrimary;
    
    return ThemeData(
      // Color Scheme
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // Typography
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: textDisabled,
        ),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
          gapPadding: 0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        hintStyle: const TextStyle(
          color: textDisabled,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        errorStyle: const TextStyle(
          color: errorColor,
          fontSize: 12,
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 0.5),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 0,
      ),

      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withOpacity(0.2),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // Other
      scaffoldBackgroundColor: backgroundColor,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
    );
  }

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    useMaterial3: true,
  );
}
