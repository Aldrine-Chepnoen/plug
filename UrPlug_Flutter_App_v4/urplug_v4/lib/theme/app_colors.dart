import 'package:flutter/material.dart';

/// Ur Plug brand palette.
///
/// Deep green = trust/reliability (Uganda-relevant, evokes growth & safety).
/// Gold = reserved almost exclusively for Gold Tier signals, so it stays
/// meaningful instead of decorative.
class AppColors {
  AppColors._();

  // Brand
  static const Color primaryGreen = Color(0xFF0B6E4F);
  static const Color primaryGreenDark = Color(0xFF084F39);
  static const Color primaryGreenLight = Color(0xFFE4F3EC);

  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFFBEFD2);

  static const Color deepBlue = Color(0xFF13324B);

  // Status
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFE0433D);
  static const Color warning = Color(0xFFE0A93D);

  // Neutrals — light
  static const Color lightBg = Color(0xFFF7F8F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4E7E5);
  static const Color lightTextPrimary = Color(0xFF15201C);
  static const Color lightTextSecondary = Color(0xFF5B665F);

  // Neutrals — dark
  static const Color darkBg = Color(0xFF0E1512);
  static const Color darkSurface = Color(0xFF16201B);
  static const Color darkBorder = Color(0xFF283530);
  static const Color darkTextPrimary = Color(0xFFEDF2EF);
  static const Color darkTextSecondary = Color(0xFFA3B0AA);

  // "Open for work" indicator dots
  static const Color openDot = Color(0xFF2E9E5B);
  static const Color closedDot = Color(0xFFB8433D);
}
