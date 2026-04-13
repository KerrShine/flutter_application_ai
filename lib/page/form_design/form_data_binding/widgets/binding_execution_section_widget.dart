import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/designer_item_type.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingExecutionSectionWidget extends StatelessWidget {
  final FormDataBindingSectionDraft section;
  final Map<String, String> fieldErrors;
  final String Function(String sectionId, String itemId) fieldKeyBuilder;
  final String Function(String itemId) actionSummaryBuilder;
  final void Function(String sectionId, String itemId) onOpenActionBinding;
  final void Function(String sectionId, String itemId, String outputKey)
      onOutputKeyChanged;
  final void Function(
    String sectionId,
    String itemId,
    BindingNullStrategy nullStrategy,
  ) onNullStrategyChanged;
  final void Function(String sectionId, String itemId, String value)
      onCustomDefaultChanged;

  const BindingExecutionSectionWidget({
    super.key,
    required this.section,
    required this.fieldErrors,
    required this.fieldKeyBuilder,
    required this.actionSummaryBuilder,
    required this.onOpenActionBinding,
    required this.onOutputKeyChanged,
    required this.onNullStrategyChanged,
    required this.onCustomDefaultChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.sectionPanelBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.sectionName, style: theme.textTheme.titleMedium),
                if (section.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    section.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.faintText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const _HeaderRow(),
                const SizedBox(height: 8),
                ...section.fields.map((field) {
                  final error = fieldErrors[
                          fieldKeyBuilder(section.sectionId, field.itemId)] ??
                      '';
                  return _FieldRow(
                    sectionId: section.sectionId,
                    field: field,
                    actionSummary: actionSummaryBuilder(field.itemId),
                    errorText: error,
                    onOpenActionBinding: onOpenActionBinding,
                    onOutputKeyChanged: onOutputKeyChanged,
                    onNullStrategyChanged: onNullStrategyChanged,
                    onCustomDefaultChanged: onCustomDefaultChanged,
                  );
                }),
              ],
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
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.headerAccentForeground,
          fontWeight: FontWeight.w700,
        );
    return Row(
      children: [
        Expanded(flex: 18, child: Text('欄位', style: style)),
        Expanded(flex: 8, child: Text('型別', style: style)),
        Expanded(flex: 18, child: Text('對應欄位', style: style)),
        Expanded(flex: 12, child: Text('空值策略', style: style)),
        Expanded(flex: 18, child: Text('預設值 / 預設行為', style: style)),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String sectionId;
  final FormDataBindingFieldDraft field;
  final String actionSummary;
  final String errorText;
  final void Function(String sectionId, String itemId) onOpenActionBinding;
  final void Function(String sectionId, String itemId, String outputKey)
      onOutputKeyChanged;
  final void Function(
    String sectionId,
    String itemId,
    BindingNullStrategy nullStrategy,
  ) onNullStrategyChanged;
  final void Function(String sectionId, String itemId, String value)
      onCustomDefaultChanged;

  const _FieldRow({
    required this.sectionId,
    required this.field,
    required this.actionSummary,
    required this.errorText,
    required this.onOpenActionBinding,
    required this.onOutputKeyChanged,
    required this.onNullStrategyChanged,
    required this.onCustomDefaultChanged,
  });

  bool get _supportsActionBinding {
    return field.fieldKind == BindingFieldKind.button ||
        field.sourceType == DesignerItemType.dropdown.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final hasError = errorText.isNotEmpty;
    final strategyItems = BindingNullStrategy.values
        .map(
          (item) => DropdownMenuItem<BindingNullStrategy>(
            value: item,
            child: Text(
              item == BindingNullStrategy.skip ? '略過' : '預設',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.headerAccentForeground,
              ),
            ),
          ),
        )
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasError ? const Color(0xFF41292C) : const Color(0xFF1E2431),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError
              ? const Color(0xFF8F4C55)
              : colors.panelBorder.withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        children: [
          field.fieldKind == BindingFieldKind.button
              ? _buildButtonRow(theme, colors)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 18,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          field.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.headerAccentForeground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          field.displayTypeLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.headerAccentForeground,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 18,
                      child: TextFormField(
                        initialValue: field.outputKey,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _buildDarkInputDecoration(
                          colors: colors,
                          isDense: true,
                          errorText: hasError && errorText == '套用結果不可為空'
                              ? errorText
                              : null,
                        ),
                        onChanged: (value) {
                          onOutputKeyChanged(sectionId, field.itemId, value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 12,
                      child: DropdownButtonFormField<BindingNullStrategy>(
                        value: field.nullStrategy,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                        ),
                        dropdownColor: const Color(0xFF262B38),
                        iconEnabledColor: colors.headerAccentForeground,
                        isDense: true,
                        decoration: _buildDarkInputDecoration(
                          colors: colors,
                          isDense: true,
                        ),
                        items: strategyItems,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          onNullStrategyChanged(sectionId, field.itemId, value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 18,
                      child: field.nullStrategy == BindingNullStrategy.skip
                          ? _SystemDefaultDisplay(field: field)
                          : TextFormField(
                              initialValue: field.customDefaultValue,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colors.headerAccentForeground,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: _buildDarkInputDecoration(
                                colors: colors,
                                isDense: true,
                                errorText: hasError && errorText != '套用結果不可為空'
                                    ? errorText
                                    : null,
                              ),
                              onChanged: (value) {
                                onCustomDefaultChanged(
                                  sectionId,
                                  field.itemId,
                                  value,
                                );
                              },
                            ),
                    ),
                  ],
                ),
          if (_supportsActionBinding) ...[
            const SizedBox(height: 10),
            _buildActionBindingEntry(theme, colors),
          ],
          if (field.required) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF1F1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'required 輸出不可省略',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFC0392B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtonRow(ThemeData theme, FormDesignThemeColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 18,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              field.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.headerAccentForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'button',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.headerAccentForeground,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 18,
          child: _ReadonlyValueDisplay(text: '動作綁定', colors: colors),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 12,
          child: _ReadonlyValueDisplay(text: '略過', colors: colors),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 18,
          child: _ReadonlyValueDisplay(text: '預設行為', colors: colors),
        ),
      ],
    );
  }

  Widget _buildActionBindingEntry(
    ThemeData theme,
    FormDesignThemeColors colors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.headerChipBackground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.headerChipText.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已選動作',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.headerAccentForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  actionSummary == '尚未選擇動作'
                      ? '此元件支援後續動作設定，可進入獨立頁面管理跳轉與其他觸發行為。'
                      : actionSummary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.faintText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () {
              onOpenActionBinding(sectionId, field.itemId);
            },
            icon: const Icon(Icons.route_outlined),
            label: Text(actionSummary == '尚未選擇動作' ? '設定動作' : '調整動作'),
          ),
        ],
      ),
    );
  }

  String _helperText(FormDataBindingFieldDraft field) {
    switch (field.valueType) {
      case BindingFieldValueType.number:
        return '請輸入數字';
      case BindingFieldValueType.date:
        return '請輸入 yyyy-MM-dd';
      case BindingFieldValueType.file:
        return '可輸入 File 類別或附件範例';
      case BindingFieldValueType.string:
        return '可輸入任意字串';
    }
  }

  InputDecoration _buildDarkInputDecoration({
    required FormDesignThemeColors colors,
    required bool isDense,
    String? errorText,
  }) {
    return InputDecoration(
      isDense: isDense,
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      errorText: errorText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: colors.shellBorder.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.sectionIconColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE07A7A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF9B9B), width: 1.4),
      ),
    );
  }
}

class _SystemDefaultDisplay extends StatelessWidget {
  final FormDataBindingFieldDraft field;

  const _SystemDefaultDisplay({required this.field});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;
    final value =
        field.systemDefaultValue.isEmpty ? '空字串' : field.systemDefaultValue;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.shellBorder.withValues(alpha: 0.7)),
      ),
      child: Text(
        '系統預設: $value',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.headerAccentForeground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ReadonlyValueDisplay extends StatelessWidget {
  final String text;
  final FormDesignThemeColors colors;

  const _ReadonlyValueDisplay({
    required this.text,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.shellBorder.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.headerAccentForeground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
