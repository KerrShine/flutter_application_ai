import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 條件欄位列表底部的「+ 新增條件欄位」CTA 卡片。
///
/// 已有定義時顯示在列表結尾，引導使用者繼續加；
/// 點擊以 `onTap` callback 通知 parent 開 editor dialog。
class ConditionFieldAddPromptWidget extends StatelessWidget {
  final int availableItemCount;
  final VoidCallback onTap;

  const ConditionFieldAddPromptWidget({
    super.key,
    required this.availableItemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormConditionFieldThemeColors>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          color: colors.addPromptBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.addPromptBorder,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20, color: colors.addPromptText),
            const SizedBox(width: 8),
            Text(
              '新增條件欄位 · 從 $availableItemCount 個可用表單欄位中組合計算',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.addPromptText,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
