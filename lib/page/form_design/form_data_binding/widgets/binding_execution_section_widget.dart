import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/designer_item_type.dart';
import 'package:flutter_application_ai/enum/injected_data_source.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/theme/form_design_page_theme.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingExecutionSectionWidget extends StatelessWidget {
  final FormDataBindingSectionDraft section;
  final String Function(String sectionId, String itemId) fieldErrorBuilder;
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
  final void Function(String sectionId, String itemId, String key)
      onProvidedDataKeyChanged;

  const BindingExecutionSectionWidget({
    super.key,
    required this.section,
    required this.fieldErrorBuilder,
    required this.actionSummaryBuilder,
    required this.onOpenActionBinding,
    required this.onOutputKeyChanged,
    required this.onNullStrategyChanged,
    required this.onCustomDefaultChanged,
    required this.onProvidedDataKeyChanged,
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
                  final error =
                      fieldErrorBuilder(section.sectionId, field.itemId);
                  return _FieldRow(
                    sectionId: section.sectionId,
                    field: field,
                    actionSummary: actionSummaryBuilder(field.itemId),
                    errorText: error,
                    onOpenActionBinding: onOpenActionBinding,
                    onOutputKeyChanged: onOutputKeyChanged,
                    onNullStrategyChanged: onNullStrategyChanged,
                    onCustomDefaultChanged: onCustomDefaultChanged,
                    onProvidedDataKeyChanged: onProvidedDataKeyChanged,
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
  final void Function(String sectionId, String itemId, String key)
      onProvidedDataKeyChanged;

  const _FieldRow({
    required this.sectionId,
    required this.field,
    required this.actionSummary,
    required this.errorText,
    required this.onOpenActionBinding,
    required this.onOutputKeyChanged,
    required this.onNullStrategyChanged,
    required this.onCustomDefaultChanged,
    required this.onProvidedDataKeyChanged,
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
          _supportsActionBinding
              ? _buildActionBindingFieldRow(context, theme, colors, hasError)
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
                        decoration:
                            FormDesignPageTheme.executionInputDecoration(
                          context,
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
                        decoration:
                            FormDesignPageTheme.executionInputDecoration(
                          context,
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
                      child: _buildDefaultValueCell(
                        context,
                        theme,
                        colors,
                        hasError: hasError,
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

  /// 「預設值 / 預設行為」儲存格 — 依 nullStrategy 切換內容。
  Widget _buildDefaultValueCell(
    BuildContext context,
    ThemeData theme,
    FormDesignThemeColors colors, {
    required bool hasError,
  }) {
    switch (field.nullStrategy) {
      case BindingNullStrategy.skip:
        return _SystemDefaultDisplay(field: field);
      case BindingNullStrategy.custom:
        return TextFormField(
          initialValue: field.customDefaultValue,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.headerAccentForeground,
            fontWeight: FontWeight.w700,
          ),
          decoration: FormDesignPageTheme.executionInputDecoration(
            context,
            isDense: true,
            errorText: hasError && errorText != '套用結果不可為空' ? errorText : null,
          ),
          onChanged: (value) {
            onCustomDefaultChanged(sectionId, field.itemId, value);
          },
        );
      case BindingNullStrategy.injected:
        final current = InjectedDataSourceX.fromCode(field.providedDataKey);
        return DropdownButtonFormField<InjectedDataSource>(
          value: current,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.headerAccentForeground,
            fontWeight: FontWeight.w700,
          ),
          dropdownColor: const Color(0xFF262B38),
          iconEnabledColor: colors.headerAccentForeground,
          isDense: true,
          decoration: FormDesignPageTheme.executionInputDecoration(
            context,
            isDense: true,
            errorText: hasError && errorText != '套用結果不可為空' ? errorText : null,
          ).copyWith(hintText: '選擇資料源'),
          items: InjectedDataSource.values
              .map((src) => DropdownMenuItem<InjectedDataSource>(
                    value: src,
                    child: Text(src.label),
                  ))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            onProvidedDataKeyChanged(sectionId, field.itemId, value.code);
          },
        );
    }
  }

  Widget _buildActionBindingFieldRow(
    BuildContext context,
    ThemeData theme,
    FormDesignThemeColors colors,
    bool hasError,
  ) {
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
              field.fieldKind == BindingFieldKind.button
                  ? 'button'
                  : field.displayTypeLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.headerAccentForeground,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 18,
          child: field.fieldKind == BindingFieldKind.button
              ? _ReadonlyValueDisplay(text: '動作綁定', colors: colors)
              : TextFormField(
                  initialValue: field.outputKey,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.headerAccentForeground,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: FormDesignPageTheme.executionInputDecoration(
                    context,
                    isDense: true,
                    errorText:
                        hasError && errorText == '套用結果不可為空' ? errorText : null,
                  ),
                  onChanged: (value) {
                    onOutputKeyChanged(sectionId, field.itemId, value);
                  },
                ),
        ),
        const SizedBox(width: 8),
        const Expanded(flex: 12, child: SizedBox.shrink()),
        const SizedBox(width: 8),
        const Expanded(flex: 18, child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildActionBindingEntry(
    ThemeData theme,
    FormDesignThemeColors colors,
  ) {
    final hasSelectedActions = actionSummary != '尚未選擇動作';
    final actionItems = hasSelectedActions
        ? actionSummary
            .split('\n')
            .map((item) => item.replaceFirst('• ', '').trim())
            .where((item) => item.isNotEmpty)
            .toList()
        : const <String>[];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: hasSelectedActions
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              colors.sectionIconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: colors.sectionIconColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: colors.sectionIconColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '已設定完畢',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colors.headerAccentForeground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...actionItems.map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.headerChipBackground
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: colors.headerChipText.withValues(
                                alpha: 0.16,
                              ),
                            ),
                          ),
                          child: Text(
                            item,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.headerAccentForeground,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '尚未設定',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.faintText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
