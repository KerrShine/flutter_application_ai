import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingSummaryPanelWidget extends StatelessWidget {
  final FormDataManagerState state;
  final VoidCallback onExportJson;

  const BindingSummaryPanelWidget({
    super.key,
    required this.state,
    required this.onExportJson,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final unmappedCount = state.fieldBindings
        .where((item) => item.issueStatus == FieldBindingIssueStatus.unmapped)
        .length;
    final versionWarningCount = state.fieldBindings
        .where(
          (item) => item.issueStatus == FieldBindingIssueStatus.versionMismatch,
        )
        .length;
    final requiredCount =
        state.fieldBindings.where((item) => item.required).length;

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('綁定摘要', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _SummaryCard(
              title: '驗證結果',
              rows: [
                _SummaryRowData('未綁定欄位', '$unmappedCount'),
                _SummaryRowData('版本警告', '$versionWarningCount'),
                _SummaryRowData('必填欄位', '$requiredCount'),
                _SummaryRowData('模板版本', 'v${state.latestTemplateVersion}'),
              ],
            ),
            const SizedBox(height: 12),
            const _SummaryCard(
              title: '版本策略',
              rows: [
                _SummaryRowData('required 輸出', '強制保留'),
                _SummaryRowData('空值策略', '略過 / 預設 0'),
                _SummaryRowData('版本規則', '數字版號'),
                _SummaryRowData('主鍵', 'DesignerItem.id'),
              ],
            ),
            const SizedBox(height: 12),
            Container(
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
                    child: FilledButton.icon(
                      onPressed:
                          state.selectedBinding == null ? null : onExportJson,
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('匯出Json'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('複製綁定'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.difference_outlined),
                      label: const Text('查看版本差異'),
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
          ...rows.map((row) => Padding(
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
              )),
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
