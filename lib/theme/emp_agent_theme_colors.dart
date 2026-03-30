import 'package:flutter/material.dart';

class EmpAgentThemeColors extends ThemeExtension<EmpAgentThemeColors> {
  final Color pageBackground;
  final Color panelBackground;
  final Color panelBorder;
  final Color panelShadow;
  final Color stepTitle;
  final Color divider;
  final Color dropdownBackground;
  final Color dropdownBorder;
  final Color dropdownLabel;
  final Color dropdownFocus;
  final Color inputText;
  final Color mutedText;
  final Color subtleText;
  final Color candidateBackground;
  final Color candidateSelectedBackground;
  final Color candidateBorder;
  final Color candidateSelectedBorder;
  final Color candidateAvatarBackground;
  final Color candidateSelectedAvatarBackground;
  final Color candidateSelectedName;
  final Color candidateSelectedRole;
  final Color summaryBackground;
  final Color summaryBorder;
  final Color summaryAvatarBackground;
  final Color summaryAvatarText;
  final Color statusActiveBackground;
  final Color statusInactiveBackground;
  final Color statusActiveText;
  final Color statusInactiveText;
  final Color primaryAction;
  final Color arrowAccent;
  final Color deleteText;
  final Color deleteBorder;
  final Color filterIcon;
  final Color footerGhostBorder;
  final Color footerPrimaryBackground;
  final Color infoBlockTitle;
  final Color infoBlockText;

  const EmpAgentThemeColors({
    required this.pageBackground,
    required this.panelBackground,
    required this.panelBorder,
    required this.panelShadow,
    required this.stepTitle,
    required this.divider,
    required this.dropdownBackground,
    required this.dropdownBorder,
    required this.dropdownLabel,
    required this.dropdownFocus,
    required this.inputText,
    required this.mutedText,
    required this.subtleText,
    required this.candidateBackground,
    required this.candidateSelectedBackground,
    required this.candidateBorder,
    required this.candidateSelectedBorder,
    required this.candidateAvatarBackground,
    required this.candidateSelectedAvatarBackground,
    required this.candidateSelectedName,
    required this.candidateSelectedRole,
    required this.summaryBackground,
    required this.summaryBorder,
    required this.summaryAvatarBackground,
    required this.summaryAvatarText,
    required this.statusActiveBackground,
    required this.statusInactiveBackground,
    required this.statusActiveText,
    required this.statusInactiveText,
    required this.primaryAction,
    required this.arrowAccent,
    required this.deleteText,
    required this.deleteBorder,
    required this.filterIcon,
    required this.footerGhostBorder,
    required this.footerPrimaryBackground,
    required this.infoBlockTitle,
    required this.infoBlockText,
  });

  @override
  EmpAgentThemeColors copyWith({
    Color? pageBackground,
    Color? panelBackground,
    Color? panelBorder,
    Color? panelShadow,
    Color? stepTitle,
    Color? divider,
    Color? dropdownBackground,
    Color? dropdownBorder,
    Color? dropdownLabel,
    Color? dropdownFocus,
    Color? inputText,
    Color? mutedText,
    Color? subtleText,
    Color? candidateBackground,
    Color? candidateSelectedBackground,
    Color? candidateBorder,
    Color? candidateSelectedBorder,
    Color? candidateAvatarBackground,
    Color? candidateSelectedAvatarBackground,
    Color? candidateSelectedName,
    Color? candidateSelectedRole,
    Color? summaryBackground,
    Color? summaryBorder,
    Color? summaryAvatarBackground,
    Color? summaryAvatarText,
    Color? statusActiveBackground,
    Color? statusInactiveBackground,
    Color? statusActiveText,
    Color? statusInactiveText,
    Color? primaryAction,
    Color? arrowAccent,
    Color? deleteText,
    Color? deleteBorder,
    Color? filterIcon,
    Color? footerGhostBorder,
    Color? footerPrimaryBackground,
    Color? infoBlockTitle,
    Color? infoBlockText,
  }) {
    return EmpAgentThemeColors(
      pageBackground: pageBackground ?? this.pageBackground,
      panelBackground: panelBackground ?? this.panelBackground,
      panelBorder: panelBorder ?? this.panelBorder,
      panelShadow: panelShadow ?? this.panelShadow,
      stepTitle: stepTitle ?? this.stepTitle,
      divider: divider ?? this.divider,
      dropdownBackground: dropdownBackground ?? this.dropdownBackground,
      dropdownBorder: dropdownBorder ?? this.dropdownBorder,
      dropdownLabel: dropdownLabel ?? this.dropdownLabel,
      dropdownFocus: dropdownFocus ?? this.dropdownFocus,
      inputText: inputText ?? this.inputText,
      mutedText: mutedText ?? this.mutedText,
      subtleText: subtleText ?? this.subtleText,
      candidateBackground: candidateBackground ?? this.candidateBackground,
      candidateSelectedBackground:
          candidateSelectedBackground ?? this.candidateSelectedBackground,
      candidateBorder: candidateBorder ?? this.candidateBorder,
      candidateSelectedBorder:
          candidateSelectedBorder ?? this.candidateSelectedBorder,
      candidateAvatarBackground:
          candidateAvatarBackground ?? this.candidateAvatarBackground,
      candidateSelectedAvatarBackground: candidateSelectedAvatarBackground ??
          this.candidateSelectedAvatarBackground,
      candidateSelectedName:
          candidateSelectedName ?? this.candidateSelectedName,
      candidateSelectedRole:
          candidateSelectedRole ?? this.candidateSelectedRole,
      summaryBackground: summaryBackground ?? this.summaryBackground,
      summaryBorder: summaryBorder ?? this.summaryBorder,
      summaryAvatarBackground:
          summaryAvatarBackground ?? this.summaryAvatarBackground,
      summaryAvatarText: summaryAvatarText ?? this.summaryAvatarText,
      statusActiveBackground:
          statusActiveBackground ?? this.statusActiveBackground,
      statusInactiveBackground:
          statusInactiveBackground ?? this.statusInactiveBackground,
      statusActiveText: statusActiveText ?? this.statusActiveText,
      statusInactiveText: statusInactiveText ?? this.statusInactiveText,
      primaryAction: primaryAction ?? this.primaryAction,
      arrowAccent: arrowAccent ?? this.arrowAccent,
      deleteText: deleteText ?? this.deleteText,
      deleteBorder: deleteBorder ?? this.deleteBorder,
      filterIcon: filterIcon ?? this.filterIcon,
      footerGhostBorder: footerGhostBorder ?? this.footerGhostBorder,
      footerPrimaryBackground:
          footerPrimaryBackground ?? this.footerPrimaryBackground,
      infoBlockTitle: infoBlockTitle ?? this.infoBlockTitle,
      infoBlockText: infoBlockText ?? this.infoBlockText,
    );
  }

  @override
  EmpAgentThemeColors lerp(
    covariant ThemeExtension<EmpAgentThemeColors>? other,
    double t,
  ) {
    if (other is! EmpAgentThemeColors) {
      return this;
    }

    return EmpAgentThemeColors(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      panelBackground: Color.lerp(panelBackground, other.panelBackground, t)!,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t)!,
      panelShadow: Color.lerp(panelShadow, other.panelShadow, t)!,
      stepTitle: Color.lerp(stepTitle, other.stepTitle, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      dropdownBackground:
          Color.lerp(dropdownBackground, other.dropdownBackground, t)!,
      dropdownBorder: Color.lerp(dropdownBorder, other.dropdownBorder, t)!,
      dropdownLabel: Color.lerp(dropdownLabel, other.dropdownLabel, t)!,
      dropdownFocus: Color.lerp(dropdownFocus, other.dropdownFocus, t)!,
      inputText: Color.lerp(inputText, other.inputText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      candidateBackground:
          Color.lerp(candidateBackground, other.candidateBackground, t)!,
      candidateSelectedBackground: Color.lerp(
        candidateSelectedBackground,
        other.candidateSelectedBackground,
        t,
      )!,
      candidateBorder: Color.lerp(candidateBorder, other.candidateBorder, t)!,
      candidateSelectedBorder: Color.lerp(
        candidateSelectedBorder,
        other.candidateSelectedBorder,
        t,
      )!,
      candidateAvatarBackground: Color.lerp(
        candidateAvatarBackground,
        other.candidateAvatarBackground,
        t,
      )!,
      candidateSelectedAvatarBackground: Color.lerp(
        candidateSelectedAvatarBackground,
        other.candidateSelectedAvatarBackground,
        t,
      )!,
      candidateSelectedName: Color.lerp(
        candidateSelectedName,
        other.candidateSelectedName,
        t,
      )!,
      candidateSelectedRole: Color.lerp(
        candidateSelectedRole,
        other.candidateSelectedRole,
        t,
      )!,
      summaryBackground:
          Color.lerp(summaryBackground, other.summaryBackground, t)!,
      summaryBorder: Color.lerp(summaryBorder, other.summaryBorder, t)!,
      summaryAvatarBackground: Color.lerp(
        summaryAvatarBackground,
        other.summaryAvatarBackground,
        t,
      )!,
      summaryAvatarText:
          Color.lerp(summaryAvatarText, other.summaryAvatarText, t)!,
      statusActiveBackground: Color.lerp(
        statusActiveBackground,
        other.statusActiveBackground,
        t,
      )!,
      statusInactiveBackground: Color.lerp(
        statusInactiveBackground,
        other.statusInactiveBackground,
        t,
      )!,
      statusActiveText:
          Color.lerp(statusActiveText, other.statusActiveText, t)!,
      statusInactiveText:
          Color.lerp(statusInactiveText, other.statusInactiveText, t)!,
      primaryAction: Color.lerp(primaryAction, other.primaryAction, t)!,
      arrowAccent: Color.lerp(arrowAccent, other.arrowAccent, t)!,
      deleteText: Color.lerp(deleteText, other.deleteText, t)!,
      deleteBorder: Color.lerp(deleteBorder, other.deleteBorder, t)!,
      filterIcon: Color.lerp(filterIcon, other.filterIcon, t)!,
      footerGhostBorder:
          Color.lerp(footerGhostBorder, other.footerGhostBorder, t)!,
      footerPrimaryBackground: Color.lerp(
        footerPrimaryBackground,
        other.footerPrimaryBackground,
        t,
      )!,
      infoBlockTitle: Color.lerp(infoBlockTitle, other.infoBlockTitle, t)!,
      infoBlockText: Color.lerp(infoBlockText, other.infoBlockText, t)!,
    );
  }
}
