import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingExecutionHeaderWidget extends StatelessWidget {
  final FormDataBindingDraft draft;
  final int errorCount;
  final bool isSaving;
  final VoidCallback onSave;
  final ValueChanged<bool> onBindingEnabledChanged;

  const BindingExecutionHeaderWidget({
    super.key,
    required this.draft,
    required this.errorCount,
    required this.isSaving,
    required this.onSave,
    required this.onBindingEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.headerAccentBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
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
                      draft.formName.isEmpty ? '資料綁定執行' : draft.formName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.headerAccentForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      ChoiceChip(
                        label: const Text('啟用'),
                        selected: draft.isEnabled,
                        onSelected: (_) => onBindingEnabledChanged(true),
                      ),
                      ChoiceChip(
                        label: const Text('停用'),
                        selected: !draft.isEnabled,
                        onSelected: (_) => onBindingEnabledChanged(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: isSaving ? null : onSave,
                    icon: Icon(
                      isSaving ? Icons.hourglass_top : Icons.save_outlined,
                    ),
                    label: Text(isSaving ? '儲存中' : '儲存暫存'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoBadge(label: '表單 ID', value: draft.formId),
              _InfoBadge(
                  label: '尺寸',
                  value: draft.formSize.isEmpty ? '-' : draft.formSize),
              _InfoBadge(label: '區塊數', value: '${draft.sections.length}'),
              _InfoBadge(label: '欄位數', value: '${draft.totalFields}'),
              _InfoBadge(label: '狀態', value: draft.isEnabled ? '啟用' : '停用'),
              _InfoBadge(label: '待修正', value: '$errorCount'),
            ],
          ),
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
