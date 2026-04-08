import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingExecutionSummaryWidget extends StatelessWidget {
  final FormDataBindingDraft draft;
  final Map<String, String> fieldErrors;
  final String Function(String sectionId, String itemId) fieldKeyBuilder;
  final VoidCallback onExportJson;
  final VoidCallback onSave;

  const BindingExecutionSummaryWidget({
    super.key,
    required this.draft,
    required this.fieldErrors,
    required this.fieldKeyBuilder,
    required this.onExportJson,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final requiredCount = draft.sections.fold<int>(
      0,
      (previousValue, section) =>
          previousValue +
          section.fields.where((field) => field.required).length,
    );
    final customStrategyCount = draft.sections.fold<int>(
      0,
      (previousValue, section) =>
          previousValue +
          section.fields
              .where(
                  (field) => field.nullStrategy == BindingNullStrategy.custom)
              .length,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.infoPanelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('執行摘要', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SummaryCard(
              title: '目前狀態',
              rows: [
                _SummaryRowData('區塊數', '${draft.sections.length}'),
                _SummaryRowData('欄位數', '${draft.totalFields}'),
                _SummaryRowData('required', '$requiredCount'),
                _SummaryRowData('自訂預設', '$customStrategyCount'),
                _SummaryRowData('待修正', '${fieldErrors.length}'),
              ],
            ),
            const SizedBox(height: 12),
            const _SummaryCard(
              title: '規則摘要',
              rows: [
                _SummaryRowData('輸出名稱', '對應欄位，可編輯'),
                _SummaryRowData('略過策略', 'string/date/number 系統預設'),
                _SummaryRowData('預設策略', '使用者輸入且須符合型別'),
                _SummaryRowData('儲存位置', 'local storage 暫存'),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.emptyStateBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.emptyStateBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('操作', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onExportJson,
                      icon: const Icon(Icons.data_object_outlined),
                      label: const Text('匯出 JSON'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('儲存暫存'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<_SummaryRowData> rows;

  const _SummaryCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.canvasPanelBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.headerAccentForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.headerChipBackground.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: colors.headerChipText.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtleText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      row.value,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.headerAccentForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRowData {
  final String label;
  final String value;

  const _SummaryRowData(this.label, this.value);
}
