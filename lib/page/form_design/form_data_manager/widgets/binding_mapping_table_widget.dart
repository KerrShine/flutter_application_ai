import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

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
        ? _EmptyBindingContent(formName: state.formName)
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
                          const _HeaderRow(),
                          ...entry.value.map(_MappingRow.new),
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
                      onPressed: binding == null ? null : onPreviewApiExport,
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
                    _InfoBadge(
                      label: '模板版本',
                      value: state.latestTemplateVersion > 0
                          ? 'v${state.latestTemplateVersion}'
                          : '-',
                    ),
                    _InfoBadge(
                      label: '綁定版本',
                      value:
                          binding == null ? '-' : 'v${binding.templateVersion}',
                    ),
                    _InfoBadge(
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

class _EmptyBindingContent extends StatelessWidget {
  final String formName;

  const _EmptyBindingContent({required this.formName});

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

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.infoRowBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: const Row(
        children: [
          _HeaderCell(flex: 36, text: '欄位名稱'),
          _HeaderCell(flex: 12, text: '型別'),
          _HeaderCell(flex: 30, text: '輸出 key'),
          _HeaderCell(flex: 22, text: '空值策略'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final int flex;
  final String text;

  const _HeaderCell({required this.flex, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MappingRow extends StatelessWidget {
  final FieldBindingItem item;

  const _MappingRow(this.item);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final rowColor = switch (item.issueStatus) {
      FieldBindingIssueStatus.mapped => Colors.transparent,
      FieldBindingIssueStatus.unmapped =>
        colors.headerChipBackground.withValues(
          alpha: isDark ? 0.16 : 0.1,
        ),
      FieldBindingIssueStatus.versionMismatch =>
        theme.colorScheme.error.withValues(alpha: isDark ? 0.16 : 0.1),
    };
    final hintColor = switch (item.issueStatus) {
      FieldBindingIssueStatus.mapped => colors.faintText,
      FieldBindingIssueStatus.unmapped =>
        isDark ? const Color(0xFFF7C97A) : const Color(0xFFB56A07),
      FieldBindingIssueStatus.versionMismatch =>
        isDark ? const Color(0xFFFFB4AB) : theme.colorScheme.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          top: BorderSide(color: colors.panelBorder.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 36,
            child: Text(
              item.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: item.issueStatus == FieldBindingIssueStatus.mapped
                    ? null
                    : hintColor,
              ),
            ),
          ),
          Expanded(flex: 12, child: Text(item.fieldType)),
          Expanded(
            flex: 30,
            child: Text(
              item.outputKey.isEmpty ? '尚未設定...' : item.outputKey,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: item.outputKey.isEmpty ? hintColor : null,
                fontWeight:
                    item.outputKey.isEmpty ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(flex: 22, child: Text(item.nullStrategy)),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.headerChipBackground.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.headerChipText.withValues(alpha: 0.18),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.subtleText,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.headerAccentForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
