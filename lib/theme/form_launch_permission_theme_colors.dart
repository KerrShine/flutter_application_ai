import 'package:flutter/material.dart';

class FormLaunchPermissionThemeColors
    extends ThemeExtension<FormLaunchPermissionThemeColors> {
  final Color pageBackground;
  final Color errorColor;
  final Color emptyText;
  final Color activeIcon;
  final Color inactiveIcon;
  final Color deleteButton;
  final Color chipIcon;
  final Color chipText;

  const FormLaunchPermissionThemeColors({
    required this.pageBackground,
    required this.errorColor,
    required this.emptyText,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.deleteButton,
    required this.chipIcon,
    required this.chipText,
  });

  @override
  FormLaunchPermissionThemeColors copyWith({
    Color? pageBackground,
    Color? errorColor,
    Color? emptyText,
    Color? activeIcon,
    Color? inactiveIcon,
    Color? deleteButton,
    Color? chipIcon,
    Color? chipText,
  }) {
    return FormLaunchPermissionThemeColors(
      pageBackground: pageBackground ?? this.pageBackground,
      errorColor: errorColor ?? this.errorColor,
      emptyText: emptyText ?? this.emptyText,
      activeIcon: activeIcon ?? this.activeIcon,
      inactiveIcon: inactiveIcon ?? this.inactiveIcon,
      deleteButton: deleteButton ?? this.deleteButton,
      chipIcon: chipIcon ?? this.chipIcon,
      chipText: chipText ?? this.chipText,
    );
  }

  @override
  FormLaunchPermissionThemeColors lerp(
    covariant ThemeExtension<FormLaunchPermissionThemeColors>? other,
    double t,
  ) {
    if (other is! FormLaunchPermissionThemeColors) {
      return this;
    }

    return FormLaunchPermissionThemeColors(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      emptyText: Color.lerp(emptyText, other.emptyText, t)!,
      activeIcon: Color.lerp(activeIcon, other.activeIcon, t)!,
      inactiveIcon: Color.lerp(inactiveIcon, other.inactiveIcon, t)!,
      deleteButton: Color.lerp(deleteButton, other.deleteButton, t)!,
      chipIcon: Color.lerp(chipIcon, other.chipIcon, t)!,
      chipText: Color.lerp(chipText, other.chipText, t)!,
    );
  }
}
