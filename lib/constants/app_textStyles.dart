import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized text styles. Pass [isDark] where the color needs to
/// adapt to the current theme (most call sites will use
/// Theme.of(context).textTheme after this is wired into ThemeData,
/// but these are handy for direct use too).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1(bool isDark) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle heading2(bool isDark) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle heading3(bool isDark) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle body(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodySecondary(bool isDark) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  static TextStyle caption(bool isDark) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle errorText = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );
}