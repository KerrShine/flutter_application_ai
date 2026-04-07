import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/theme/dynamic_form_field_theme.dart';

class DropdownFieldWidget extends StatelessWidget {
  final DesignerItem item;
  final String placeholder;

  const DropdownFieldWidget(
    this.item, {
    super.key,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final optionLabels = item.options.isEmpty ? const ['選項1'] : item.options;
    final hasRemoteSource = item.dataSourceUrl.trim().isNotEmpty;
    final hintParts = <String>[];

    if (hasRemoteSource) {
      hintParts.add('來源: API');
    }
    if (item.dataSourceKey.trim().isNotEmpty) {
      hintParts.add('鍵: ${item.dataSourceKey.trim()}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DynamicFormFieldTheme.buildFieldShell(
          context: context,
          item: item,
          child: DropdownButtonFormField<String>(
            value: null,
            items: optionLabels
                .map(
                  (label) => DropdownMenuItem<String>(
                    value: label,
                    child: Text(
                      label,
                      style: DynamicFormFieldTheme.inputTextStyle(
                        context,
                        item,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (_) {},
            style: DynamicFormFieldTheme.inputTextStyle(context, item),
            dropdownColor: Theme.of(context).cardColor,
            decoration: DynamicFormFieldTheme.decoration(
              context: context,
              item: item,
              hintText: _requiredHintText(
                placeholder.isNotEmpty
                    ? placeholder
                    : (hasRemoteSource ? '將由遠端資料載入' : null),
              ),
            ),
          ),
        ),
        if (hintParts.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            hintParts.join(' | '),
            style: DynamicFormFieldTheme.metaTextStyle(context, item),
          ),
        ],
      ],
    );
  }

  String? _requiredHintText(String? hintText) {
    final normalizedHint = hintText?.trim();
    if (normalizedHint == null || normalizedHint.isEmpty) {
      return normalizedHint;
    }
    if (!item.required || normalizedHint.startsWith('*')) {
      return normalizedHint;
    }
    return '* $normalizedHint';
  }
}
