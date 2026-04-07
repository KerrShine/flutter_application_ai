import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/choice_group_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/date_picker_field_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/dropdown_field_widget.dart';
import 'package:flutter_application_ai/theme/dynamic_form_field_theme.dart';
import 'package:flutter_application_ai/unit/color_hex_utils.dart';

class FormWidgetFactory {
  static Widget buildReadOnlyWidget(BuildContext context, DesignerItem item) {
    return Container(
      padding: EdgeInsets.all(item.padding),
      alignment: item.alignment.value,
      child: _buildContent(context, item),
    );
  }

  static Widget _buildContent(BuildContext context, DesignerItem item) {
    final theme = Theme.of(context);
    final primaryTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final placeholder = item.placeholder.trim();
    final maxLength = item.maxLength <= 0 ? null : item.maxLength;
    switch (item.type) {
      case DesignerItemType.label:
        return Text(
          item.text,
          style: TextStyle(
            fontSize: item.fontSize,
            fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
            color: primaryTextColor,
          ),
          textAlign: _toTextAlign(item.alignment),
        );
      case DesignerItemType.textField:
        return DynamicFormFieldTheme.buildFieldShell(
          context: context,
          item: item,
          child: TextField(
            readOnly: false,
            enabled: true,
            maxLength: maxLength,
            style: DynamicFormFieldTheme.inputTextStyle(context, item),
            decoration: DynamicFormFieldTheme.decoration(
              context: context,
              item: item,
              hintText: _requiredHintText(
                item,
                placeholder.isNotEmpty
                    ? placeholder
                    : (item.fieldName.isEmpty ? null : item.fieldName),
              ),
            ),
          ),
        );
      case DesignerItemType.textArea:
        return DynamicFormFieldTheme.buildFieldShell(
          context: context,
          item: item,
          child: SizedBox(
            height: item.textAreaHeight,
            child: TextField(
              readOnly: false,
              enabled: true,
              maxLength: maxLength,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: DynamicFormFieldTheme.inputTextStyle(context, item),
              decoration: DynamicFormFieldTheme.decoration(
                context: context,
                item: item,
                hintText: _requiredHintText(
                  item,
                  placeholder.isNotEmpty
                      ? placeholder
                      : (item.fieldName.isEmpty ? null : item.fieldName),
                ),
                isMultiline: true,
              ),
            ),
          ),
        );
      case DesignerItemType.radio:
        return ChoiceGroupWidget(
          item: item,
          isRadio: true,
          primaryTextColor: primaryTextColor,
        );
      case DesignerItemType.checkbox:
        return ChoiceGroupWidget(
          item: item,
          isRadio: false,
          primaryTextColor: primaryTextColor,
        );
      case DesignerItemType.dropdown:
        return DropdownFieldWidget(
          item,
          placeholder: placeholder,
        );
      case DesignerItemType.button:
        final buttonBackgroundColor = ColorHexUtils.parse(item.buttonColorHex);
        final buttonForegroundColor =
            ColorHexUtils.parse(item.buttonTextColorHex);
        final button = ElevatedButton(
          onPressed: () {},
          child: Text(item.text.isEmpty ? 'Button' : item.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonForegroundColor,
            textStyle: TextStyle(fontSize: item.fontSize),
          ),
        );
        if (item.buttonWidthMode == ButtonWidthMode.fill) {
          return SizedBox(width: double.infinity, child: button);
        }
        return SizedBox(width: item.buttonWidth, child: button);
      case DesignerItemType.datePicker:
        return DatePickerFieldWidget(
          item: item,
          placeholder: placeholder,
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
          label: Text(
            item.fieldName.isEmpty ? '選擇檔案' : item.fieldName,
          ),
          style: DynamicFormFieldTheme.uploadButtonStyle(context, item),
        );
        final uploadWidget = item.buttonWidthMode == ButtonWidthMode.fill
            ? SizedBox(width: double.infinity, child: uploadButton)
            : SizedBox(width: item.buttonWidth, child: uploadButton);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DynamicFormFieldTheme.buildFieldShell(
              context: context,
              item: item,
              child: uploadWidget,
            ),
            if (hintText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                hintText,
                style: DynamicFormFieldTheme.metaTextStyle(context, item),
              ),
            ],
          ],
        );
    }
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

  static String? _requiredHintText(DesignerItem item, String? hintText) {
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
