import 'package:flutter/material.dart';

class AppColors {
  // 🔹 Primary
  static const Color primary = Colors.green; // Deep Purple
  static const Color primaryLight = Color(0xFF7B42F6); // Lighter gradient
  static const Color primaryDark = Color(0xFF2E005A); // Dark variant

  // 🔹 Secondary
  static const Color secondary = Color(0xFFFFA500); // Orange Accent
  static const Color secondaryLight = Color(0xFFFFC266); // Soft Orange

  // 🔹 Backgrounds
  static const Color background = Color(0xFFF7F7F7); // Light Grey
  static const Color cardBackground = Colors.white; // Card container

  // 🔹 Text
  static const Color textPrimary = Color(0xFF1F1F1F); // Dark text
  static const Color textSecondary = Color(0xFF757575); // Grey text
  static const Color textOnPrimary = Colors.white; // Text on primary bg

  // 🔹 Borders & Dividers
  static const Color border = Color(0xFFE0E0E0); // Light gray border
  static const Color divider = Color(0xFFBDBDBD);

  // 🔹 Error & Success
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // 🔹 Shadows
  static const Color shadow = Colors.black12;

  // 🔹 Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryLight, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color card = Colors.white;
  static const Color inputBackground = Color(0xFFF0F0F0);

}
