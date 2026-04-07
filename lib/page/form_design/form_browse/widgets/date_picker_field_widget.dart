import 'package:flutter/material.dart';
import 'package:flutter_application_ai/dialog/datepicker_dialog.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/theme/dynamic_form_field_theme.dart';

class DatePickerFieldWidget extends StatefulWidget {
  final DesignerItem item;
  final String placeholder;

  const DatePickerFieldWidget({
    super.key,
    required this.item,
    required this.placeholder,
  });

  @override
  State<DatePickerFieldWidget> createState() => _DatePickerFieldWidgetState();
}

class _DatePickerFieldWidgetState extends State<DatePickerFieldWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicFormFieldTheme.buildFieldShell(
      context: context,
      item: widget.item,
      child: TextField(
        controller: _controller,
        readOnly: true,
        enabled: true,
        style: DynamicFormFieldTheme.inputTextStyle(context, widget.item),
        decoration: DynamicFormFieldTheme.decoration(
          context: context,
          item: widget.item,
          hintText: widget.placeholder.isNotEmpty
              ? widget.placeholder
              : (widget.item.fieldName.isEmpty
                  ? widget.item.dateFormat
                  : widget.item.fieldName),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: widget.item.readonly ? null : _handlePickDate,
          ),
        ),
      ),
    );
  }

  Future<void> _handlePickDate() async {
    final selectedDate = await showDatePickerDialog(
      context: context,
      initialDate: _parseDate(_controller.text),
    );

    if (!mounted || selectedDate == null || selectedDate.isEmpty) {
      return;
    }

    setState(() {
      _controller.text = selectedDate;
    });
  }

  DateTime? _parseDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final parts = normalized.split('-');
    if (parts.length != 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}
