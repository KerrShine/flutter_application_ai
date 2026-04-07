import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/theme/app_colors.dart';

class DynamicFormFieldTheme {
  static const double labelSpacing = 10;
  static const double fieldRadius = 14;
  static const EdgeInsets fieldContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  static Widget buildFieldShell({
    required BuildContext context,
    required DesignerItem item,
    required Widget child,
    String? label,
  }) {
    final colors = _resolve(context);
    final labelText = (label ?? item.text).trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: labelSpacing),
            child: RichText(
              text: TextSpan(
                text: labelText,
                style: TextStyle(
                  fontSize: item.fontSize,
                  fontWeight: FontWeight.w600,
                  color: colors.label,
                ),
                children: item.required
                    ? [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: colors.required),
                        ),
                      ]
                    : const [],
              ),
            ),
          ),
        child,
      ],
    );
  }

  static InputDecoration decoration({
    required BuildContext context,
    required DesignerItem item,
    String? hintText,
    Widget? suffixIcon,
    bool isMultiline = false,
  }) {
    final colors = _resolve(context);
    final border = _border(colors.border);
    final focusedBorder = _border(colors.focusedBorder, width: 1.3);

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: item.fontSize,
        color: colors.hint,
      ),
      filled: true,
      fillColor: colors.fill,
      isDense: false,
      alignLabelWithHint: isMultiline,
      contentPadding: fieldContentPadding,
      counterText: '',
      suffixIcon: suffixIcon,
      suffixIconColor: colors.icon,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      disabledBorder: border,
      errorBorder: border,
      focusedErrorBorder: focusedBorder,
    );
  }

  static TextStyle inputTextStyle(BuildContext context, DesignerItem item) {
    final colors = _resolve(context);
    return TextStyle(
      fontSize: item.fontSize,
      color: colors.text,
    );
  }

  static TextStyle metaTextStyle(BuildContext context, DesignerItem item) {
    final colors = _resolve(context);
    return TextStyle(
      fontSize: item.fontSize - 2,
      color: colors.hint,
    );
  }

  static ButtonStyle uploadButtonStyle(
      BuildContext context, DesignerItem item) {
    final colors = _resolve(context);
    return OutlinedButton.styleFrom(
      foregroundColor: colors.text,
      backgroundColor: colors.fill,
      side: BorderSide(color: colors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
      ),
      padding: fieldContentPadding,
      textStyle: TextStyle(fontSize: item.fontSize),
      alignment: Alignment.centerLeft,
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static _DynamicFieldColors _resolve(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return const _DynamicFieldColors(
        label: AppColors.dynamicFormFieldLabelDark,
        required: AppColors.dynamicFormFieldRequiredDark,
        fill: AppColors.dynamicFormFieldFillDark,
        border: AppColors.dynamicFormFieldBorderDark,
        focusedBorder: AppColors.dynamicFormFieldFocusedBorderDark,
        text: AppColors.dynamicFormFieldTextDark,
        hint: AppColors.dynamicFormFieldHintDark,
        icon: AppColors.dynamicFormFieldIconDark,
      );
    }

    return const _DynamicFieldColors(
      label: AppColors.dynamicFormFieldLabelLight,
      required: AppColors.dynamicFormFieldRequiredLight,
      fill: AppColors.dynamicFormFieldFillLight,
      border: AppColors.dynamicFormFieldBorderLight,
      focusedBorder: AppColors.dynamicFormFieldFocusedBorderLight,
      text: AppColors.dynamicFormFieldTextLight,
      hint: AppColors.dynamicFormFieldHintLight,
      icon: AppColors.dynamicFormFieldIconLight,
    );
  }
}

class _DynamicFieldColors {
  final Color label;
  final Color required;
  final Color fill;
  final Color border;
  final Color focusedBorder;
  final Color text;
  final Color hint;
  final Color icon;

  const _DynamicFieldColors({
    required this.label,
    required this.required,
    required this.fill,
    required this.border,
    required this.focusedBorder,
    required this.text,
    required this.hint,
    required this.icon,
  });
}
