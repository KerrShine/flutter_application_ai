import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';

class DesignerItemRowWidget extends StatelessWidget {
  final DesignerItem item;
  final int index;
  final bool isSelected;

  const DesignerItemRowWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? Colors.blue : Colors.grey.shade300;
    final borderWidth = isSelected ? 2.0 : 1.0;

    return InkWell(
      onTap: () => context.read<FormSectionDesignBloc>().add(
            SelectDesignerItemEvent(item.id),
          ),
      child: Container(
        padding: EdgeInsets.all(item.padding),
        alignment: item.alignment.value,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final placeholder = item.placeholder.trim();
    final maxLength = item.maxLength <= 0 ? null : item.maxLength;
    switch (item.type) {
      case DesignerItemType.label:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.label_outline, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: item.fontSize,
                  fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle, color: Colors.black54),
          ],
        );
      case DesignerItemType.textField:
        return Row(
          children: [
            const Icon(Icons.text_fields, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                enabled: false,
                maxLength: maxLength,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: item.text,
                  hintText: placeholder.isEmpty ? null : placeholder,
                  hintStyle: TextStyle(fontSize: item.fontSize),
                  labelStyle: TextStyle(fontSize: item.fontSize),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle, color: Colors.black54),
          ],
        );
      case DesignerItemType.textArea:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.notes, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: item.textAreaHeight,
                child: TextField(
                  enabled: false,
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
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.drag_handle, color: Colors.black54),
            ),
          ],
        );
      case DesignerItemType.radio:
        return _buildChoiceRow(isRadio: true);
      case DesignerItemType.checkbox:
        return _buildChoiceRow(isRadio: false);
      case DesignerItemType.dropdown:
        return _buildDropdownRow();
      case DesignerItemType.datePicker:
        return Row(
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: item.text,
                  hintText:
                      placeholder.isNotEmpty ? placeholder : item.dateFormat,
                  labelStyle: TextStyle(fontSize: item.fontSize),
                  hintStyle: TextStyle(fontSize: item.fontSize),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle, color: Colors.black54),
          ],
        );
      case DesignerItemType.fileUpload:
        return _buildFileUploadRow();
      case DesignerItemType.button:
        return _buildButtonRow();
    }
  }

  Widget _buildDropdownRow() {
    final placeholder = item.placeholder.trim();
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.arrow_drop_down_circle_outlined, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
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
                onChanged: null,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: item.text,
                  hintText: placeholder.isNotEmpty
                      ? placeholder
                      : (hasRemoteSource ? '將由遠端資料載入' : null),
                  labelStyle: TextStyle(fontSize: item.fontSize),
                  hintStyle: TextStyle(fontSize: item.fontSize),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.drag_handle, color: Colors.black54),
            ),
          ],
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

  Widget _buildFileUploadRow() {
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
      onPressed: null,
      icon: const Icon(Icons.attach_file, size: 16),
      label: Text(item.text.isEmpty ? '選擇檔案' : item.text),
      style: OutlinedButton.styleFrom(
        textStyle: TextStyle(fontSize: item.fontSize),
      ),
    );

    final buttonWidget = item.buttonWidthMode == ButtonWidthMode.fill
        ? SizedBox(width: double.infinity, child: uploadButton)
        : SizedBox(width: item.buttonWidth, child: uploadButton);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: item.buttonWidthMode == ButtonWidthMode.fill
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file, size: 18),
            const SizedBox(width: 8),
            if (item.buttonWidthMode == ButtonWidthMode.fill)
              Expanded(child: buttonWidget)
            else
              buttonWidget,
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle, color: Colors.black54),
          ],
        ),
        if (hintText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            hintText,
            style: TextStyle(fontSize: item.fontSize - 2, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildButtonRow() {
    final button = ElevatedButton(
      onPressed: null,
      child: Text(item.text),
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(fontSize: item.fontSize),
      ),
    );

    final buttonWidget = item.buttonWidthMode == ButtonWidthMode.fill
        ? SizedBox(width: double.infinity, child: button)
        : SizedBox(width: item.buttonWidth, child: button);

    return Row(
      mainAxisSize: item.buttonWidthMode == ButtonWidthMode.fill
          ? MainAxisSize.max
          : MainAxisSize.min,
      children: [
        const Icon(Icons.touch_app, size: 18),
        const SizedBox(width: 8),
        if (item.buttonWidthMode == ButtonWidthMode.fill)
          Expanded(child: buttonWidget)
        else
          buttonWidget,
        const SizedBox(width: 8),
        const Icon(Icons.drag_handle, color: Colors.black54),
      ],
    );
  }

  Widget _buildChoiceRow({required bool isRadio}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            isRadio ? Icons.radio_button_checked : Icons.check_box_outlined,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildChoiceContent(isRadio: isRadio)),
        const SizedBox(width: 8),
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.drag_handle, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildChoiceContent({required bool isRadio}) {
    final optionLabels = item.isGrouped ? item.options : [item.text];
    final title = item.isGrouped && item.text.isNotEmpty ? item.text : '';
    final optionSpacing = item.optionSpacing;
    final children = optionLabels
        .map((label) => _buildChoiceOption(label: label, isRadio: isRadio))
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

  Widget _buildChoiceOption({
    required String label,
    required bool isRadio,
  }) {
    if (isRadio) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<int>(
            value: 0,
            groupValue: 0,
            onChanged: null,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(label, style: TextStyle(fontSize: item.fontSize)),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: false,
          onChanged: null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: TextStyle(fontSize: item.fontSize)),
      ],
    );
  }
}
