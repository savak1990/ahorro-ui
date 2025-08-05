import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);    // Material Blue
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color accent = Color(0xFF03DAC6);     // Teal accent
  static const Color background = Color(0xFFFAFAFA); // Almost white
  static const Color surface = Color(0xFFFFFFFF);    // White
  static const Color error = Color(0xFFB00020);      // Material Red

  // Text colors
  static const Color textPrimary = Color(0xFF212121);   // Primary text
  static const Color textSecondary = Color(0xFF757575); // Secondary text
  static const Color textHint = Color(0xFFBDBDBD);      // Underlines

  // Borders and dividers
  static const Color divider = Color(0xFFE0E0E0);    // Dividers
  static const Color border = Color(0xFFBDBDBD);     // Borders

  // States
  static const Color disabled = Color(0xFFBDBDBD);   // Inactive elements
  static const Color selected = Color(0xFFE3F2FD);   // Selected elements
  static const Color hover = Color(0xFFF5F5F5);      // When hovering

  // Success and warning colors
  static const Color success = Color(0xFF4CAF50);    // Green
  static const Color warning = Color(0xFFFF9800);    // Orange
  static const Color info = Color(0xFF2196F3);       // Blue

  // Card and elevation colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);

  // Web-specific colors
  static const Color webBackground = Color(0xFFF8F9FA);
  static const Color webSurface = Color(0xFFFFFFFF);
  static const Color webBorder = Color(0xFFE9ECEF);

  // Dark theme colors (for future use)
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);

  // Add more colors as needed
}