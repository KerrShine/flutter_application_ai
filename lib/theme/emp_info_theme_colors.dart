import 'package:flutter/material.dart';

class EmpInfoThemeColors extends ThemeExtension<EmpInfoThemeColors> {
  final Color actionColor;
  final Color breadcrumbText;
  final Color headlineText;

  const EmpInfoThemeColors({
    required this.actionColor,
    required this.breadcrumbText,
    required this.headlineText,
  });

  @override
  EmpInfoThemeColors copyWith({
    Color? actionColor,
    Color? breadcrumbText,
    Color? headlineText,
  }) {
    return EmpInfoThemeColors(
      actionColor: actionColor ?? this.actionColor,
      breadcrumbText: breadcrumbText ?? this.breadcrumbText,
      headlineText: headlineText ?? this.headlineText,
    );
  }

  @override
  EmpInfoThemeColors lerp(
    covariant ThemeExtension<EmpInfoThemeColors>? other,
    double t,
  ) {
    if (other is! EmpInfoThemeColors) return this;
    return EmpInfoThemeColors(
      actionColor: Color.lerp(actionColor, other.actionColor, t)!,
      breadcrumbText: Color.lerp(breadcrumbText, other.breadcrumbText, t)!,
      headlineText: Color.lerp(headlineText, other.headlineText, t)!,
    );
  }
}
