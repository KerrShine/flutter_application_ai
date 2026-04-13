import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'binding_empty_content_widget.dart';
import 'binding_header_row_widget.dart';
import 'binding_info_badge_widget.dart';
import 'binding_mapping_row_widget.dart';

class BindingMappingTableWidget extends StatelessWidget {
  final FormDataManagerState state;
  final VoidCallback onPreviewApiExport;

  const BindingMappingTableWidget({
    super.key,
    required this.state,
    required this.onPreviewApiExport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final binding = state.selectedBinding;
    final grouped = <String, List<FieldBindingItem>>{};

    for (final item in state.fieldBindings) {
      if (item.sectionName.isEmpty) {
        continue;
      }
      grouped
          .putIfAbsent(item.sectionName, () => <FieldBindingItem>[])
          .add(item);
    }

    final Widget tableContent = grouped.isEmpty
        ? BindingEmptyContentWidget(formName: state.formName)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: grouped.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            colors.canvasCardBackground.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.panelBorder),
                      ),
                      child: Column(
                        children: [
                          const BindingHeaderRowWidget(),
                          ...entry.value.map(
                            (item) => BindingMappingRowWidget(item: item),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );

    return Container(
      decoration: BoxDecoration(
        color: colors.canvasPanelBackground,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.headerAccentBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            binding?.name ?? '尚未選擇綁定',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.headerAccentForeground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            binding == null
                                ? '請從左側選擇一份綁定設定'
                                : '${binding.description} / 模板 ${state.templateId}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.subtleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: binding == null || !binding.isEnabled
                          ? null
                          : onPreviewApiExport,
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('預覽API匯出'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    BindingInfoBadgeWidget(
                      label: '模板版本',
                      value: state.latestTemplateVersion > 0
                          ? 'v${state.latestTemplateVersion}'
                          : '-',
                    ),
                    BindingInfoBadgeWidget(
                      label: '綁定版本',
                      value:
                          binding == null ? '-' : 'v${binding.templateVersion}',
                    ),
                    BindingInfoBadgeWidget(
                      label: '啟用狀態',
                      value: binding == null
                          ? '-'
                          : (binding.isEnabled ? '啟用' : '停用'),
                    ),
                    BindingInfoBadgeWidget(
                      label: '相容狀態',
                      value: _resolveCompatibility(binding?.healthStatus),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: tableContent,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveCompatibility(BindingHealthStatus? status) {
    switch (status) {
      case BindingHealthStatus.outdated:
        return '版本落後';
      case BindingHealthStatus.warning:
        return '需檢查';
      case BindingHealthStatus.healthy:
        return '版本相容';
      case null:
        return '-';
    }
  }
}
