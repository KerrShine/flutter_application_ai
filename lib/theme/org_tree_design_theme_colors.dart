import 'package:flutter/material.dart';

class OrgTreeDesignThemeColors
    extends ThemeExtension<OrgTreeDesignThemeColors> {
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
  final Color headerChipBackground;
  final Color headerChipForeground;
  final Color mutedText;
  final Color subtleText;
  final Color sourceSelectedBackground;
  final Color sourcePlacedBackground;
  final Color canvasOuterBackground;
  final Color canvasOuterBorder;
  final Color canvasSurface;
  final Color canvasBorder;
  final Color canvasShadow;
  final Color canvasBadgeBackground;
  final Color canvasBadgeBorder;
  final Color gridMinor;
  final Color gridMajor;
  final Color connection;
  final Color nodeBackground;
  final Color nodeBorder;
  final Color nodeTitle;
  final Color nodeSubtitle;
  final Color nodeShadow;
  final Color nodeSelectedBackground;
  final Color nodeSelectedBorder;
  final Color nodeSelectedTitle;
  final Color nodeSelectedSubtitle;
  final Color nodeHighlightedBackground;
  final Color nodeHighlightedBorder;
  final Color nodeHighlightedTitle;
  final Color nodeHighlightedSubtitle;
  final Color nodeHighlightedShadow;
  final Color zoomBackground;
  final Color zoomBorder;

  const OrgTreeDesignThemeColors({
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
    required this.headerChipBackground,
    required this.headerChipForeground,
    required this.mutedText,
    required this.subtleText,
    required this.sourceSelectedBackground,
    required this.sourcePlacedBackground,
    required this.canvasOuterBackground,
    required this.canvasOuterBorder,
    required this.canvasSurface,
    required this.canvasBorder,
    required this.canvasShadow,
    required this.canvasBadgeBackground,
    required this.canvasBadgeBorder,
    required this.gridMinor,
    required this.gridMajor,
    required this.connection,
    required this.nodeBackground,
    required this.nodeBorder,
    required this.nodeTitle,
    required this.nodeSubtitle,
    required this.nodeShadow,
    required this.nodeSelectedBackground,
    required this.nodeSelectedBorder,
    required this.nodeSelectedTitle,
    required this.nodeSelectedSubtitle,
    required this.nodeHighlightedBackground,
    required this.nodeHighlightedBorder,
    required this.nodeHighlightedTitle,
    required this.nodeHighlightedSubtitle,
    required this.nodeHighlightedShadow,
    required this.zoomBackground,
    required this.zoomBorder,
  });

  @override
  OrgTreeDesignThemeColors copyWith({
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
    Color? headerChipBackground,
    Color? headerChipForeground,
    Color? mutedText,
    Color? subtleText,
    Color? sourceSelectedBackground,
    Color? sourcePlacedBackground,
    Color? canvasOuterBackground,
    Color? canvasOuterBorder,
    Color? canvasSurface,
    Color? canvasBorder,
    Color? canvasShadow,
    Color? canvasBadgeBackground,
    Color? canvasBadgeBorder,
    Color? gridMinor,
    Color? gridMajor,
    Color? connection,
    Color? nodeBackground,
    Color? nodeBorder,
    Color? nodeTitle,
    Color? nodeSubtitle,
    Color? nodeShadow,
    Color? nodeSelectedBackground,
    Color? nodeSelectedBorder,
    Color? nodeSelectedTitle,
    Color? nodeSelectedSubtitle,
    Color? nodeHighlightedBackground,
    Color? nodeHighlightedBorder,
    Color? nodeHighlightedTitle,
    Color? nodeHighlightedSubtitle,
    Color? nodeHighlightedShadow,
    Color? zoomBackground,
    Color? zoomBorder,
  }) {
    return OrgTreeDesignThemeColors(
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
      headerChipBackground: headerChipBackground ?? this.headerChipBackground,
      headerChipForeground: headerChipForeground ?? this.headerChipForeground,
      mutedText: mutedText ?? this.mutedText,
      subtleText: subtleText ?? this.subtleText,
      sourceSelectedBackground:
          sourceSelectedBackground ?? this.sourceSelectedBackground,
      sourcePlacedBackground:
          sourcePlacedBackground ?? this.sourcePlacedBackground,
      canvasOuterBackground:
          canvasOuterBackground ?? this.canvasOuterBackground,
      canvasOuterBorder: canvasOuterBorder ?? this.canvasOuterBorder,
      canvasSurface: canvasSurface ?? this.canvasSurface,
      canvasBorder: canvasBorder ?? this.canvasBorder,
      canvasShadow: canvasShadow ?? this.canvasShadow,
      canvasBadgeBackground:
          canvasBadgeBackground ?? this.canvasBadgeBackground,
      canvasBadgeBorder: canvasBadgeBorder ?? this.canvasBadgeBorder,
      gridMinor: gridMinor ?? this.gridMinor,
      gridMajor: gridMajor ?? this.gridMajor,
      connection: connection ?? this.connection,
      nodeBackground: nodeBackground ?? this.nodeBackground,
      nodeBorder: nodeBorder ?? this.nodeBorder,
      nodeTitle: nodeTitle ?? this.nodeTitle,
      nodeSubtitle: nodeSubtitle ?? this.nodeSubtitle,
      nodeShadow: nodeShadow ?? this.nodeShadow,
      nodeSelectedBackground:
          nodeSelectedBackground ?? this.nodeSelectedBackground,
      nodeSelectedBorder: nodeSelectedBorder ?? this.nodeSelectedBorder,
      nodeSelectedTitle: nodeSelectedTitle ?? this.nodeSelectedTitle,
      nodeSelectedSubtitle: nodeSelectedSubtitle ?? this.nodeSelectedSubtitle,
      nodeHighlightedBackground:
          nodeHighlightedBackground ?? this.nodeHighlightedBackground,
      nodeHighlightedBorder:
          nodeHighlightedBorder ?? this.nodeHighlightedBorder,
      nodeHighlightedTitle: nodeHighlightedTitle ?? this.nodeHighlightedTitle,
      nodeHighlightedSubtitle:
          nodeHighlightedSubtitle ?? this.nodeHighlightedSubtitle,
      nodeHighlightedShadow:
          nodeHighlightedShadow ?? this.nodeHighlightedShadow,
      zoomBackground: zoomBackground ?? this.zoomBackground,
      zoomBorder: zoomBorder ?? this.zoomBorder,
    );
  }

  @override
  OrgTreeDesignThemeColors lerp(
    covariant ThemeExtension<OrgTreeDesignThemeColors>? other,
    double t,
  ) {
    if (other is! OrgTreeDesignThemeColors) {
      return this;
    }

    return OrgTreeDesignThemeColors(
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
      headerChipBackground: Color.lerp(
        headerChipBackground,
        other.headerChipBackground,
        t,
      )!,
      headerChipForeground: Color.lerp(
        headerChipForeground,
        other.headerChipForeground,
        t,
      )!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      sourceSelectedBackground: Color.lerp(
        sourceSelectedBackground,
        other.sourceSelectedBackground,
        t,
      )!,
      sourcePlacedBackground: Color.lerp(
        sourcePlacedBackground,
        other.sourcePlacedBackground,
        t,
      )!,
      canvasOuterBackground: Color.lerp(
        canvasOuterBackground,
        other.canvasOuterBackground,
        t,
      )!,
      canvasOuterBorder:
          Color.lerp(canvasOuterBorder, other.canvasOuterBorder, t)!,
      canvasSurface: Color.lerp(canvasSurface, other.canvasSurface, t)!,
      canvasBorder: Color.lerp(canvasBorder, other.canvasBorder, t)!,
      canvasShadow: Color.lerp(canvasShadow, other.canvasShadow, t)!,
      canvasBadgeBackground: Color.lerp(
        canvasBadgeBackground,
        other.canvasBadgeBackground,
        t,
      )!,
      canvasBadgeBorder:
          Color.lerp(canvasBadgeBorder, other.canvasBadgeBorder, t)!,
      gridMinor: Color.lerp(gridMinor, other.gridMinor, t)!,
      gridMajor: Color.lerp(gridMajor, other.gridMajor, t)!,
      connection: Color.lerp(connection, other.connection, t)!,
      nodeBackground: Color.lerp(nodeBackground, other.nodeBackground, t)!,
      nodeBorder: Color.lerp(nodeBorder, other.nodeBorder, t)!,
      nodeTitle: Color.lerp(nodeTitle, other.nodeTitle, t)!,
      nodeSubtitle: Color.lerp(nodeSubtitle, other.nodeSubtitle, t)!,
      nodeShadow: Color.lerp(nodeShadow, other.nodeShadow, t)!,
      nodeSelectedBackground: Color.lerp(
        nodeSelectedBackground,
        other.nodeSelectedBackground,
        t,
      )!,
      nodeSelectedBorder: Color.lerp(
        nodeSelectedBorder,
        other.nodeSelectedBorder,
        t,
      )!,
      nodeSelectedTitle:
          Color.lerp(nodeSelectedTitle, other.nodeSelectedTitle, t)!,
      nodeSelectedSubtitle: Color.lerp(
        nodeSelectedSubtitle,
        other.nodeSelectedSubtitle,
        t,
      )!,
      nodeHighlightedBackground: Color.lerp(
        nodeHighlightedBackground,
        other.nodeHighlightedBackground,
        t,
      )!,
      nodeHighlightedBorder: Color.lerp(
        nodeHighlightedBorder,
        other.nodeHighlightedBorder,
        t,
      )!,
      nodeHighlightedTitle: Color.lerp(
        nodeHighlightedTitle,
        other.nodeHighlightedTitle,
        t,
      )!,
      nodeHighlightedSubtitle: Color.lerp(
        nodeHighlightedSubtitle,
        other.nodeHighlightedSubtitle,
        t,
      )!,
      nodeHighlightedShadow: Color.lerp(
        nodeHighlightedShadow,
        other.nodeHighlightedShadow,
        t,
      )!,
      zoomBackground: Color.lerp(zoomBackground, other.zoomBackground, t)!,
      zoomBorder: Color.lerp(zoomBorder, other.zoomBorder, t)!,
    );
  }
}
