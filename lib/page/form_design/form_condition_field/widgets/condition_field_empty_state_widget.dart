import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 表單條件欄位頁「尚未定義任何條件欄位」空狀態卡片。
///
/// draft.definitions 為空但 availableItems 仍有可選欄位時顯示，
/// 引導使用者點上方「+ 新增條件欄位」開始。
class ConditionFieldEmptyStateWidget extends StatelessWidget {
  const ConditionFieldEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormConditionFieldThemeColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colors.emptyStateBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.emptyStateBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.functions,
              size: 48, color: colors.emptyStateIconColor),
          const SizedBox(height: 14),
          Text(
            '尚未定義任何條件欄位',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.labelText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '點上方「+ 新增條件欄位」開始；'
            '可使用 Direct / DateDiff / Sum / Concat 4 種函式組合表單欄位。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.subtleText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
