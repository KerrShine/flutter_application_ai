import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'binding_status_chip_widget.dart';

class BindingSidebarWidget extends StatelessWidget {
  final FormDataManagerState state;
  final VoidCallback onAddBinding;
  final ValueChanged<String> onSelectBinding;
  final ValueChanged<String> onEditBinding;
  final ValueChanged<String> onDeleteBinding;

  const BindingSidebarWidget({
    super.key,
    required this.state,
    required this.onAddBinding,
    required this.onSelectBinding,
    required this.onEditBinding,
    required this.onDeleteBinding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final Widget bindingsContent = state.bindings.isEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.emptyStateBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.emptyStateBorder),
              ),
              child: Text(
                '目前沒有任何綁定設定。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.faintText,
                ),
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: state.bindings.length,
            itemBuilder: (context, index) {
              final binding = state.bindings[index];
              final isSelected = binding.id == state.selectedBindingId;

              return InkWell(
                onTap: () => onSelectBinding(binding.id),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.headerChipBackground.withValues(alpha: 0.16)
                        : colors.sectionCardBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? colors.headerChipText
                          : colors.sectionCardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              binding.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          BindingStatusChipWidget(
                            isEnabled: binding.isEnabled,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        binding.id,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.faintText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        binding.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtleText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '綁定於 v${binding.templateVersion}',
                            style: theme.textTheme.labelMedium,
                          ),
                          const Spacer(),
                          if (binding.unmappedCount > 0)
                            Text(
                              '${binding.unmappedCount} 未完成',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isDark
                                    ? const Color(0xFFF7C97A)
                                    : const Color(0xFFB56A07),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              binding.isEnabled ? '目前啟用中' : '目前停用中',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.faintText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => onEditBinding(binding.id),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('編輯'),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            tooltip: '刪除',
                            onPressed: () => onDeleteBinding(binding.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: colors.sectionPanelBackground,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.headerAccentBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.headerChipBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.account_tree_outlined,
                    color: colors.headerChipText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.formName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.latestTemplateVersion > 0
                            ? '模板 ${state.templateId} / 最新 v${state.latestTemplateVersion}'
                            : '模板 ${state.templateId} / 尚未建立版本資料',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.statsCardBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.statsCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('綁定設定清單', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    '同一張表單可建立多份資料綁定，提供不同資料來源與匯出需求共用。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.faintText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onAddBinding,
                          icon: const Icon(Icons.add),
                          label: const Text('新增綁定'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('複製'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: bindingsContent),
        ],
      ),
    );
  }
}
