import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/app_colors.dart';
import 'package:flutter_application_ai/theme/form_browse_theme_colors.dart';

class FormBrowsePreviewTheme {
  static OutlineInputBorder fieldBorder(BuildContext context) {
    final colors = Theme.of(context).extension<FormBrowseThemeColors>()!;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: colors.previewFrameBorder),
    );
  }

  static OutlineInputBorder focusedFieldBorder(BuildContext context) {
    final colors = Theme.of(context).extension<FormBrowseThemeColors>()!;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: colors.previewSelectedBorder,
        width: 1.2,
      ),
    );
  }

  static ThemeData resolve(ThemeData baseTheme) {
    final borderlessInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide.none,
    );

    return baseTheme.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.formBrowsePreviewFrameBackground,
      cardColor: AppColors.formBrowsePreviewFrameBackground,
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: false,
        fillColor: Colors.transparent,
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
        hintStyle: const TextStyle(color: AppColors.formBrowsePreviewSubtle),
        border: borderlessInputBorder,
        enabledBorder: borderlessInputBorder,
        focusedBorder: borderlessInputBorder,
        disabledBorder: borderlessInputBorder,
        errorBorder: borderlessInputBorder,
        focusedErrorBorder: borderlessInputBorder,
        contentPadding: EdgeInsets.zero,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
    );
  }
}
