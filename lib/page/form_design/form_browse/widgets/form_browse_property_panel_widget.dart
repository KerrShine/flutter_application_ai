import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/form_browse_field_meta.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_event.dart';

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
    final fields = _flattenFields(sections);

    if (fields.isEmpty) {
      return const Center(
        child: Text(
          '無可檢視屬性',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '欄位屬性',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '共 ${fields.length} 欄位',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: fields.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final field = fields[index];
              final fieldKey = '${field.section.id}::${field.item.id}';
              final isSelected = selectedFieldKey == fieldKey;
              final isExpanded = expandedFieldKey == fieldKey;

              return Card(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.blue.shade200
                        : Colors.grey.shade300,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    context.read<FormBrowseBloc>().add(
                          ToggleFieldExpandEvent(
                            sectionId: field.section.id,
                            itemId: field.item.id,
                          ),
                        );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              field.item.type.name,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black54),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${field.section.name} / row ${field.item.rowIndex}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 8),
                          _buildPropertyLine('id', field.item.id),
                          _buildPropertyLine('fieldName', field.item.fieldName),
                          _buildPropertyLine(
                              'placeholder', field.item.placeholder),
                          _buildPropertyLine(
                              'required', field.item.required.toString()),
                          _buildPropertyLine(
                              'readonly', field.item.readonly.toString()),
                          _buildPropertyLine('widthPercentage',
                              field.item.widthPercentage.toString()),
                          _buildPropertyLine(
                              'alignment', field.item.alignment.name),
                          _buildPropertyLine(
                              'padding', field.item.padding.toString()),
                          _buildPropertyLine(
                              'fontSize', field.item.fontSize.toString()),
                          _buildPropertyLine(
                              'maxLength', field.item.maxLength.toString()),
                          _buildPropertyLine(
                              'inputType', field.item.inputType.name),
                          _buildPropertyLine(
                              'dateFormat', field.item.dateFormat),
                          _buildPropertyLine(
                              'options', field.item.options.join(', ')),
                          _buildPropertyLine(
                              'isGrouped', field.item.isGrouped.toString()),
                          _buildPropertyLine(
                              'optionLayout', field.item.optionLayout.name),
                          _buildPropertyLine('optionSpacing',
                              field.item.optionSpacing.toString()),
                          _buildPropertyLine('buttonWidthMode',
                              field.item.buttonWidthMode.name),
                          _buildPropertyLine(
                              'buttonWidth', field.item.buttonWidth.toString()),
                          _buildPropertyLine('textAreaHeight',
                              field.item.textAreaHeight.toString()),
                          _buildPropertyLine(
                              'allowedTypes', field.item.allowedTypes),
                          _buildPropertyLine(
                              'maxSize', field.item.maxSize.toString()),
                          _buildPropertyLine(
                              'dataSourceUrl', field.item.dataSourceUrl),
                          _buildPropertyLine(
                              'dataSourceKey', field.item.dataSourceKey),
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
    );
  }

  Widget _buildPropertyLine(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 12),
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
