import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_unsaved_chip_widget.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 表單條件欄位頁的頂部 header bar。
///
/// 內含返回按鈕、表單名稱標題、未儲存提示 chip、預覽 / 儲存 action button。
/// 動作以 callback 回傳給 parent；`onPreview` / `onSave` 傳 null 等同停用。
class ConditionFieldHeaderWidget extends StatelessWidget {
  final String formName;
  final bool isDirty;
  final VoidCallback onBack;
  final VoidCallback? onPreview;
  final VoidCallback? onSave;

  const ConditionFieldHeaderWidget({
    super.key,
    required this.formName,
    required this.isDirty,
    required this.onBack,
    required this.onPreview,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormConditionFieldThemeColors>()!;
    final title = formName.isEmpty ? '表單條件欄位' : '表單條件欄位 — $formName';

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, color: colors.headerTitleText),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.headerTitleText,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isDirty) const ConditionFieldUnsavedChipWidget(),
          if (isDirty) const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onPreview,
            icon: Icon(Icons.visibility_outlined,
                size: 18, color: colors.previewButtonText),
            label: Text(
              '預覽',
              style: TextStyle(
                color: colors.previewButtonText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.previewButtonBorder),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text(
              '儲存',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colors.saveButtonBackground,
              foregroundColor: colors.saveButtonText,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
