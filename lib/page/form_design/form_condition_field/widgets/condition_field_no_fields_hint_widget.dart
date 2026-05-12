import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 表單條件欄位頁「此表單尚未設計任何可作為條件來源的欄位」全頁 hint。
///
/// availableItems 與 draft.definitions 都為空時顯示；
/// 提示使用者先到表單設計加入欄位再回來設定條件。
class ConditionFieldNoFieldsHintWidget extends StatelessWidget {
  const ConditionFieldNoFieldsHintWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormConditionFieldThemeColors>()!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.emptyStateBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.emptyStateBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline,
                  size: 36, color: colors.emptyStateIconColor),
              const SizedBox(height: 10),
              Text(
                '此表單尚未設計任何可作為條件來源的欄位',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.labelText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '請先到表單設計加入欄位後再回此處設定條件欄位。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.subtleText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
