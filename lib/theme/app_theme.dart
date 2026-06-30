import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color bgDark      = Color(0xFF0D1117);
  static const Color bgCard      = Color(0xFF161B22);
  static const Color bgCardLight = Color(0xFF1C2333);

  // ── Wallet card: أخضر زمردي جميل بدل الأزرق ──
  static const Color walletStart = Color(0xFF00C896);
  static const Color walletEnd   = Color(0xFF00897B);

  // Accent
  static const Color green      = Color(0xFF00E676);
  static const Color greenLight = Color(0xFF69F0AE);
  static const Color red        = Color(0xFFFF5252);
  static const Color orange     = Color(0xFFFFB300);
  static const Color blue       = Color(0xFF448AFF);
  static const Color teal       = Color(0xFF00BFA5);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted     = Color(0xFF607D8B);

  // Bottom nav
  static const Color navBg       = Color(0xFF161B22);
  static const Color navActive   = Color(0xFF00C896);   // أخضر
  static const Color navInactive = Color(0xFF546E7A);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.walletStart,
      secondary: AppColors.green,
      surface: AppColors.bgCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navBg,
      selectedItemColor: AppColors.navActive,
      unselectedItemColor: AppColors.navInactive,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
