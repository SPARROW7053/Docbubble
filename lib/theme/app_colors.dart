import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFFF9F9F9);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // App bar gradient
  static const Color gradientStart = Color(0xFFFF6B35);
  static const Color gradientEnd = Color(0xFFFF4500);

  // Accents
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryLight = Color(0xFFFF8C42);

  // File type colors
  static const Color pdfRed = Color(0xFFEA4335);
  static const Color pdfRedBg = Color(0xFFFFEBEA);
  static const Color xlsGreen = Color(0xFF34A853);
  static const Color xlsGreenBg = Color(0xFFE6F4EA);
  static const Color docBlue = Color(0xFF4285F4);
  static const Color docBlueBg = Color(0xFFE8F0FE);
  static const Color pptOrange = Color(0xFFFF9800);
  static const Color pptOrangeBg = Color(0xFFFFF3E0);
  static const Color txtGrey = Color(0xFF9E9E9E);
  static const Color txtGreyBg = Color(0xFFF5F5F5);
  static const Color imgPurple = Color(0xFF9C27B0);
  static const Color imgPurpleBg = Color(0xFFF3E5F5);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFFB0B3C1);

  // UI
  static const Color divider = Color(0xFFF0F0F0);
  static const Color inputFill = Color(0xFFF3F4F6);
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navActive = Color(0xFFFF5722);
  static const Color navInactive = Color(0xFF9E9E9E);

  // Special
  static const Color favoriteYellow = Color(0xFFFFC107);
  static const Color folderBlue = Color(0xFF2196F3);
  static const Color successGreen = Color(0xFF34A853);
  static const Color errorRed = Color(0xFFEA4335);
  static const Color warningOrange = Color(0xFFFF9800);

  // Gradients
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Tool gradients
  static LinearGradient toolGreen = const LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient toolBlue = const LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient toolOrange = const LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient toolPurple = const LinearGradient(
    colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient toolTeal = const LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient toolPink = const LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient toolRed = const LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient toolDark = const LinearGradient(
    colors: [Color(0xFF37474F), Color(0xFF546E7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient toolYellow = const LinearGradient(
    colors: [Color(0xFFF9A825), Color(0xFFFFCA28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
