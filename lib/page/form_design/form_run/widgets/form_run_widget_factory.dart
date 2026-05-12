import 'package:flutter/material.dart';
import 'package:flutter_application_ai/dialog/datepicker_dialog.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/choice_group_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_run/widgets/form_run_dropdown_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_run/widgets/form_run_text_field_widget.dart';
import 'package:flutter_application_ai/theme/dynamic_form_field_theme.dart';
import 'package:flutter_application_ai/unit/color_hex_utils.dart';

/// 表單執行頁的互動式 Widget 工廠。
/// 依 DesignerItem.type 分派對應的執行期元件（TextField、Dropdown、Button 等），
/// 並將 onChanged / onButtonPressed 等 callbacks 注入，實現欄位值即時回傳。
class FormRunWidgetFactory {
  static Widget buildInteractiveWidget({
    required BuildContext context,
    required DesignerItem item,
    required String currentValue,
    List<String>? dropdownOptionsOverride,
    Map<String, String> computedValues = const {},
    required void Function(String value) onValueChanged,
    required void Function() onButtonPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(item.padding),
      alignment: item.alignment.value,
      child: _buildContent(
        context: context,
        item: item,
        currentValue: currentValue,
        dropdownOptionsOverride: dropdownOptionsOverride,
        computedValues: computedValues,
        onValueChanged: onValueChanged,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  static Widget _buildContent({
    required BuildContext context,
    required DesignerItem item,
    required String currentValue,
    List<String>? dropdownOptionsOverride,
    required Map<String, String> computedValues,
    required void Function(String value) onValueChanged,
    required void Function() onButtonPressed,
  }) {
    final theme = Theme.of(context);
    final primaryTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;

    switch (item.type) {
      case DesignerItemType.label:
        // 綁 condition_field 時把 item.text 當 template，用 `{value}` 占位符替換成計算結果，
        // 例如「共 {value} 天」→「共 5 天」；text 中無占位符時 fallback 為純值顯示。
        // 未綁定則顯示設計師輸入的靜態文字。
        String displayText = item.text;
        if (item.computedFieldKey.isNotEmpty) {
          final value = computedValues[item.computedFieldKey] ?? '';
          displayText = item.text.contains('{value}')
              ? item.text.replaceAll('{value}', value)
              : value;
        }
        return Text(
          displayText,
          style: TextStyle(
            fontSize: item.fontSize,
            fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
            color: primaryTextColor,
          ),
        );

      case DesignerItemType.textField:
        return FormRunTextFieldWidget(
          item: item,
          initialValue: currentValue,
          onChanged: onValueChanged,
        );

      case DesignerItemType.textArea:
        return FormRunTextFieldWidget(
          item: item,
          initialValue: currentValue,
          onChanged: onValueChanged,
          multiline: true,
        );

      case DesignerItemType.dropdown:
        return FormRunDropdownWidget(
          item: item,
          initialValue: currentValue,
          optionsOverride: dropdownOptionsOverride,
          onChanged: onValueChanged,
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

      case DesignerItemType.datePicker:
        return _FormRunDatePickerWidget(
          item: item,
          initialValue: currentValue,
          onChanged: onValueChanged,
        );

      case DesignerItemType.button:
        final bg = ColorHexUtils.parse(item.buttonColorHex);
        final fg = ColorHexUtils.parse(item.buttonTextColorHex);
        final btn = ElevatedButton(
          onPressed: onButtonPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            textStyle: TextStyle(fontSize: item.fontSize),
          ),
          child: Text(item.text.isEmpty ? 'Button' : item.text),
        );
        if (item.buttonWidthMode == ButtonWidthMode.fill) {
          return SizedBox(width: double.infinity, child: btn);
        }
        return SizedBox(width: item.buttonWidth, child: btn);

      case DesignerItemType.fileUpload:
        // 暫時唯讀，不處理上傳
        final uploadButton = OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.attach_file, size: 16),
          label: Text(item.fieldName.isEmpty ? '選擇檔案' : item.fieldName),
          style: DynamicFormFieldTheme.uploadButtonStyle(context, item),
        );
        return item.buttonWidthMode == ButtonWidthMode.fill
            ? SizedBox(width: double.infinity, child: uploadButton)
            : SizedBox(width: item.buttonWidth, child: uploadButton);
    }
  }
}

class _FormRunDatePickerWidget extends StatefulWidget {
  final DesignerItem item;
  final String initialValue;
  final void Function(String value) onChanged;

  const _FormRunDatePickerWidget({
    required this.item,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_FormRunDatePickerWidget> createState() =>
      _FormRunDatePickerWidgetState();
}

class _FormRunDatePickerWidgetState extends State<_FormRunDatePickerWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final placeholder = item.placeholder.trim();
    return DynamicFormFieldTheme.buildFieldShell(
      context: context,
      item: item,
      child: TextField(
        controller: _controller,
        readOnly: true,
        enabled: true,
        style: DynamicFormFieldTheme.inputTextStyle(context, item),
        decoration: DynamicFormFieldTheme.decoration(
          context: context,
          item: item,
          hintText: placeholder.isNotEmpty
              ? placeholder
              : (item.fieldName.isEmpty ? item.dateFormat : item.fieldName),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: item.readonly ? null : _pickDate,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePickerDialog(
      context: context,
      initialDate: _parseDate(_controller.text),
    );
    if (!mounted || selected == null || selected.isEmpty) return;
    setState(() => _controller.text = selected);
    widget.onChanged(selected);
  }

  DateTime? _parseDate(String value) {
    final parts = value.trim().split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }
}
