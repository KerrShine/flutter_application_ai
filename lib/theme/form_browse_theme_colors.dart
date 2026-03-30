import 'package:flutter/material.dart';

class FormBrowseThemeColors extends ThemeExtension<FormBrowseThemeColors> {
  final List<Color> pageGradient;
  final Color heroGlow;
  final Color shellBackground;
  final Color shellBorder;
  final Color shellShadow;
  final Color panelBackground;
  final Color panelBorder;
  final Color panelShadow;
  final Color headerBackground;
  final Color headerForeground;
  final Color chipBackground;
  final Color chipForeground;
  final Color mutedText;
  final Color subtleText;
  final Color listSelectedBackground;
  final Color previewFrameBackground;
  final Color previewFrameBorder;
  final Color previewFrameShadow;
  final Color previewSurface;
  final Color previewSubtleText;
  final Color previewSelectedBackground;
  final Color previewSelectedBorder;
  final Color propertyCardBackground;
  final Color propertyCardSelectedBackground;

  const FormBrowseThemeColors({
    required this.pageGradient,
    required this.heroGlow,
    required this.shellBackground,
    required this.shellBorder,
    required this.shellShadow,
    required this.panelBackground,
    required this.panelBorder,
    required this.panelShadow,
    required this.headerBackground,
    required this.headerForeground,
    required this.chipBackground,
    required this.chipForeground,
    required this.mutedText,
    required this.subtleText,
    required this.listSelectedBackground,
    required this.previewFrameBackground,
    required this.previewFrameBorder,
    required this.previewFrameShadow,
    required this.previewSurface,
    required this.previewSubtleText,
    required this.previewSelectedBackground,
    required this.previewSelectedBorder,
    required this.propertyCardBackground,
    required this.propertyCardSelectedBackground,
  });

  @override
  FormBrowseThemeColors copyWith({
    List<Color>? pageGradient,
    Color? heroGlow,
    Color? shellBackground,
    Color? shellBorder,
    Color? shellShadow,
    Color? panelBackground,
    Color? panelBorder,
    Color? panelShadow,
    Color? headerBackground,
    Color? headerForeground,
    Color? chipBackground,
    Color? chipForeground,
    Color? mutedText,
    Color? subtleText,
    Color? listSelectedBackground,
    Color? previewFrameBackground,
    Color? previewFrameBorder,
    Color? previewFrameShadow,
    Color? previewSurface,
    Color? previewSubtleText,
    Color? previewSelectedBackground,
    Color? previewSelectedBorder,
    Color? propertyCardBackground,
    Color? propertyCardSelectedBackground,
  }) {
    return FormBrowseThemeColors(
      pageGradient: pageGradient ?? this.pageGradient,
      heroGlow: heroGlow ?? this.heroGlow,
      shellBackground: shellBackground ?? this.shellBackground,
      shellBorder: shellBorder ?? this.shellBorder,
      shellShadow: shellShadow ?? this.shellShadow,
      panelBackground: panelBackground ?? this.panelBackground,
      panelBorder: panelBorder ?? this.panelBorder,
      panelShadow: panelShadow ?? this.panelShadow,
      headerBackground: headerBackground ?? this.headerBackground,
      headerForeground: headerForeground ?? this.headerForeground,
      chipBackground: chipBackground ?? this.chipBackground,
      chipForeground: chipForeground ?? this.chipForeground,
      mutedText: mutedText ?? this.mutedText,
      subtleText: subtleText ?? this.subtleText,
      listSelectedBackground:
          listSelectedBackground ?? this.listSelectedBackground,
      previewFrameBackground:
          previewFrameBackground ?? this.previewFrameBackground,
      previewFrameBorder: previewFrameBorder ?? this.previewFrameBorder,
      previewFrameShadow: previewFrameShadow ?? this.previewFrameShadow,
      previewSurface: previewSurface ?? this.previewSurface,
      previewSubtleText: previewSubtleText ?? this.previewSubtleText,
      previewSelectedBackground:
          previewSelectedBackground ?? this.previewSelectedBackground,
      previewSelectedBorder:
          previewSelectedBorder ?? this.previewSelectedBorder,
      propertyCardBackground:
          propertyCardBackground ?? this.propertyCardBackground,
      propertyCardSelectedBackground:
          propertyCardSelectedBackground ?? this.propertyCardSelectedBackground,
    );
  }

  @override
  FormBrowseThemeColors lerp(
    covariant ThemeExtension<FormBrowseThemeColors>? other,
    double t,
  ) {
    if (other is! FormBrowseThemeColors) {
      return this;
    }

    return FormBrowseThemeColors(
      pageGradient: List<Color>.generate(
        pageGradient.length,
        (index) =>
            Color.lerp(pageGradient[index], other.pageGradient[index], t)!,
      ),
      heroGlow: Color.lerp(heroGlow, other.heroGlow, t)!,
      shellBackground: Color.lerp(shellBackground, other.shellBackground, t)!,
      shellBorder: Color.lerp(shellBorder, other.shellBorder, t)!,
      shellShadow: Color.lerp(shellShadow, other.shellShadow, t)!,
      panelBackground: Color.lerp(panelBackground, other.panelBackground, t)!,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t)!,
      panelShadow: Color.lerp(panelShadow, other.panelShadow, t)!,
      headerBackground:
          Color.lerp(headerBackground, other.headerBackground, t)!,
      headerForeground:
          Color.lerp(headerForeground, other.headerForeground, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipForeground: Color.lerp(chipForeground, other.chipForeground, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      listSelectedBackground: Color.lerp(
        listSelectedBackground,
        other.listSelectedBackground,
        t,
      )!,
      previewFrameBackground: Color.lerp(
        previewFrameBackground,
        other.previewFrameBackground,
        t,
      )!,
      previewFrameBorder:
          Color.lerp(previewFrameBorder, other.previewFrameBorder, t)!,
      previewFrameShadow:
          Color.lerp(previewFrameShadow, other.previewFrameShadow, t)!,
      previewSurface: Color.lerp(previewSurface, other.previewSurface, t)!,
      previewSubtleText:
          Color.lerp(previewSubtleText, other.previewSubtleText, t)!,
      previewSelectedBackground: Color.lerp(
        previewSelectedBackground,
        other.previewSelectedBackground,
        t,
      )!,
      previewSelectedBorder: Color.lerp(
        previewSelectedBorder,
        other.previewSelectedBorder,
        t,
      )!,
      propertyCardBackground: Color.lerp(
        propertyCardBackground,
        other.propertyCardBackground,
        t,
      )!,
      propertyCardSelectedBackground: Color.lerp(
        propertyCardSelectedBackground,
        other.propertyCardSelectedBackground,
        t,
      )!,
    );
  }
}
