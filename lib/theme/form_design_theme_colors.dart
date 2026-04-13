import 'package:flutter/material.dart';

class FormDesignThemeColors extends ThemeExtension<FormDesignThemeColors> {
  final List<Color> pageGradient;
  final Color heroGlow;
  final Color shellBackground;
  final Color shellBorder;
  final Color shellShadow;
  final Color sectionPanelBackground;
  final Color canvasPanelBackground;
  final Color infoPanelBackground;
  final Color panelBorder;
  final Color panelShadow;
  final Color headerAccentBackground;
  final Color headerAccentForeground;
  final Color headerChipBackground;
  final Color headerChipText;
  final Color statsCardBackground;
  final Color statsCardBorder;
  final Color sectionCardBackground;
  final Color sectionCardBorder;
  final Color sectionCardShadow;
  final Color sectionIconBackground;
  final Color sectionIconColor;
  final Color canvasCardBackground;
  final Color canvasCardBorder;
  final Color canvasCardShadow;
  final Color infoRowBackground;
  final Color infoRowBorder;
  final Color emptyStateBackground;
  final Color emptyStateBorder;
  final Color emptyStateIconBackground;
  final Color emptyStateIconColor;
  final Color subtleText;
  final Color faintText;
  final Color actionButtonAccent;
  final Color actionDropdownAccent;
  final Color actionWarning;
  final Color actionInfo;
  final Color actionSuccess;

  const FormDesignThemeColors({
    required this.pageGradient,
    required this.heroGlow,
    required this.shellBackground,
    required this.shellBorder,
    required this.shellShadow,
    required this.sectionPanelBackground,
    required this.canvasPanelBackground,
    required this.infoPanelBackground,
    required this.panelBorder,
    required this.panelShadow,
    required this.headerAccentBackground,
    required this.headerAccentForeground,
    required this.headerChipBackground,
    required this.headerChipText,
    required this.statsCardBackground,
    required this.statsCardBorder,
    required this.sectionCardBackground,
    required this.sectionCardBorder,
    required this.sectionCardShadow,
    required this.sectionIconBackground,
    required this.sectionIconColor,
    required this.canvasCardBackground,
    required this.canvasCardBorder,
    required this.canvasCardShadow,
    required this.infoRowBackground,
    required this.infoRowBorder,
    required this.emptyStateBackground,
    required this.emptyStateBorder,
    required this.emptyStateIconBackground,
    required this.emptyStateIconColor,
    required this.subtleText,
    required this.faintText,
    required this.actionButtonAccent,
    required this.actionDropdownAccent,
    required this.actionWarning,
    required this.actionInfo,
    required this.actionSuccess,
  });

  @override
  FormDesignThemeColors copyWith({
    List<Color>? pageGradient,
    Color? heroGlow,
    Color? shellBackground,
    Color? shellBorder,
    Color? shellShadow,
    Color? sectionPanelBackground,
    Color? canvasPanelBackground,
    Color? infoPanelBackground,
    Color? panelBorder,
    Color? panelShadow,
    Color? headerAccentBackground,
    Color? headerAccentForeground,
    Color? headerChipBackground,
    Color? headerChipText,
    Color? statsCardBackground,
    Color? statsCardBorder,
    Color? sectionCardBackground,
    Color? sectionCardBorder,
    Color? sectionCardShadow,
    Color? sectionIconBackground,
    Color? sectionIconColor,
    Color? canvasCardBackground,
    Color? canvasCardBorder,
    Color? canvasCardShadow,
    Color? infoRowBackground,
    Color? infoRowBorder,
    Color? emptyStateBackground,
    Color? emptyStateBorder,
    Color? emptyStateIconBackground,
    Color? emptyStateIconColor,
    Color? subtleText,
    Color? faintText,
    Color? actionButtonAccent,
    Color? actionDropdownAccent,
    Color? actionWarning,
    Color? actionInfo,
    Color? actionSuccess,
  }) {
    return FormDesignThemeColors(
      pageGradient: pageGradient ?? this.pageGradient,
      heroGlow: heroGlow ?? this.heroGlow,
      shellBackground: shellBackground ?? this.shellBackground,
      shellBorder: shellBorder ?? this.shellBorder,
      shellShadow: shellShadow ?? this.shellShadow,
      sectionPanelBackground:
          sectionPanelBackground ?? this.sectionPanelBackground,
      canvasPanelBackground:
          canvasPanelBackground ?? this.canvasPanelBackground,
      infoPanelBackground: infoPanelBackground ?? this.infoPanelBackground,
      panelBorder: panelBorder ?? this.panelBorder,
      panelShadow: panelShadow ?? this.panelShadow,
      headerAccentBackground:
          headerAccentBackground ?? this.headerAccentBackground,
      headerAccentForeground:
          headerAccentForeground ?? this.headerAccentForeground,
      headerChipBackground: headerChipBackground ?? this.headerChipBackground,
      headerChipText: headerChipText ?? this.headerChipText,
      statsCardBackground: statsCardBackground ?? this.statsCardBackground,
      statsCardBorder: statsCardBorder ?? this.statsCardBorder,
      sectionCardBackground:
          sectionCardBackground ?? this.sectionCardBackground,
      sectionCardBorder: sectionCardBorder ?? this.sectionCardBorder,
      sectionCardShadow: sectionCardShadow ?? this.sectionCardShadow,
      sectionIconBackground:
          sectionIconBackground ?? this.sectionIconBackground,
      sectionIconColor: sectionIconColor ?? this.sectionIconColor,
      canvasCardBackground: canvasCardBackground ?? this.canvasCardBackground,
      canvasCardBorder: canvasCardBorder ?? this.canvasCardBorder,
      canvasCardShadow: canvasCardShadow ?? this.canvasCardShadow,
      infoRowBackground: infoRowBackground ?? this.infoRowBackground,
      infoRowBorder: infoRowBorder ?? this.infoRowBorder,
      emptyStateBackground: emptyStateBackground ?? this.emptyStateBackground,
      emptyStateBorder: emptyStateBorder ?? this.emptyStateBorder,
      emptyStateIconBackground:
          emptyStateIconBackground ?? this.emptyStateIconBackground,
      emptyStateIconColor: emptyStateIconColor ?? this.emptyStateIconColor,
      subtleText: subtleText ?? this.subtleText,
      faintText: faintText ?? this.faintText,
      actionButtonAccent: actionButtonAccent ?? this.actionButtonAccent,
      actionDropdownAccent: actionDropdownAccent ?? this.actionDropdownAccent,
      actionWarning: actionWarning ?? this.actionWarning,
      actionInfo: actionInfo ?? this.actionInfo,
      actionSuccess: actionSuccess ?? this.actionSuccess,
    );
  }

  @override
  FormDesignThemeColors lerp(
    covariant ThemeExtension<FormDesignThemeColors>? other,
    double t,
  ) {
    if (other is! FormDesignThemeColors) {
      return this;
    }

    return FormDesignThemeColors(
      pageGradient: List<Color>.generate(
        pageGradient.length,
        (index) =>
            Color.lerp(pageGradient[index], other.pageGradient[index], t)!,
      ),
      heroGlow: Color.lerp(heroGlow, other.heroGlow, t)!,
      shellBackground: Color.lerp(shellBackground, other.shellBackground, t)!,
      shellBorder: Color.lerp(shellBorder, other.shellBorder, t)!,
      shellShadow: Color.lerp(shellShadow, other.shellShadow, t)!,
      sectionPanelBackground: Color.lerp(
        sectionPanelBackground,
        other.sectionPanelBackground,
        t,
      )!,
      canvasPanelBackground: Color.lerp(
        canvasPanelBackground,
        other.canvasPanelBackground,
        t,
      )!,
      infoPanelBackground: Color.lerp(
        infoPanelBackground,
        other.infoPanelBackground,
        t,
      )!,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t)!,
      panelShadow: Color.lerp(panelShadow, other.panelShadow, t)!,
      headerAccentBackground: Color.lerp(
        headerAccentBackground,
        other.headerAccentBackground,
        t,
      )!,
      headerAccentForeground: Color.lerp(
        headerAccentForeground,
        other.headerAccentForeground,
        t,
      )!,
      headerChipBackground: Color.lerp(
        headerChipBackground,
        other.headerChipBackground,
        t,
      )!,
      headerChipText: Color.lerp(headerChipText, other.headerChipText, t)!,
      statsCardBackground: Color.lerp(
        statsCardBackground,
        other.statsCardBackground,
        t,
      )!,
      statsCardBorder: Color.lerp(statsCardBorder, other.statsCardBorder, t)!,
      sectionCardBackground: Color.lerp(
        sectionCardBackground,
        other.sectionCardBackground,
        t,
      )!,
      sectionCardBorder:
          Color.lerp(sectionCardBorder, other.sectionCardBorder, t)!,
      sectionCardShadow:
          Color.lerp(sectionCardShadow, other.sectionCardShadow, t)!,
      sectionIconBackground: Color.lerp(
        sectionIconBackground,
        other.sectionIconBackground,
        t,
      )!,
      sectionIconColor:
          Color.lerp(sectionIconColor, other.sectionIconColor, t)!,
      canvasCardBackground: Color.lerp(
        canvasCardBackground,
        other.canvasCardBackground,
        t,
      )!,
      canvasCardBorder:
          Color.lerp(canvasCardBorder, other.canvasCardBorder, t)!,
      canvasCardShadow:
          Color.lerp(canvasCardShadow, other.canvasCardShadow, t)!,
      infoRowBackground:
          Color.lerp(infoRowBackground, other.infoRowBackground, t)!,
      infoRowBorder: Color.lerp(infoRowBorder, other.infoRowBorder, t)!,
      emptyStateBackground: Color.lerp(
        emptyStateBackground,
        other.emptyStateBackground,
        t,
      )!,
      emptyStateBorder:
          Color.lerp(emptyStateBorder, other.emptyStateBorder, t)!,
      emptyStateIconBackground: Color.lerp(
        emptyStateIconBackground,
        other.emptyStateIconBackground,
        t,
      )!,
      emptyStateIconColor: Color.lerp(
        emptyStateIconColor,
        other.emptyStateIconColor,
        t,
      )!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      faintText: Color.lerp(faintText, other.faintText, t)!,
      actionButtonAccent:
          Color.lerp(actionButtonAccent, other.actionButtonAccent, t)!,
      actionDropdownAccent:
          Color.lerp(actionDropdownAccent, other.actionDropdownAccent, t)!,
      actionWarning: Color.lerp(actionWarning, other.actionWarning, t)!,
      actionInfo: Color.lerp(actionInfo, other.actionInfo, t)!,
      actionSuccess: Color.lerp(actionSuccess, other.actionSuccess, t)!,
    );
  }
}
