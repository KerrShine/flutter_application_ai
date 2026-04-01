import 'package:flutter/material.dart';

class OrgTreeDesignPageTheme {
  static ThemeData resolve(ThemeData baseTheme) {
    return baseTheme.copyWith(
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide:
              baseTheme.inputDecorationTheme.enabledBorder?.borderSide ??
                  const BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide:
              baseTheme.inputDecorationTheme.focusedBorder?.borderSide ??
                  const BorderSide(width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              baseTheme.brightness == Brightness.dark ? Colors.white : null,
          side: baseTheme.brightness == Brightness.dark
              ? const BorderSide(color: Colors.white54)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      snackBarTheme: baseTheme.snackBarTheme.copyWith(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
