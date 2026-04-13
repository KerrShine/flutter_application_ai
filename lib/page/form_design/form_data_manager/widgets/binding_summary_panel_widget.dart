import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'binding_summary_card_widget.dart';

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
            BindingSummaryCardWidget(
              title: '驗證結果',
              rows: [
                BindingSummaryRowData('未綁定欄位', '$unmappedCount'),
                BindingSummaryRowData('版本警告', '$versionWarningCount'),
                BindingSummaryRowData('必填欄位', '$requiredCount'),
                BindingSummaryRowData(
                  '模板版本',
                  'v${state.latestTemplateVersion}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const BindingSummaryCardWidget(
              title: '版本策略',
              rows: [
                BindingSummaryRowData('required 輸出', '強制保留'),
                BindingSummaryRowData('空值策略', '略過 / 預設 0'),
                BindingSummaryRowData('版本規則', '數字版號'),
                BindingSummaryRowData('主鍵', 'DesignerItem.id'),
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
                      onPressed: state.selectedBinding == null ||
                              !state.selectedBinding!.isEnabled
                          ? null
                          : onExportJson,
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
