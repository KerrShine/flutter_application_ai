import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/form_browse_field_meta.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_event.dart';
import 'package:flutter_application_ai/theme/form_browse_theme_colors.dart';

class FormBrowsePropertyPanelWidget extends StatelessWidget {
  final List<SectionModel> sections;
  final String? selectedFieldKey;
  final String? expandedFieldKey;

  const FormBrowsePropertyPanelWidget({
    super.key,
    required this.sections,
    this.selectedFieldKey,
    this.expandedFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormBrowseThemeColors>()!;
    final fields = _flattenFields(sections);

    if (fields.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: colors.panelBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.panelBorder),
          boxShadow: [
            BoxShadow(
              color: colors.panelShadow,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '無可檢視屬性',
            style:
                theme.textTheme.bodyMedium?.copyWith(color: colors.mutedText),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.panelBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.headerBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.panelBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.tune, color: colors.headerForeground),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '欄位屬性',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.headerForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '共 ${fields.length} 欄位，可展開查看完整設定。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtleText,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: fields.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final field = fields[index];
                final fieldKey = '${field.section.id}::${field.item.id}';
                final isSelected = selectedFieldKey == fieldKey;
                final isExpanded = expandedFieldKey == fieldKey;

                return Material(
                  color: isSelected
                      ? colors.propertyCardSelectedBackground
                      : colors.propertyCardBackground,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      context.read<FormBrowseBloc>().add(
                            ToggleFieldExpandEvent(
                              sectionId: field.section.id,
                              itemId: field.item.id,
                            ),
                          );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? colors.previewSelectedBorder
                              : colors.panelBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  field.item.text.isEmpty
                                      ? '(未命名欄位)'
                                      : field.item.text,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                field.item.type.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.mutedText,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 18,
                                color: colors.mutedText,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${field.section.name} / row ${field.item.rowIndex}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.mutedText,
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 8),
                            _buildPropertyLine(context, 'id', field.item.id),
                            _buildPropertyLine(
                                context, 'fieldName', field.item.fieldName),
                            _buildPropertyLine(
                                context, 'placeholder', field.item.placeholder),
                            _buildPropertyLine(context, 'required',
                                field.item.required.toString()),
                            _buildPropertyLine(context, 'readonly',
                                field.item.readonly.toString()),
                            _buildPropertyLine(context, 'widthPercentage',
                                field.item.widthPercentage.toString()),
                            _buildPropertyLine(context, 'alignment',
                                field.item.alignment.name),
                            _buildPropertyLine(context, 'padding',
                                field.item.padding.toString()),
                            _buildPropertyLine(context, 'fontSize',
                                field.item.fontSize.toString()),
                            _buildPropertyLine(context, 'maxLength',
                                field.item.maxLength.toString()),
                            _buildPropertyLine(context, 'inputType',
                                field.item.inputType.name),
                            _buildPropertyLine(
                                context, 'dateFormat', field.item.dateFormat),
                            _buildPropertyLine(context, 'options',
                                field.item.options.join(', ')),
                            _buildPropertyLine(context, 'isGrouped',
                                field.item.isGrouped.toString()),
                            _buildPropertyLine(context, 'optionLayout',
                                field.item.optionLayout.name),
                            _buildPropertyLine(context, 'optionSpacing',
                                field.item.optionSpacing.toString()),
                            _buildPropertyLine(context, 'buttonWidthMode',
                                field.item.buttonWidthMode.name),
                            _buildPropertyLine(context, 'buttonWidth',
                                field.item.buttonWidth.toString()),
                            _buildPropertyLine(context, 'textAreaHeight',
                                field.item.textAreaHeight.toString()),
                            _buildPropertyLine(context, 'allowedTypes',
                                field.item.allowedTypes),
                            _buildPropertyLine(context, 'maxSize',
                                field.item.maxSize.toString()),
                            _buildPropertyLine(context, 'dataSourceUrl',
                                field.item.dataSourceUrl),
                            _buildPropertyLine(context, 'dataSourceKey',
                                field.item.dataSourceKey),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyLine(BuildContext context, String key, String value) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormBrowseThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  List<FormBrowseFieldMeta> _flattenFields(List<SectionModel> sections) {
    final result = <FormBrowseFieldMeta>[];
    for (final section in sections) {
      final sortedItems = [...section.items]..sort((a, b) {
          final rowCompare = a.rowIndex.compareTo(b.rowIndex);
          if (rowCompare != 0) return rowCompare;
          return a.id.compareTo(b.id);
        });

      for (final item in sortedItems) {
        result.add(FormBrowseFieldMeta(section: section, item: item));
      }
    }
    return result;
  }
}
