import 'package:flutter/material.dart';

class EmpManagerThemeColors extends ThemeExtension<EmpManagerThemeColors> {
  final Color iconContainerBackground;
  final Color iconColor;
  final Color subtitleText;

  const EmpManagerThemeColors({
    required this.iconContainerBackground,
    required this.iconColor,
    required this.subtitleText,
  });

  @override
  EmpManagerThemeColors copyWith({
    Color? iconContainerBackground,
    Color? iconColor,
    Color? subtitleText,
  }) {
    return EmpManagerThemeColors(
      iconContainerBackground:
          iconContainerBackground ?? this.iconContainerBackground,
      iconColor: iconColor ?? this.iconColor,
      subtitleText: subtitleText ?? this.subtitleText,
    );
  }

  @override
  EmpManagerThemeColors lerp(
    covariant ThemeExtension<EmpManagerThemeColors>? other,
    double t,
  ) {
    if (other is! EmpManagerThemeColors) return this;
    return EmpManagerThemeColors(
      iconContainerBackground: Color.lerp(
        iconContainerBackground,
        other.iconContainerBackground,
        t,
      )!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      subtitleText: Color.lerp(subtitleText, other.subtitleText, t)!,
    );
  }
}
