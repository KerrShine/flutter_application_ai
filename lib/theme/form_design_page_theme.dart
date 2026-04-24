import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormDesignPageTheme {
  static ThemeData resolve(ThemeData baseTheme) {
    final colors = baseTheme.extension<FormDesignThemeColors>();

    if (colors == null) {
      return baseTheme;
    }

    return baseTheme.copyWith(
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colors.shellBorder.withValues(alpha: 0.7),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colors.shellBorder.withValues(alpha: 0.7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colors.sectionIconColor,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE07A7A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFF9B9B),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  static InputDecoration executionInputDecoration(
    BuildContext context, {
    bool isDense = true,
    String? errorText,
  }) {
    return InputDecoration(
      isDense: isDense,
      errorText: errorText,
    ).applyDefaults(Theme.of(context).inputDecorationTheme);
  }
}
