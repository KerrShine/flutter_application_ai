import 'package:flutter/material.dart';

class FormApplicationCenterThemeColors
    extends ThemeExtension<FormApplicationCenterThemeColors> {
  final Color pageBackground;
  final Color errorColor;
  final Color subtitleText;
  final Color searchFill;
  final Color emptyText;
  final Color formIcon;
  final Color hintText;
  final Color submittedIcon;
  final Color pendingIcon;

  const FormApplicationCenterThemeColors({
    required this.pageBackground,
    required this.errorColor,
    required this.subtitleText,
    required this.searchFill,
    required this.emptyText,
    required this.formIcon,
    required this.hintText,
    required this.submittedIcon,
    required this.pendingIcon,
  });

  @override
  FormApplicationCenterThemeColors copyWith({
    Color? pageBackground,
    Color? errorColor,
    Color? subtitleText,
    Color? searchFill,
    Color? emptyText,
    Color? formIcon,
    Color? hintText,
    Color? submittedIcon,
    Color? pendingIcon,
  }) {
    return FormApplicationCenterThemeColors(
      pageBackground: pageBackground ?? this.pageBackground,
      errorColor: errorColor ?? this.errorColor,
      subtitleText: subtitleText ?? this.subtitleText,
      searchFill: searchFill ?? this.searchFill,
      emptyText: emptyText ?? this.emptyText,
      formIcon: formIcon ?? this.formIcon,
      hintText: hintText ?? this.hintText,
      submittedIcon: submittedIcon ?? this.submittedIcon,
      pendingIcon: pendingIcon ?? this.pendingIcon,
    );
  }

  @override
  FormApplicationCenterThemeColors lerp(
    covariant ThemeExtension<FormApplicationCenterThemeColors>? other,
    double t,
  ) {
    if (other is! FormApplicationCenterThemeColors) {
      return this;
    }

    return FormApplicationCenterThemeColors(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      subtitleText: Color.lerp(subtitleText, other.subtitleText, t)!,
      searchFill: Color.lerp(searchFill, other.searchFill, t)!,
      emptyText: Color.lerp(emptyText, other.emptyText, t)!,
      formIcon: Color.lerp(formIcon, other.formIcon, t)!,
      hintText: Color.lerp(hintText, other.hintText, t)!,
      submittedIcon: Color.lerp(submittedIcon, other.submittedIcon, t)!,
      pendingIcon: Color.lerp(pendingIcon, other.pendingIcon, t)!,
    );
  }
}
