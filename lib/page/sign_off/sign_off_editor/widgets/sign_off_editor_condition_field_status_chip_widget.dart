import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/sign_off_condition_field_status.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_summary.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

Color signOffConditionFieldStatusColor(
  ThemeData theme,
  FormDesignThemeColors colors,
  SignOffConditionFieldStatus status,
) {
  switch (status) {
    case SignOffConditionFieldStatus.ready:
      return colors.actionSuccess;
    case SignOffConditionFieldStatus.none:
      return theme.colorScheme.error;
  }
}

/// 簽核流程編輯器頂部的「條件欄位狀態」chip — 顯示對應表單的 form_condition_field draft 狀態與定義數，點擊跳到該表單的條件欄位編輯器。
class SignOffEditorConditionFieldStatusChipWidget extends StatelessWidget {
  final SignOffConditionFieldSummary summary;
  final VoidCallback onPressed;

  const SignOffEditorConditionFieldStatusChipWidget({
    super.key,
    required this.summary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final color =
        signOffConditionFieldStatusColor(theme, colors, summary.status);
    final label = summary.status.fullLabel(summary.definitionCount);

    return Tooltip(
      message: '點擊前往表單條件欄位編輯器',
      child: ActionChip(
        avatar: Icon(summary.status.icon, color: color, size: 16),
        label: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 1,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
      ),
    );
  }
}
