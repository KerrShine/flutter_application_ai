import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 表單條件欄位頁中段「條件欄位定義」section title 與右側「+ 新增」按鈕。
///
/// `onAdd` 為 null 時按鈕停用（例如表單尚未設計任何欄位）。
class ConditionFieldSectionHeaderWidget extends StatelessWidget {
  final VoidCallback? onAdd;

  const ConditionFieldSectionHeaderWidget({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormConditionFieldThemeColors>()!;
    return Row(
      children: [
        Text(
          '條件欄位定義',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.sectionTitleText,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add, size: 18, color: colors.addButtonText),
          label: Text(
            '新增條件欄位',
            style: TextStyle(
              color: colors.addButtonText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.addButtonBorder),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
