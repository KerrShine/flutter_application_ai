import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingEmptyContentWidget extends StatelessWidget {
  final String formName;

  const BindingEmptyContentWidget({
    super.key,
    required this.formName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.emptyStateBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.emptyStateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('目前尚無綁定資料', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            formName.isEmpty
                ? '此表單尚未建立任何資料綁定設定。'
                : '「$formName」目前尚未建立任何資料綁定設定。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '可從左側新增綁定，完成暫存後回到此頁檢視欄位對應內容。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.faintText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
