import 'package:flutter/material.dart';
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
    final colors = baseTheme.extension<FormBrowseThemeColors>();
    final borderlessInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide.none,
    );
    final primaryTextColor = baseTheme.textTheme.bodyMedium?.color ??
        baseTheme.colorScheme.onSurface;
    final subtleTextColor = colors?.previewSubtleText ??
        baseTheme.textTheme.bodySmall?.color ??
        baseTheme.colorScheme.onSurfaceVariant;
    final previewSurface =
        colors?.previewSurface ?? baseTheme.colorScheme.surface;

    return baseTheme.copyWith(
      scaffoldBackgroundColor: previewSurface,
      cardColor: previewSurface,
      canvasColor: previewSurface,
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: false,
        fillColor: Colors.transparent,
        labelStyle: TextStyle(color: subtleTextColor),
        hintStyle: TextStyle(color: subtleTextColor),
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
        bodyColor: primaryTextColor,
        displayColor: primaryTextColor,
      ),
    );
  }
}
