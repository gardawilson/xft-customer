import 'package:flutter/material.dart';

/// Brand colour tokens for Xing Fu Tang.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFD71518);
  static const Color accent = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color background = Color(0xFFF2E8DC);

  // ── Semantic aliases (keep old names to avoid breaking references) ─────────
  static const Color xftPrimary = primary;
  static const Color xftAccent = accent;
  static const Color xftSurface = surface;
  static const Color xftBackground = background;
}

/// Spacing scale in logical pixels.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border-radius tokens.
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 100.0;
}
