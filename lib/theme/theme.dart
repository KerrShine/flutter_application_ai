import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/app_colors.dart';
import 'package:flutter_application_ai/theme/emp_agent_theme_colors.dart';
import 'package:flutter_application_ai/theme/emp_info_theme_colors.dart';
import 'package:flutter_application_ai/theme/emp_manager_theme_colors.dart';
import 'package:flutter_application_ai/theme/form_browse_theme_colors.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';
import 'package:flutter_application_ai/theme/login_theme_colors.dart';
import 'package:flutter_application_ai/theme/org_tree_design_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceVariant =
        isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    // EmpInfoPage、EmpInfoHeaderWidget 使用
    final empInfoThemeColors = isDark
        ? const EmpInfoThemeColors(
            actionColor: AppColors.empInfoActionColorDark,
            breadcrumbText: AppColors.empInfoBreadcrumbTextDark,
            headlineText: AppColors.empInfoHeadlineTextDark,
          )
        : const EmpInfoThemeColors(
            actionColor: AppColors.empInfoActionColorLight,
            breadcrumbText: AppColors.empInfoBreadcrumbTextLight,
            headlineText: AppColors.empInfoHeadlineTextLight,
          );

    // EmpManagerPage、EmpManagerFeatureEntryCardWidget、EmpManagerSectionTitleWidget 使用
    final empManagerThemeColors = isDark
        ? const EmpManagerThemeColors(
            iconContainerBackground:
                AppColors.empManagerIconContainerBackgroundDark,
            iconColor: AppColors.empManagerIconColorDark,
            subtitleText: AppColors.empManagerSubtitleTextDark,
          )
        : const EmpManagerThemeColors(
            iconContainerBackground:
                AppColors.empManagerIconContainerBackgroundLight,
            iconColor: AppColors.empManagerIconColorLight,
            subtitleText: AppColors.empManagerSubtitleTextLight,
          );

    // LoginPage、LoginFormWidget、ThemeModeSelectorWidget 使用
    final loginThemeColors = isDark
        ? const LoginThemeColors(
            backgroundGradient: [
              AppColors.loginGradientStartDark,
              AppColors.loginGradientMiddleDark,
              AppColors.loginGradientEndDark,
            ],
            heroShadowColor: AppColors.loginHeroShadow,
            panelShadowColor: AppColors.loginPanelShadowDark,
            selectorBackgroundColor: AppColors.loginSelectorBackgroundDark,
          )
        : const LoginThemeColors(
            backgroundGradient: [
              AppColors.loginGradientStartLight,
              AppColors.loginGradientMiddleLight,
              AppColors.loginGradientEndLight,
            ],
            heroShadowColor: AppColors.loginHeroShadow,
            panelShadowColor: AppColors.loginPanelShadowLight,
            selectorBackgroundColor: AppColors.loginSelectorBackgroundLight,
          );

    // EmpAgentPage、EmpAgentPrincipalSectionWidget、EmpAgentAgentSectionWidget、
    // EmpAgentEmployeeSummaryWidget、EmpAgentAssignmentListPanelWidget 使用
    final empAgentThemeColors = isDark
        ? const EmpAgentThemeColors(
            pageBackground: AppColors.empAgentPageBackgroundDark,
            panelBackground: AppColors.empAgentPanelBackgroundDark,
            panelBorder: AppColors.empAgentPanelBorderDark,
            panelShadow: AppColors.empAgentPanelShadowDark,
            stepTitle: AppColors.empAgentStepTitleDark,
            divider: AppColors.empAgentDividerDark,
            dropdownBackground: AppColors.empAgentDropdownBackgroundDark,
            dropdownBorder: AppColors.empAgentDropdownBorderDark,
            dropdownLabel: AppColors.empAgentDropdownLabelDark,
            dropdownFocus: AppColors.empAgentDropdownFocusDark,
            inputText: AppColors.empAgentInputTextDark,
            mutedText: AppColors.empAgentMutedTextDark,
            subtleText: AppColors.empAgentSubtleTextDark,
            candidateBackground: AppColors.empAgentCandidateBackgroundDark,
            candidateSelectedBackground:
                AppColors.empAgentCandidateSelectedBackgroundDark,
            candidateBorder: AppColors.empAgentCandidateBorderDark,
            candidateSelectedBorder:
                AppColors.empAgentCandidateSelectedBorderDark,
            candidateAvatarBackground:
                AppColors.empAgentCandidateAvatarBackgroundDark,
            candidateSelectedAvatarBackground:
                AppColors.empAgentCandidateSelectedAvatarBackgroundDark,
            candidateSelectedName: AppColors.empAgentCandidateSelectedNameDark,
            candidateSelectedRole: AppColors.empAgentCandidateSelectedRoleDark,
            summaryBackground: AppColors.empAgentSummaryBackgroundDark,
            summaryBorder: AppColors.empAgentSummaryBorderDark,
            summaryAvatarBackground:
                AppColors.empAgentSummaryAvatarBackgroundDark,
            summaryAvatarText: AppColors.empAgentSummaryAvatarTextDark,
            statusActiveBackground: AppColors.empAgentStatusActiveBackground,
            statusInactiveBackground:
                AppColors.empAgentStatusInactiveBackground,
            statusActiveText: AppColors.empAgentStatusActiveText,
            statusInactiveText: AppColors.empAgentStatusInactiveText,
            primaryAction: AppColors.empAgentPrimaryAction,
            arrowAccent: AppColors.empAgentArrowAccentDark,
            deleteText: AppColors.empAgentDeleteTextDark,
            deleteBorder: AppColors.empAgentDeleteBorderDark,
            filterIcon: AppColors.empAgentFilterIconDark,
            footerGhostBorder: AppColors.empAgentFooterGhostBorderDark,
            footerPrimaryBackground: AppColors.empAgentFooterPrimaryBackground,
            infoBlockTitle: AppColors.empAgentInfoBlockTitleDark,
            infoBlockText: AppColors.empAgentInfoBlockTextDark,
          )
        : const EmpAgentThemeColors(
            pageBackground: AppColors.empAgentPageBackgroundLight,
            panelBackground: AppColors.empAgentPanelBackgroundLight,
            panelBorder: AppColors.empAgentPanelBorderLight,
            panelShadow: AppColors.empAgentPanelShadowLight,
            stepTitle: AppColors.empAgentStepTitleLight,
            divider: AppColors.empAgentDividerLight,
            dropdownBackground: AppColors.empAgentDropdownBackgroundLight,
            dropdownBorder: AppColors.empAgentDropdownBorderLight,
            dropdownLabel: AppColors.empAgentDropdownLabelLight,
            dropdownFocus: AppColors.empAgentDropdownFocusLight,
            inputText: AppColors.empAgentInputTextLight,
            mutedText: AppColors.empAgentMutedTextLight,
            subtleText: AppColors.empAgentSubtleTextLight,
            candidateBackground: AppColors.empAgentCandidateBackgroundLight,
            candidateSelectedBackground:
                AppColors.empAgentCandidateSelectedBackgroundLight,
            candidateBorder: AppColors.empAgentCandidateBorderLight,
            candidateSelectedBorder:
                AppColors.empAgentCandidateSelectedBorderLight,
            candidateAvatarBackground:
                AppColors.empAgentCandidateAvatarBackgroundLight,
            candidateSelectedAvatarBackground:
                AppColors.empAgentCandidateSelectedAvatarBackgroundLight,
            candidateSelectedName: AppColors.empAgentCandidateSelectedNameLight,
            candidateSelectedRole: AppColors.empAgentCandidateSelectedRoleLight,
            summaryBackground: AppColors.empAgentSummaryBackgroundLight,
            summaryBorder: AppColors.empAgentSummaryBorderLight,
            summaryAvatarBackground:
                AppColors.empAgentSummaryAvatarBackgroundLight,
            summaryAvatarText: AppColors.empAgentSummaryAvatarTextLight,
            statusActiveBackground: AppColors.empAgentStatusActiveBackground,
            statusInactiveBackground:
                AppColors.empAgentStatusInactiveBackground,
            statusActiveText: AppColors.empAgentStatusActiveText,
            statusInactiveText: AppColors.empAgentStatusInactiveText,
            primaryAction: AppColors.empAgentPrimaryAction,
            arrowAccent: AppColors.empAgentArrowAccentLight,
            deleteText: AppColors.empAgentDeleteTextLight,
            deleteBorder: AppColors.empAgentDeleteBorderLight,
            filterIcon: AppColors.empAgentFilterIconLight,
            footerGhostBorder: AppColors.empAgentFooterGhostBorderLight,
            footerPrimaryBackground: AppColors.empAgentFooterPrimaryBackground,
            infoBlockTitle: AppColors.empAgentInfoBlockTitleLight,
            infoBlockText: AppColors.empAgentInfoBlockTextLight,
          );

    // FormSectionDesignPage、PropertiesPanelWidget、CanvasRowWidget、
    // DesignerItemRowWidget、PaletteItemWidget、PaletteTileWidget、
    // EmptyDropZoneWidget、TrailingDropZoneWidget、DragTargetFrameWidget 使用
    final formSectionDesignThemeColors = FormSectionDesignThemeColors(
      paletteBackground: isDark
          ? AppColors.formSectionPaletteBackgroundDark
          : AppColors.formSectionPaletteBackgroundLight,
      canvasBackground: isDark
          ? AppColors.formSectionCanvasBackgroundDark
          : AppColors.formSectionCanvasBackgroundLight,
      propertiesBackground: isDark
          ? AppColors.formSectionPropertiesBackgroundDark
          : AppColors.formSectionPropertiesBackgroundLight,
      surface: isDark
          ? AppColors.formSectionSurfaceDark
          : AppColors.formSectionSurfaceLight,
      border: isDark
          ? AppColors.formSectionBorderDark
          : AppColors.formSectionBorderLight,
      panelBorder: isDark
          ? AppColors.formSectionPanelBorderDark
          : AppColors.formSectionPanelBorderLight,
      panelShadow: isDark
          ? AppColors.formSectionPanelShadowDark
          : AppColors.formSectionPanelShadowLight,
      paletteHeaderBackground: isDark
          ? AppColors.formSectionPaletteHeaderDark
          : AppColors.formSectionPaletteHeaderLight,
      canvasHeaderBackground: isDark
          ? AppColors.formSectionCanvasHeaderDark
          : AppColors.formSectionCanvasHeaderLight,
      propertiesHeaderBackground: isDark
          ? AppColors.formSectionPropertiesHeaderDark
          : AppColors.formSectionPropertiesHeaderLight,
      actionBarBackground: isDark
          ? AppColors.formSectionActionBarDark
          : AppColors.formSectionActionBarLight,
      tileBackground: isDark
          ? AppColors.formSectionTileBackgroundDark
          : AppColors.formSectionTileBackgroundLight,
      tileBorder: isDark
          ? AppColors.formSectionTileBorderDark
          : AppColors.formSectionTileBorderLight,
      tileIconBackground: isDark
          ? AppColors.formSectionTileIconBackgroundDark
          : AppColors.formSectionTileIconBackgroundLight,
      tileIconColor: isDark
          ? AppColors.formSectionTileIconDark
          : AppColors.formSectionTileIconLight,
      tileShadow: isDark
          ? AppColors.formSectionTileShadowDark
          : AppColors.formSectionTileShadowLight,
      selectedBorder: AppColors.primary,
      selectedFill: isDark
          ? AppColors.formSectionSelectedFillDark
          : AppColors.formSectionSelectedFillLight,
      selectedShadow: isDark
          ? AppColors.formSectionSelectedShadowDark
          : AppColors.formSectionSelectedShadowLight,
      hoverBorder: AppColors.primary,
      hoverFill: isDark
          ? AppColors.formSectionHoverFillDark
          : AppColors.formSectionHoverFillLight,
      emptyStateBackground: isDark
          ? AppColors.formSectionEmptyStateBackgroundDark
          : AppColors.formSectionEmptyStateBackgroundLight,
      textPrimary: textPrimary,
      textMuted: isDark
          ? AppColors.formSectionMutedTextDark
          : AppColors.formSectionMutedTextLight,
      textFaint: isDark
          ? AppColors.formSectionFaintTextDark
          : AppColors.formSectionFaintTextLight,
      hintText: isDark
          ? AppColors.formSectionHintTextDark
          : AppColors.formSectionHintTextLight,
      dragHandle: isDark
          ? AppColors.formSectionMutedTextDark
          : AppColors.formSectionMutedTextLight,
      destructive: AppColors.error,
      destructiveSoft: isDark
          ? AppColors.formSectionDeleteSoftDark
          : AppColors.formSectionDeleteSoftLight,
    );

    // FormDesignPage、AvailableSectionPanelWidget、FormSectionCanvasWidget、
    // FormDesignInfoPanelWidget、SectionCardWidget、InfoRowWidget 使用
    final formDesignThemeColors = isDark
        ? const FormDesignThemeColors(
            pageGradient: [
              AppColors.formDesignGradientStartDark,
              AppColors.formDesignGradientMiddleDark,
              AppColors.formDesignGradientEndDark,
            ],
            heroGlow: AppColors.formDesignHeroGlowDark,
            shellBackground: AppColors.formDesignShellBackgroundDark,
            shellBorder: AppColors.formDesignShellBorderDark,
            shellShadow: AppColors.formDesignShellShadowDark,
            sectionPanelBackground:
                AppColors.formDesignSectionPanelBackgroundDark,
            canvasPanelBackground:
                AppColors.formDesignCanvasPanelBackgroundDark,
            infoPanelBackground: AppColors.formDesignInfoPanelBackgroundDark,
            panelBorder: AppColors.formDesignPanelBorderDark,
            panelShadow: AppColors.formDesignPanelShadowDark,
            headerAccentBackground:
                AppColors.formDesignHeaderAccentBackgroundDark,
            headerAccentForeground:
                AppColors.formDesignHeaderAccentForegroundDark,
            headerChipBackground: AppColors.formDesignHeaderChipBackgroundDark,
            headerChipText: AppColors.formDesignHeaderChipTextDark,
            statsCardBackground: AppColors.formDesignStatsCardBackgroundDark,
            statsCardBorder: AppColors.formDesignStatsCardBorderDark,
            sectionCardBackground:
                AppColors.formDesignSectionCardBackgroundDark,
            sectionCardBorder: AppColors.formDesignSectionCardBorderDark,
            sectionCardShadow: AppColors.formDesignSectionCardShadowDark,
            sectionIconBackground:
                AppColors.formDesignSectionIconBackgroundDark,
            sectionIconColor: AppColors.formDesignSectionIconColorDark,
            canvasCardBackground: AppColors.formDesignCanvasCardBackgroundDark,
            canvasCardBorder: AppColors.formDesignCanvasCardBorderDark,
            canvasCardShadow: AppColors.formDesignCanvasCardShadowDark,
            infoRowBackground: AppColors.formDesignInfoRowBackgroundDark,
            infoRowBorder: AppColors.formDesignInfoRowBorderDark,
            emptyStateBackground: AppColors.formDesignEmptyStateBackgroundDark,
            emptyStateBorder: AppColors.formDesignEmptyStateBorderDark,
            emptyStateIconBackground:
                AppColors.formDesignEmptyStateIconBackgroundDark,
            emptyStateIconColor: AppColors.formDesignEmptyStateIconColorDark,
            subtleText: AppColors.formDesignSubtleTextDark,
            faintText: AppColors.formDesignFaintTextDark,
          )
        : const FormDesignThemeColors(
            pageGradient: [
              AppColors.formDesignGradientStartLight,
              AppColors.formDesignGradientMiddleLight,
              AppColors.formDesignGradientEndLight,
            ],
            heroGlow: AppColors.formDesignHeroGlowLight,
            shellBackground: AppColors.formDesignShellBackgroundLight,
            shellBorder: AppColors.formDesignShellBorderLight,
            shellShadow: AppColors.formDesignShellShadowLight,
            sectionPanelBackground:
                AppColors.formDesignSectionPanelBackgroundLight,
            canvasPanelBackground:
                AppColors.formDesignCanvasPanelBackgroundLight,
            infoPanelBackground: AppColors.formDesignInfoPanelBackgroundLight,
            panelBorder: AppColors.formDesignPanelBorderLight,
            panelShadow: AppColors.formDesignPanelShadowLight,
            headerAccentBackground:
                AppColors.formDesignHeaderAccentBackgroundLight,
            headerAccentForeground:
                AppColors.formDesignHeaderAccentForegroundLight,
            headerChipBackground: AppColors.formDesignHeaderChipBackgroundLight,
            headerChipText: AppColors.formDesignHeaderChipTextLight,
            statsCardBackground: AppColors.formDesignStatsCardBackgroundLight,
            statsCardBorder: AppColors.formDesignStatsCardBorderLight,
            sectionCardBackground:
                AppColors.formDesignSectionCardBackgroundLight,
            sectionCardBorder: AppColors.formDesignSectionCardBorderLight,
            sectionCardShadow: AppColors.formDesignSectionCardShadowLight,
            sectionIconBackground:
                AppColors.formDesignSectionIconBackgroundLight,
            sectionIconColor: AppColors.formDesignSectionIconColorLight,
            canvasCardBackground: AppColors.formDesignCanvasCardBackgroundLight,
            canvasCardBorder: AppColors.formDesignCanvasCardBorderLight,
            canvasCardShadow: AppColors.formDesignCanvasCardShadowLight,
            infoRowBackground: AppColors.formDesignInfoRowBackgroundLight,
            infoRowBorder: AppColors.formDesignInfoRowBorderLight,
            emptyStateBackground: AppColors.formDesignEmptyStateBackgroundLight,
            emptyStateBorder: AppColors.formDesignEmptyStateBorderLight,
            emptyStateIconBackground:
                AppColors.formDesignEmptyStateIconBackgroundLight,
            emptyStateIconColor: AppColors.formDesignEmptyStateIconColorLight,
            subtleText: AppColors.formDesignSubtleTextLight,
            faintText: AppColors.formDesignFaintTextLight,
          );

    // FormBrowsePage、FormBrowseBodyWidget、FormBrowseSectionListWidget、
    // FormBrowsePropertyPanelWidget、SectionPreviewWidget 使用
    final formBrowseThemeColors = isDark
        ? const FormBrowseThemeColors(
            pageGradient: [
              AppColors.formBrowseGradientStartDark,
              AppColors.formBrowseGradientMiddleDark,
              AppColors.formBrowseGradientEndDark,
            ],
            heroGlow: AppColors.formBrowseHeroGlowDark,
            shellBackground: AppColors.formBrowseShellBackgroundDark,
            shellBorder: AppColors.formBrowseShellBorderDark,
            shellShadow: AppColors.formBrowseShellShadowDark,
            panelBackground: AppColors.formBrowsePanelBackgroundDark,
            panelBorder: AppColors.formBrowsePanelBorderDark,
            panelShadow: AppColors.formBrowsePanelShadowDark,
            headerBackground: AppColors.formBrowseHeaderBackgroundDark,
            headerForeground: AppColors.formBrowseHeaderForegroundDark,
            chipBackground: AppColors.formBrowseChipBackgroundDark,
            chipForeground: AppColors.formBrowseChipForegroundDark,
            mutedText: AppColors.formBrowseMutedTextDark,
            subtleText: AppColors.formBrowseSubtleTextDark,
            listSelectedBackground: AppColors.formBrowseListSelectedDark,
            previewFrameBackground: AppColors.formBrowsePreviewFrameBackground,
            previewFrameBorder: AppColors.formBrowsePreviewFrameBorder,
            previewFrameShadow: AppColors.formBrowsePreviewFrameShadow,
            previewSurface: AppColors.formBrowsePreviewSurface,
            previewSubtleText: AppColors.formBrowsePreviewSubtle,
            previewSelectedBackground: AppColors.formBrowsePreviewSelected,
            previewSelectedBorder: AppColors.formBrowsePreviewSelectedBorder,
            propertyCardBackground:
                AppColors.formBrowsePropertyCardBackgroundDark,
            propertyCardSelectedBackground:
                AppColors.formBrowsePropertyCardSelectedDark,
          )
        : const FormBrowseThemeColors(
            pageGradient: [
              AppColors.formBrowseGradientStartLight,
              AppColors.formBrowseGradientMiddleLight,
              AppColors.formBrowseGradientEndLight,
            ],
            heroGlow: AppColors.formBrowseHeroGlowLight,
            shellBackground: AppColors.formBrowseShellBackgroundLight,
            shellBorder: AppColors.formBrowseShellBorderLight,
            shellShadow: AppColors.formBrowseShellShadowLight,
            panelBackground: AppColors.formBrowsePanelBackgroundLight,
            panelBorder: AppColors.formBrowsePanelBorderLight,
            panelShadow: AppColors.formBrowsePanelShadowLight,
            headerBackground: AppColors.formBrowseHeaderBackgroundLight,
            headerForeground: AppColors.formBrowseHeaderForegroundLight,
            chipBackground: AppColors.formBrowseChipBackgroundLight,
            chipForeground: AppColors.formBrowseChipForegroundLight,
            mutedText: AppColors.formBrowseMutedTextLight,
            subtleText: AppColors.formBrowseSubtleTextLight,
            listSelectedBackground: AppColors.formBrowseListSelectedLight,
            previewFrameBackground: AppColors.formBrowsePreviewFrameBackground,
            previewFrameBorder: AppColors.formBrowsePreviewFrameBorder,
            previewFrameShadow: AppColors.formBrowsePreviewFrameShadow,
            previewSurface: AppColors.formBrowsePreviewSurface,
            previewSubtleText: AppColors.formBrowsePreviewSubtle,
            previewSelectedBackground: AppColors.formBrowsePreviewSelected,
            previewSelectedBorder: AppColors.formBrowsePreviewSelectedBorder,
            propertyCardBackground:
                AppColors.formBrowsePropertyCardBackgroundLight,
            propertyCardSelectedBackground:
                AppColors.formBrowsePropertyCardSelectedLight,
          );

    final orgTreeDesignThemeColors = isDark
        ? const OrgTreeDesignThemeColors(
            pageGradient: [
              AppColors.orgTreeGradientStartDark,
              AppColors.orgTreeGradientMiddleDark,
              AppColors.orgTreeGradientEndDark,
            ],
            heroGlow: AppColors.orgTreeHeroGlowDark,
            shellBackground: AppColors.orgTreeShellBackgroundDark,
            shellBorder: AppColors.orgTreeShellBorderDark,
            shellShadow: AppColors.orgTreeShellShadowDark,
            panelBackground: AppColors.orgTreePanelBackgroundDark,
            panelBorder: AppColors.orgTreePanelBorderDark,
            panelShadow: AppColors.orgTreePanelShadowDark,
            headerBackground: AppColors.orgTreeHeaderBackgroundDark,
            headerForeground: AppColors.orgTreeHeaderForegroundDark,
            headerChipBackground: AppColors.orgTreeHeaderChipBackgroundDark,
            headerChipForeground: AppColors.orgTreeHeaderChipForegroundDark,
            mutedText: AppColors.orgTreeMutedTextDark,
            subtleText: AppColors.orgTreeSubtleTextDark,
            sourceSelectedBackground: AppColors.orgTreeSourceSelectedDark,
            sourcePlacedBackground: AppColors.orgTreeSourcePlacedDark,
            canvasOuterBackground: AppColors.orgTreeCanvasOuterBackground,
            canvasOuterBorder: AppColors.orgTreeCanvasOuterBorder,
            canvasSurface: AppColors.orgTreeCanvasSurface,
            canvasBorder: AppColors.orgTreeCanvasBorder,
            canvasShadow: AppColors.orgTreeCanvasShadow,
            canvasBadgeBackground: AppColors.orgTreeCanvasBadgeBackground,
            canvasBadgeBorder: AppColors.orgTreeCanvasBadgeBorder,
            gridMinor: AppColors.orgTreeGridMinor,
            gridMajor: AppColors.orgTreeGridMajor,
            connection: AppColors.orgTreeConnection,
            nodeBackground: AppColors.orgTreeNodeBackground,
            nodeBorder: AppColors.orgTreeNodeBorder,
            nodeTitle: AppColors.orgTreeNodeTitle,
            nodeSubtitle: AppColors.orgTreeNodeSubtitle,
            nodeShadow: AppColors.orgTreeNodeShadow,
            nodeSelectedBackground: AppColors.orgTreeNodeSelectedBackground,
            nodeSelectedBorder: AppColors.orgTreeNodeSelectedBorder,
            nodeSelectedTitle: AppColors.orgTreeNodeSelectedTitle,
            nodeSelectedSubtitle: AppColors.orgTreeNodeSelectedSubtitle,
            nodeHighlightedBackground:
                AppColors.orgTreeNodeHighlightedBackground,
            nodeHighlightedBorder: AppColors.orgTreeNodeHighlightedBorder,
            nodeHighlightedTitle: AppColors.orgTreeNodeHighlightedTitle,
            nodeHighlightedSubtitle: AppColors.orgTreeNodeHighlightedSubtitle,
            nodeHighlightedShadow: AppColors.orgTreeNodeHighlightedShadow,
            zoomBackground: AppColors.orgTreeZoomBackground,
            zoomBorder: AppColors.orgTreeZoomBorder,
          )
        : const OrgTreeDesignThemeColors(
            pageGradient: [
              AppColors.orgTreeGradientStartLight,
              AppColors.orgTreeGradientMiddleLight,
              AppColors.orgTreeGradientEndLight,
            ],
            heroGlow: AppColors.orgTreeHeroGlowLight,
            shellBackground: AppColors.orgTreeShellBackgroundLight,
            shellBorder: AppColors.orgTreeShellBorderLight,
            shellShadow: AppColors.orgTreeShellShadowLight,
            panelBackground: AppColors.orgTreePanelBackgroundLight,
            panelBorder: AppColors.orgTreePanelBorderLight,
            panelShadow: AppColors.orgTreePanelShadowLight,
            headerBackground: AppColors.orgTreeHeaderBackgroundLight,
            headerForeground: AppColors.orgTreeHeaderForegroundLight,
            headerChipBackground: AppColors.orgTreeHeaderChipBackgroundLight,
            headerChipForeground: AppColors.orgTreeHeaderChipForegroundLight,
            mutedText: AppColors.orgTreeMutedTextLight,
            subtleText: AppColors.orgTreeSubtleTextLight,
            sourceSelectedBackground: AppColors.orgTreeSourceSelectedLight,
            sourcePlacedBackground: AppColors.orgTreeSourcePlacedLight,
            canvasOuterBackground: AppColors.orgTreeCanvasOuterBackground,
            canvasOuterBorder: AppColors.orgTreeCanvasOuterBorder,
            canvasSurface: AppColors.orgTreeCanvasSurface,
            canvasBorder: AppColors.orgTreeCanvasBorder,
            canvasShadow: AppColors.orgTreeCanvasShadow,
            canvasBadgeBackground: AppColors.orgTreeCanvasBadgeBackground,
            canvasBadgeBorder: AppColors.orgTreeCanvasBadgeBorder,
            gridMinor: AppColors.orgTreeGridMinor,
            gridMajor: AppColors.orgTreeGridMajor,
            connection: AppColors.orgTreeConnection,
            nodeBackground: AppColors.orgTreeNodeBackground,
            nodeBorder: AppColors.orgTreeNodeBorder,
            nodeTitle: AppColors.orgTreeNodeTitle,
            nodeSubtitle: AppColors.orgTreeNodeSubtitle,
            nodeShadow: AppColors.orgTreeNodeShadow,
            nodeSelectedBackground: AppColors.orgTreeNodeSelectedBackground,
            nodeSelectedBorder: AppColors.orgTreeNodeSelectedBorder,
            nodeSelectedTitle: AppColors.orgTreeNodeSelectedTitle,
            nodeSelectedSubtitle: AppColors.orgTreeNodeSelectedSubtitle,
            nodeHighlightedBackground:
                AppColors.orgTreeNodeHighlightedBackground,
            nodeHighlightedBorder: AppColors.orgTreeNodeHighlightedBorder,
            nodeHighlightedTitle: AppColors.orgTreeNodeHighlightedTitle,
            nodeHighlightedSubtitle: AppColors.orgTreeNodeHighlightedSubtitle,
            nodeHighlightedShadow: AppColors.orgTreeNodeHighlightedShadow,
            zoomBackground: AppColors.orgTreeZoomBackground,
            zoomBorder: AppColors.orgTreeZoomBorder,
          );

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: TextSize.h1,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: TextSize.h2,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: TextSize.title,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: TextSize.body,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: TextSize.caption,
          color: textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurfaceVariant : AppColors.secondary,
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [
        loginThemeColors,
        empInfoThemeColors,
        empManagerThemeColors,
        empAgentThemeColors,
        formBrowseThemeColors,
        orgTreeDesignThemeColors,
        formSectionDesignThemeColors,
        formDesignThemeColors,
      ],
    );
  }
}
