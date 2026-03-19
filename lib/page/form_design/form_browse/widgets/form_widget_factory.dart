import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';

class FormWidgetFactory {
  static Widget buildReadOnlyWidget(DesignerItem item) {
    return Container(
      padding: EdgeInsets.all(item.padding),
      alignment: item.alignment.value,
      child: _buildContent(item),
    );
  }

  static Widget _buildContent(DesignerItem item) {
    final placeholder = item.placeholder.trim();
    final maxLength = item.maxLength <= 0 ? null : item.maxLength;
    switch (item.type) {
      case DesignerItemType.label:
        return Text(
          item.text,
          style: TextStyle(
            fontSize: item.fontSize,
            fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: _toTextAlign(item.alignment),
        );
      case DesignerItemType.textField:
        return TextField(
          readOnly: false,
          enabled: true,
          maxLength: maxLength,
          decoration: InputDecoration(
            labelText: item.text,
            hintText: placeholder.isNotEmpty
                ? placeholder
                : (item.fieldName.isEmpty ? null : item.fieldName),
            labelStyle: TextStyle(fontSize: item.fontSize),
            hintStyle: TextStyle(fontSize: item.fontSize),
            border: const OutlineInputBorder(),
            disabledBorder: const OutlineInputBorder(),
          ),
        );
      case DesignerItemType.textArea:
        return SizedBox(
          height: item.textAreaHeight,
          child: TextField(
            readOnly: false,
            enabled: true,
            maxLength: maxLength,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              labelText: item.text,
              hintText: placeholder.isNotEmpty
                  ? placeholder
                  : (item.fieldName.isEmpty ? null : item.fieldName),
              labelStyle: TextStyle(fontSize: item.fontSize),
              hintStyle: TextStyle(fontSize: item.fontSize),
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
            ),
          ),
        );
      case DesignerItemType.radio:
        return _buildChoiceGroup(item: item, isRadio: true);
      case DesignerItemType.checkbox:
        return _buildChoiceGroup(item: item, isRadio: false);
      case DesignerItemType.dropdown:
        return _buildDropdown(item, placeholder);
      case DesignerItemType.button:
        final button = ElevatedButton(
          onPressed: () {},
          child: Text(item.text.isEmpty ? 'Button' : item.text),
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: item.fontSize),
          ),
        );
        if (item.buttonWidthMode == ButtonWidthMode.fill) {
          return SizedBox(width: double.infinity, child: button);
        }
        return SizedBox(width: item.buttonWidth, child: button);
      case DesignerItemType.datePicker:
        return TextField(
          readOnly: false,
          enabled: true,
          decoration: InputDecoration(
            labelText: item.text,
            hintText: placeholder.isNotEmpty
                ? placeholder
                : (item.fieldName.isEmpty ? item.dateFormat : item.fieldName),
            labelStyle: TextStyle(fontSize: item.fontSize),
            hintStyle: TextStyle(fontSize: item.fontSize),
            border: const OutlineInputBorder(),
            disabledBorder: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        );
      case DesignerItemType.fileUpload:
        final normalizedTypes = item.allowedTypes
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .join(', ');
        final hintParts = <String>[];
        if (normalizedTypes.isNotEmpty) {
          hintParts.add('格式: $normalizedTypes');
        }
        if (item.maxSize > 0) {
          hintParts.add('上限: ${item.maxSize}MB');
        }
        final hintText = hintParts.join(' | ');

        final uploadButton = OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.attach_file, size: 16),
          label: Text(item.fieldName.isEmpty ? item.text : item.fieldName),
          style: OutlinedButton.styleFrom(
            textStyle: TextStyle(fontSize: item.fontSize),
          ),
        );
        final uploadWidget = item.buttonWidthMode == ButtonWidthMode.fill
            ? SizedBox(width: double.infinity, child: uploadButton)
            : SizedBox(width: item.buttonWidth, child: uploadButton);

        if (hintText.isEmpty) {
          return uploadWidget;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            uploadWidget,
            const SizedBox(height: 6),
            Text(
              hintText,
              style: TextStyle(fontSize: item.fontSize - 2, color: Colors.grey),
            ),
          ],
        );
    }
  }

  static Widget _buildDropdown(DesignerItem item, String placeholder) {
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
        DropdownButtonFormField<String>(
          value: null,
          items: optionLabels
              .map(
                (label) => DropdownMenuItem<String>(
                  value: label,
                  child: Text(
                    label,
                    style: TextStyle(fontSize: item.fontSize),
                  ),
                ),
              )
              .toList(),
          onChanged: (_) {},
          decoration: InputDecoration(
            labelText: item.text,
            hintText: placeholder.isNotEmpty
                ? placeholder
                : (hasRemoteSource ? '將由遠端資料載入' : null),
            labelStyle: TextStyle(fontSize: item.fontSize),
            hintStyle: TextStyle(fontSize: item.fontSize),
            border: const OutlineInputBorder(),
            disabledBorder: const OutlineInputBorder(),
          ),
        ),
        if (hintParts.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            hintParts.join(' | '),
            style: TextStyle(fontSize: item.fontSize - 2, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  static Widget _buildChoiceGroup({
    required DesignerItem item,
    required bool isRadio,
  }) {
    final optionLabels = item.isGrouped ? item.options : [item.text];
    final title = item.isGrouped && item.text.isNotEmpty ? item.text : '';
    final optionSpacing = item.optionSpacing;
    final children = optionLabels
        .asMap()
        .entries
        .map(
          (entry) => _buildChoiceOption(
            label: entry.value,
            isRadio: isRadio,
            isChecked: isRadio ? entry.key == 0 : false,
            fontSize: item.fontSize,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style:
                TextStyle(fontSize: item.fontSize, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        if (item.isGrouped &&
            item.optionLayout == DesignerItemOptionLayout.horizontal)
          Wrap(
            spacing: optionSpacing,
            runSpacing: optionSpacing,
            children: children,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map(
                  (child) => Padding(
                    padding: EdgeInsets.only(bottom: optionSpacing),
                    child: child,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  static Widget _buildChoiceOption({
    required String label,
    required bool isRadio,
    required bool isChecked,
    required double fontSize,
  }) {
    if (isRadio) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<bool>(
            value: true,
            groupValue: isChecked,
            onChanged: (_) {},
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(label, style: TextStyle(fontSize: fontSize)),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (_) {},
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: TextStyle(fontSize: fontSize)),
      ],
    );
  }

  static TextAlign _toTextAlign(DesignerItemAlignment alignment) {
    switch (alignment) {
      case DesignerItemAlignment.topLeft:
      case DesignerItemAlignment.centerLeft:
      case DesignerItemAlignment.bottomLeft:
        return TextAlign.left;
      case DesignerItemAlignment.topCenter:
      case DesignerItemAlignment.center:
      case DesignerItemAlignment.bottomCenter:
        return TextAlign.center;
      case DesignerItemAlignment.topRight:
      case DesignerItemAlignment.centerRight:
      case DesignerItemAlignment.bottomRight:
        return TextAlign.right;
    }
  }
}
