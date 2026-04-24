import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/theme/dynamic_form_field_theme.dart';

/// 表單執行頁的文字輸入欄位 Widget（含 textField / textArea）。
/// 使用者輸入時透過 onChanged 即時通知父層更新 fieldValues。
class FormRunTextFieldWidget extends StatefulWidget {
  final DesignerItem item;
  final String initialValue;
  final void Function(String value) onChanged;
  final bool multiline;

  const FormRunTextFieldWidget({
    super.key,
    required this.item,
    required this.onChanged,
    this.initialValue = '',
    this.multiline = false,
  });

  @override
  State<FormRunTextFieldWidget> createState() => _FormRunTextFieldWidgetState();
}

class _FormRunTextFieldWidgetState extends State<FormRunTextFieldWidget> {
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
    final maxLength = item.maxLength <= 0 ? null : item.maxLength;
    final hintText = placeholder.isNotEmpty
        ? placeholder
        : (item.fieldName.isNotEmpty ? item.fieldName : null);
    final requiredHint = item.required && hintText != null && !hintText.startsWith('*')
        ? '* $hintText'
        : hintText;

    if (widget.multiline) {
      return DynamicFormFieldTheme.buildFieldShell(
        context: context,
        item: item,
        child: SizedBox(
          height: item.textAreaHeight,
          child: TextField(
            controller: _controller,
            readOnly: item.readonly,
            enabled: !item.readonly,
            maxLength: maxLength,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            onChanged: widget.onChanged,
            style: DynamicFormFieldTheme.inputTextStyle(context, item),
            decoration: DynamicFormFieldTheme.decoration(
              context: context,
              item: item,
              hintText: requiredHint,
              isMultiline: true,
            ),
          ),
        ),
      );
    }

    return DynamicFormFieldTheme.buildFieldShell(
      context: context,
      item: item,
      child: TextField(
        controller: _controller,
        readOnly: item.readonly,
        enabled: !item.readonly,
        maxLength: maxLength,
        onChanged: widget.onChanged,
        style: DynamicFormFieldTheme.inputTextStyle(context, item),
        decoration: DynamicFormFieldTheme.decoration(
          context: context,
          item: item,
          hintText: requiredHint,
        ),
      ),
    );
  }
}
