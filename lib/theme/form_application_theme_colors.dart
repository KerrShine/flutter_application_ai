import 'package:flutter/material.dart';

class FormApplicationThemeColors
    extends ThemeExtension<FormApplicationThemeColors> {
  final Color pageBackground;
  final Color errorColor;
  final Color subtitleText;
  final Color searchFill;
  final Color emptyText;
  final Color formIcon;
  final Color hintText;
  // 五種簽核狀態圖示色
  final Color submittedIcon; // approved
  final Color pendingIcon; // pending
  final Color inReviewIcon;
  final Color withdrawnIcon;
  // 列表卡片
  final Color cardBackground;
  final Color cardBorder;
  final Color listTitleText;
  final Color listSubtitleText;
  final Color chipBackground;

  const FormApplicationThemeColors({
    required this.pageBackground,
    required this.errorColor,
    required this.subtitleText,
    required this.searchFill,
    required this.emptyText,
    required this.formIcon,
    required this.hintText,
    required this.submittedIcon,
    required this.pendingIcon,
    required this.inReviewIcon,
    required this.withdrawnIcon,
    required this.cardBackground,
    required this.cardBorder,
    required this.listTitleText,
    required this.listSubtitleText,
    required this.chipBackground,
  });

  @override
  FormApplicationThemeColors copyWith({
    Color? pageBackground,
    Color? errorColor,
    Color? subtitleText,
    Color? searchFill,
    Color? emptyText,
    Color? formIcon,
    Color? hintText,
    Color? submittedIcon,
    Color? pendingIcon,
    Color? inReviewIcon,
    Color? withdrawnIcon,
    Color? cardBackground,
    Color? cardBorder,
    Color? listTitleText,
    Color? listSubtitleText,
    Color? chipBackground,
  }) {
    return FormApplicationThemeColors(
      pageBackground: pageBackground ?? this.pageBackground,
      errorColor: errorColor ?? this.errorColor,
      subtitleText: subtitleText ?? this.subtitleText,
      searchFill: searchFill ?? this.searchFill,
      emptyText: emptyText ?? this.emptyText,
      formIcon: formIcon ?? this.formIcon,
      hintText: hintText ?? this.hintText,
      submittedIcon: submittedIcon ?? this.submittedIcon,
      pendingIcon: pendingIcon ?? this.pendingIcon,
      inReviewIcon: inReviewIcon ?? this.inReviewIcon,
      withdrawnIcon: withdrawnIcon ?? this.withdrawnIcon,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      listTitleText: listTitleText ?? this.listTitleText,
      listSubtitleText: listSubtitleText ?? this.listSubtitleText,
      chipBackground: chipBackground ?? this.chipBackground,
    );
  }

  @override
  FormApplicationThemeColors lerp(
    covariant ThemeExtension<FormApplicationThemeColors>? other,
    double t,
  ) {
    if (other is! FormApplicationThemeColors) {
      return this;
    }

    return FormApplicationThemeColors(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      subtitleText: Color.lerp(subtitleText, other.subtitleText, t)!,
      searchFill: Color.lerp(searchFill, other.searchFill, t)!,
      emptyText: Color.lerp(emptyText, other.emptyText, t)!,
      formIcon: Color.lerp(formIcon, other.formIcon, t)!,
      hintText: Color.lerp(hintText, other.hintText, t)!,
      submittedIcon: Color.lerp(submittedIcon, other.submittedIcon, t)!,
      pendingIcon: Color.lerp(pendingIcon, other.pendingIcon, t)!,
      inReviewIcon: Color.lerp(inReviewIcon, other.inReviewIcon, t)!,
      withdrawnIcon: Color.lerp(withdrawnIcon, other.withdrawnIcon, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      listTitleText: Color.lerp(listTitleText, other.listTitleText, t)!,
      listSubtitleText:
          Color.lerp(listSubtitleText, other.listSubtitleText, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
    );
  }
}
