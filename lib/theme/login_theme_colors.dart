import 'package:flutter/material.dart';

class LoginThemeColors extends ThemeExtension<LoginThemeColors> {
  final List<Color> backgroundGradient;
  final Color heroShadowColor;
  final Color panelShadowColor;
  final Color selectorBackgroundColor;

  const LoginThemeColors({
    required this.backgroundGradient,
    required this.heroShadowColor,
    required this.panelShadowColor,
    required this.selectorBackgroundColor,
  });

  @override
  LoginThemeColors copyWith({
    List<Color>? backgroundGradient,
    Color? heroShadowColor,
    Color? panelShadowColor,
    Color? selectorBackgroundColor,
  }) {
    return LoginThemeColors(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      heroShadowColor: heroShadowColor ?? this.heroShadowColor,
      panelShadowColor: panelShadowColor ?? this.panelShadowColor,
      selectorBackgroundColor:
          selectorBackgroundColor ?? this.selectorBackgroundColor,
    );
  }

  @override
  LoginThemeColors lerp(
    covariant ThemeExtension<LoginThemeColors>? other,
    double t,
  ) {
    if (other is! LoginThemeColors) {
      return this;
    }

    return LoginThemeColors(
      backgroundGradient: List<Color>.generate(
        backgroundGradient.length,
        (index) => Color.lerp(
          backgroundGradient[index],
          other.backgroundGradient[index],
          t,
        )!,
      ),
      heroShadowColor: Color.lerp(heroShadowColor, other.heroShadowColor, t)!,
      panelShadowColor:
          Color.lerp(panelShadowColor, other.panelShadowColor, t)!,
      selectorBackgroundColor: Color.lerp(
        selectorBackgroundColor,
        other.selectorBackgroundColor,
        t,
      )!,
    );
  }
}
