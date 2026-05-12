import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 表單條件欄位頁 header 上「尚未儲存」紅色提示 chip。
///
/// 在 `state.isDirty == true` 時由 [ConditionFieldHeaderWidget] 顯示。
class ConditionFieldUnsavedChipWidget extends StatelessWidget {
  const ConditionFieldUnsavedChipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<FormConditionFieldThemeColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.unsavedChipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '尚未儲存',
        style: TextStyle(
          color: colors.unsavedChipText,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
