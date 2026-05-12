import 'package:flutter/material.dart';

/// FormConditionFieldPage、ConditionFieldDefinitionCard、ConditionFieldEditorDialog 使用。
///
/// 為何獨立成 ThemeExtension：頁面有多種特殊視覺元素（fieldKey monospace badge、
/// 綠色 type pill、淺藍 arg chip、amber 公式箭頭、dashed 新增 CTA），
/// 不抽出來會散落 magic colors 在 widgets 內。
class FormConditionFieldThemeColors
    extends ThemeExtension<FormConditionFieldThemeColors> {
  // Page shell
  final List<Color> pageGradient;
  final Color heroGlow;
  final Color shellBackground;
  final Color shellBorder;
  final Color shellShadow;

  // Header / actions
  final Color headerTitleText;
  final Color unsavedChipBackground;
  final Color unsavedChipText;
  final Color previewButtonBorder;
  final Color previewButtonText;
  final Color saveButtonBackground;
  final Color saveButtonText;

  // Stats card
  final Color statsCardBackground;
  final Color statsCardBorder;
  final Color statsCardShadow;
  final Color statsIconBackground;
  final Color statsIconColor;
  final Color statsTitleText;
  final Color statsDescriptionText;
  final Color statsCounterValue;
  final Color statsCounterLabel;

  // Section
  final Color sectionTitleText;
  final Color addButtonBorder;
  final Color addButtonText;

  // Definition card
  final Color definitionCardBackground;
  final Color definitionCardBorder;
  final Color definitionCardShadow;
  final Color fieldKeyBadgeBackground;
  final Color fieldKeyBadgeText;
  final Color typePillBackground;
  final Color typePillText;
  final Color labelText;
  final Color formulaIconColor;
  final Color formulaText;
  final Color argChipBackground;
  final Color argChipBorder;
  final Color argChipText;
  final Color iconButtonBorder;
  final Color editIconColor;
  final Color removeIconColor;

  // Add prompt (dashed CTA)
  final Color addPromptBackground;
  final Color addPromptBorder;
  final Color addPromptText;

  // Common
  final Color subtleText;
  final Color faintText;
  final Color emptyStateBackground;
  final Color emptyStateBorder;
  final Color emptyStateIconColor;

  const FormConditionFieldThemeColors({
    required this.pageGradient,
    required this.heroGlow,
    required this.shellBackground,
    required this.shellBorder,
    required this.shellShadow,
    required this.headerTitleText,
    required this.unsavedChipBackground,
    required this.unsavedChipText,
    required this.previewButtonBorder,
    required this.previewButtonText,
    required this.saveButtonBackground,
    required this.saveButtonText,
    required this.statsCardBackground,
    required this.statsCardBorder,
    required this.statsCardShadow,
    required this.statsIconBackground,
    required this.statsIconColor,
    required this.statsTitleText,
    required this.statsDescriptionText,
    required this.statsCounterValue,
    required this.statsCounterLabel,
    required this.sectionTitleText,
    required this.addButtonBorder,
    required this.addButtonText,
    required this.definitionCardBackground,
    required this.definitionCardBorder,
    required this.definitionCardShadow,
    required this.fieldKeyBadgeBackground,
    required this.fieldKeyBadgeText,
    required this.typePillBackground,
    required this.typePillText,
    required this.labelText,
    required this.formulaIconColor,
    required this.formulaText,
    required this.argChipBackground,
    required this.argChipBorder,
    required this.argChipText,
    required this.iconButtonBorder,
    required this.editIconColor,
    required this.removeIconColor,
    required this.addPromptBackground,
    required this.addPromptBorder,
    required this.addPromptText,
    required this.subtleText,
    required this.faintText,
    required this.emptyStateBackground,
    required this.emptyStateBorder,
    required this.emptyStateIconColor,
  });

  @override
  FormConditionFieldThemeColors copyWith({
    List<Color>? pageGradient,
    Color? heroGlow,
    Color? shellBackground,
    Color? shellBorder,
    Color? shellShadow,
    Color? headerTitleText,
    Color? unsavedChipBackground,
    Color? unsavedChipText,
    Color? previewButtonBorder,
    Color? previewButtonText,
    Color? saveButtonBackground,
    Color? saveButtonText,
    Color? statsCardBackground,
    Color? statsCardBorder,
    Color? statsCardShadow,
    Color? statsIconBackground,
    Color? statsIconColor,
    Color? statsTitleText,
    Color? statsDescriptionText,
    Color? statsCounterValue,
    Color? statsCounterLabel,
    Color? sectionTitleText,
    Color? addButtonBorder,
    Color? addButtonText,
    Color? definitionCardBackground,
    Color? definitionCardBorder,
    Color? definitionCardShadow,
    Color? fieldKeyBadgeBackground,
    Color? fieldKeyBadgeText,
    Color? typePillBackground,
    Color? typePillText,
    Color? labelText,
    Color? formulaIconColor,
    Color? formulaText,
    Color? argChipBackground,
    Color? argChipBorder,
    Color? argChipText,
    Color? iconButtonBorder,
    Color? editIconColor,
    Color? removeIconColor,
    Color? addPromptBackground,
    Color? addPromptBorder,
    Color? addPromptText,
    Color? subtleText,
    Color? faintText,
    Color? emptyStateBackground,
    Color? emptyStateBorder,
    Color? emptyStateIconColor,
  }) {
    return FormConditionFieldThemeColors(
      pageGradient: pageGradient ?? this.pageGradient,
      heroGlow: heroGlow ?? this.heroGlow,
      shellBackground: shellBackground ?? this.shellBackground,
      shellBorder: shellBorder ?? this.shellBorder,
      shellShadow: shellShadow ?? this.shellShadow,
      headerTitleText: headerTitleText ?? this.headerTitleText,
      unsavedChipBackground:
          unsavedChipBackground ?? this.unsavedChipBackground,
      unsavedChipText: unsavedChipText ?? this.unsavedChipText,
      previewButtonBorder: previewButtonBorder ?? this.previewButtonBorder,
      previewButtonText: previewButtonText ?? this.previewButtonText,
      saveButtonBackground: saveButtonBackground ?? this.saveButtonBackground,
      saveButtonText: saveButtonText ?? this.saveButtonText,
      statsCardBackground: statsCardBackground ?? this.statsCardBackground,
      statsCardBorder: statsCardBorder ?? this.statsCardBorder,
      statsCardShadow: statsCardShadow ?? this.statsCardShadow,
      statsIconBackground: statsIconBackground ?? this.statsIconBackground,
      statsIconColor: statsIconColor ?? this.statsIconColor,
      statsTitleText: statsTitleText ?? this.statsTitleText,
      statsDescriptionText:
          statsDescriptionText ?? this.statsDescriptionText,
      statsCounterValue: statsCounterValue ?? this.statsCounterValue,
      statsCounterLabel: statsCounterLabel ?? this.statsCounterLabel,
      sectionTitleText: sectionTitleText ?? this.sectionTitleText,
      addButtonBorder: addButtonBorder ?? this.addButtonBorder,
      addButtonText: addButtonText ?? this.addButtonText,
      definitionCardBackground:
          definitionCardBackground ?? this.definitionCardBackground,
      definitionCardBorder:
          definitionCardBorder ?? this.definitionCardBorder,
      definitionCardShadow:
          definitionCardShadow ?? this.definitionCardShadow,
      fieldKeyBadgeBackground:
          fieldKeyBadgeBackground ?? this.fieldKeyBadgeBackground,
      fieldKeyBadgeText: fieldKeyBadgeText ?? this.fieldKeyBadgeText,
      typePillBackground: typePillBackground ?? this.typePillBackground,
      typePillText: typePillText ?? this.typePillText,
      labelText: labelText ?? this.labelText,
      formulaIconColor: formulaIconColor ?? this.formulaIconColor,
      formulaText: formulaText ?? this.formulaText,
      argChipBackground: argChipBackground ?? this.argChipBackground,
      argChipBorder: argChipBorder ?? this.argChipBorder,
      argChipText: argChipText ?? this.argChipText,
      iconButtonBorder: iconButtonBorder ?? this.iconButtonBorder,
      editIconColor: editIconColor ?? this.editIconColor,
      removeIconColor: removeIconColor ?? this.removeIconColor,
      addPromptBackground: addPromptBackground ?? this.addPromptBackground,
      addPromptBorder: addPromptBorder ?? this.addPromptBorder,
      addPromptText: addPromptText ?? this.addPromptText,
      subtleText: subtleText ?? this.subtleText,
      faintText: faintText ?? this.faintText,
      emptyStateBackground: emptyStateBackground ?? this.emptyStateBackground,
      emptyStateBorder: emptyStateBorder ?? this.emptyStateBorder,
      emptyStateIconColor: emptyStateIconColor ?? this.emptyStateIconColor,
    );
  }

  @override
  FormConditionFieldThemeColors lerp(
    covariant ThemeExtension<FormConditionFieldThemeColors>? other,
    double t,
  ) {
    if (other is! FormConditionFieldThemeColors) return this;
    return FormConditionFieldThemeColors(
      pageGradient: List<Color>.generate(
        pageGradient.length,
        (i) => Color.lerp(pageGradient[i], other.pageGradient[i], t)!,
      ),
      heroGlow: Color.lerp(heroGlow, other.heroGlow, t)!,
      shellBackground:
          Color.lerp(shellBackground, other.shellBackground, t)!,
      shellBorder: Color.lerp(shellBorder, other.shellBorder, t)!,
      shellShadow: Color.lerp(shellShadow, other.shellShadow, t)!,
      headerTitleText:
          Color.lerp(headerTitleText, other.headerTitleText, t)!,
      unsavedChipBackground: Color.lerp(
          unsavedChipBackground, other.unsavedChipBackground, t)!,
      unsavedChipText:
          Color.lerp(unsavedChipText, other.unsavedChipText, t)!,
      previewButtonBorder:
          Color.lerp(previewButtonBorder, other.previewButtonBorder, t)!,
      previewButtonText:
          Color.lerp(previewButtonText, other.previewButtonText, t)!,
      saveButtonBackground:
          Color.lerp(saveButtonBackground, other.saveButtonBackground, t)!,
      saveButtonText: Color.lerp(saveButtonText, other.saveButtonText, t)!,
      statsCardBackground:
          Color.lerp(statsCardBackground, other.statsCardBackground, t)!,
      statsCardBorder:
          Color.lerp(statsCardBorder, other.statsCardBorder, t)!,
      statsCardShadow:
          Color.lerp(statsCardShadow, other.statsCardShadow, t)!,
      statsIconBackground:
          Color.lerp(statsIconBackground, other.statsIconBackground, t)!,
      statsIconColor: Color.lerp(statsIconColor, other.statsIconColor, t)!,
      statsTitleText: Color.lerp(statsTitleText, other.statsTitleText, t)!,
      statsDescriptionText: Color.lerp(
          statsDescriptionText, other.statsDescriptionText, t)!,
      statsCounterValue:
          Color.lerp(statsCounterValue, other.statsCounterValue, t)!,
      statsCounterLabel:
          Color.lerp(statsCounterLabel, other.statsCounterLabel, t)!,
      sectionTitleText:
          Color.lerp(sectionTitleText, other.sectionTitleText, t)!,
      addButtonBorder:
          Color.lerp(addButtonBorder, other.addButtonBorder, t)!,
      addButtonText: Color.lerp(addButtonText, other.addButtonText, t)!,
      definitionCardBackground: Color.lerp(
          definitionCardBackground, other.definitionCardBackground, t)!,
      definitionCardBorder: Color.lerp(
          definitionCardBorder, other.definitionCardBorder, t)!,
      definitionCardShadow: Color.lerp(
          definitionCardShadow, other.definitionCardShadow, t)!,
      fieldKeyBadgeBackground: Color.lerp(
          fieldKeyBadgeBackground, other.fieldKeyBadgeBackground, t)!,
      fieldKeyBadgeText:
          Color.lerp(fieldKeyBadgeText, other.fieldKeyBadgeText, t)!,
      typePillBackground:
          Color.lerp(typePillBackground, other.typePillBackground, t)!,
      typePillText: Color.lerp(typePillText, other.typePillText, t)!,
      labelText: Color.lerp(labelText, other.labelText, t)!,
      formulaIconColor:
          Color.lerp(formulaIconColor, other.formulaIconColor, t)!,
      formulaText: Color.lerp(formulaText, other.formulaText, t)!,
      argChipBackground:
          Color.lerp(argChipBackground, other.argChipBackground, t)!,
      argChipBorder: Color.lerp(argChipBorder, other.argChipBorder, t)!,
      argChipText: Color.lerp(argChipText, other.argChipText, t)!,
      iconButtonBorder:
          Color.lerp(iconButtonBorder, other.iconButtonBorder, t)!,
      editIconColor: Color.lerp(editIconColor, other.editIconColor, t)!,
      removeIconColor:
          Color.lerp(removeIconColor, other.removeIconColor, t)!,
      addPromptBackground:
          Color.lerp(addPromptBackground, other.addPromptBackground, t)!,
      addPromptBorder:
          Color.lerp(addPromptBorder, other.addPromptBorder, t)!,
      addPromptText: Color.lerp(addPromptText, other.addPromptText, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      faintText: Color.lerp(faintText, other.faintText, t)!,
      emptyStateBackground:
          Color.lerp(emptyStateBackground, other.emptyStateBackground, t)!,
      emptyStateBorder:
          Color.lerp(emptyStateBorder, other.emptyStateBorder, t)!,
      emptyStateIconColor:
          Color.lerp(emptyStateIconColor, other.emptyStateIconColor, t)!,
    );
  }
}
