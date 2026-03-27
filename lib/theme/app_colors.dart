import 'package:flutter/material.dart';

class AppColors {
  static const scaffold = Color(0xFF0D0D0F);
  static const surface = Color(0xFF1A1A1F);
  static const glass = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const teal = Color(0xFF00E5D0);
  static const tealDim = Color(0xFF00B5A5);
  static const purple = Color(0xFF9B6DFF);
  static const purpleDim = Color(0xFF7B4FD8);
  static const amber = Color(0xFFFFB547);
  static const red = Color(0xFFFF5C5C);
  static const green = Color(0xFF3DDE8B);
  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF8888A0);
  static const cardBg = Color(0xFF16161C);

  static Color subjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'medicine':
        return teal;
      case 'surgery':
        return amber;
      case 'pathology':
        return purple;
      case 'pharmacology':
        return const Color(0xFF4FC3F7);
      case 'anatomy':
        return const Color(0xFFA8E063);
      default:
        return const Color(0xFF8888A0);
    }
  }
}
