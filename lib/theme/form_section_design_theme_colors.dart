import 'package:flutter/material.dart';

class FormSectionDesignThemeColors
    extends ThemeExtension<FormSectionDesignThemeColors> {
  final Color paletteBackground;
  final Color canvasBackground;
  final Color propertiesBackground;
  final Color surface;
  final Color border;
  final Color panelBorder;
  final Color panelShadow;
  final Color paletteHeaderBackground;
  final Color canvasHeaderBackground;
  final Color propertiesHeaderBackground;
  final Color actionBarBackground;
  final Color tileBackground;
  final Color tileBorder;
  final Color tileIconBackground;
  final Color tileIconColor;
  final Color tileShadow;
  final Color selectedBorder;
  final Color selectedFill;
  final Color selectedShadow;
  final Color hoverBorder;
  final Color hoverFill;
  final Color emptyStateBackground;
  final Color textPrimary;
  final Color textMuted;
  final Color textFaint;
  final Color hintText;
  final Color dragHandle;
  final Color destructive;
  final Color destructiveSoft;

  const FormSectionDesignThemeColors({
    required this.paletteBackground,
    required this.canvasBackground,
    required this.propertiesBackground,
    required this.surface,
    required this.border,
    required this.panelBorder,
    required this.panelShadow,
    required this.paletteHeaderBackground,
    required this.canvasHeaderBackground,
    required this.propertiesHeaderBackground,
    required this.actionBarBackground,
    required this.tileBackground,
    required this.tileBorder,
    required this.tileIconBackground,
    required this.tileIconColor,
    required this.tileShadow,
    required this.selectedBorder,
    required this.selectedFill,
    required this.selectedShadow,
    required this.hoverBorder,
    required this.hoverFill,
    required this.emptyStateBackground,
    required this.textPrimary,
    required this.textMuted,
    required this.textFaint,
    required this.hintText,
    required this.dragHandle,
    required this.destructive,
    required this.destructiveSoft,
  });

  @override
  FormSectionDesignThemeColors copyWith({
    Color? paletteBackground,
    Color? canvasBackground,
    Color? propertiesBackground,
    Color? surface,
    Color? border,
    Color? panelBorder,
    Color? panelShadow,
    Color? paletteHeaderBackground,
    Color? canvasHeaderBackground,
    Color? propertiesHeaderBackground,
    Color? actionBarBackground,
    Color? tileBackground,
    Color? tileBorder,
    Color? tileIconBackground,
    Color? tileIconColor,
    Color? tileShadow,
    Color? selectedBorder,
    Color? selectedFill,
    Color? selectedShadow,
    Color? hoverBorder,
    Color? hoverFill,
    Color? emptyStateBackground,
    Color? textPrimary,
    Color? textMuted,
    Color? textFaint,
    Color? hintText,
    Color? dragHandle,
    Color? destructive,
    Color? destructiveSoft,
  }) {
    return FormSectionDesignThemeColors(
      paletteBackground: paletteBackground ?? this.paletteBackground,
      canvasBackground: canvasBackground ?? this.canvasBackground,
      propertiesBackground: propertiesBackground ?? this.propertiesBackground,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      panelBorder: panelBorder ?? this.panelBorder,
      panelShadow: panelShadow ?? this.panelShadow,
      paletteHeaderBackground:
          paletteHeaderBackground ?? this.paletteHeaderBackground,
      canvasHeaderBackground:
          canvasHeaderBackground ?? this.canvasHeaderBackground,
      propertiesHeaderBackground:
          propertiesHeaderBackground ?? this.propertiesHeaderBackground,
      actionBarBackground: actionBarBackground ?? this.actionBarBackground,
      tileBackground: tileBackground ?? this.tileBackground,
      tileBorder: tileBorder ?? this.tileBorder,
      tileIconBackground: tileIconBackground ?? this.tileIconBackground,
      tileIconColor: tileIconColor ?? this.tileIconColor,
      tileShadow: tileShadow ?? this.tileShadow,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      selectedFill: selectedFill ?? this.selectedFill,
      selectedShadow: selectedShadow ?? this.selectedShadow,
      hoverBorder: hoverBorder ?? this.hoverBorder,
      hoverFill: hoverFill ?? this.hoverFill,
      emptyStateBackground: emptyStateBackground ?? this.emptyStateBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      hintText: hintText ?? this.hintText,
      dragHandle: dragHandle ?? this.dragHandle,
      destructive: destructive ?? this.destructive,
      destructiveSoft: destructiveSoft ?? this.destructiveSoft,
    );
  }

  @override
  FormSectionDesignThemeColors lerp(
    covariant ThemeExtension<FormSectionDesignThemeColors>? other,
    double t,
  ) {
    if (other is! FormSectionDesignThemeColors) {
      return this;
    }

    return FormSectionDesignThemeColors(
      paletteBackground:
          Color.lerp(paletteBackground, other.paletteBackground, t)!,
      canvasBackground:
          Color.lerp(canvasBackground, other.canvasBackground, t)!,
      propertiesBackground:
          Color.lerp(propertiesBackground, other.propertiesBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t)!,
      panelShadow: Color.lerp(panelShadow, other.panelShadow, t)!,
      paletteHeaderBackground: Color.lerp(
        paletteHeaderBackground,
        other.paletteHeaderBackground,
        t,
      )!,
      canvasHeaderBackground: Color.lerp(
        canvasHeaderBackground,
        other.canvasHeaderBackground,
        t,
      )!,
      propertiesHeaderBackground: Color.lerp(
        propertiesHeaderBackground,
        other.propertiesHeaderBackground,
        t,
      )!,
      actionBarBackground:
          Color.lerp(actionBarBackground, other.actionBarBackground, t)!,
      tileBackground: Color.lerp(tileBackground, other.tileBackground, t)!,
      tileBorder: Color.lerp(tileBorder, other.tileBorder, t)!,
      tileIconBackground:
          Color.lerp(tileIconBackground, other.tileIconBackground, t)!,
      tileIconColor: Color.lerp(tileIconColor, other.tileIconColor, t)!,
      tileShadow: Color.lerp(tileShadow, other.tileShadow, t)!,
      selectedBorder: Color.lerp(selectedBorder, other.selectedBorder, t)!,
      selectedFill: Color.lerp(selectedFill, other.selectedFill, t)!,
      selectedShadow: Color.lerp(selectedShadow, other.selectedShadow, t)!,
      hoverBorder: Color.lerp(hoverBorder, other.hoverBorder, t)!,
      hoverFill: Color.lerp(hoverFill, other.hoverFill, t)!,
      emptyStateBackground:
          Color.lerp(emptyStateBackground, other.emptyStateBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      hintText: Color.lerp(hintText, other.hintText, t)!,
      dragHandle: Color.lerp(dragHandle, other.dragHandle, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      destructiveSoft: Color.lerp(destructiveSoft, other.destructiveSoft, t)!,
    );
  }
}
