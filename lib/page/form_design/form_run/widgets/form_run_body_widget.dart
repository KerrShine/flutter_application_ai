import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/form_run_field_value.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_run/widgets/form_run_section_widget.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 表單執行頁的主體內容 Widget。
/// 依序渲染所有 SectionModel，並統一傳入欄位值、下拉選項覆寫與各種事件 callbacks。
class FormRunBodyWidget extends StatelessWidget {
  final List<SectionModel> sections;
  final Map<String, FormRunFieldValue> fieldValues;
  final Map<String, List<String>> dropdownOptionsOverride;
  final Map<String, String> computedValues;
  final void Function(String itemId, String value) onValueChanged;
  final void Function(String itemId) onButtonPressed;
  final void Function(String itemId, String value) onDropdownChanged;

  const FormRunBodyWidget({
    super.key,
    required this.sections,
    required this.fieldValues,
    required this.dropdownOptionsOverride,
    this.computedValues = const {},
    required this.onValueChanged,
    required this.onButtonPressed,
    required this.onDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>();
    final theme = Theme.of(context);

    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: colors?.faintText ?? Colors.white24,
            ),
            const SizedBox(height: 12),
            Text(
              '此表單尚無區塊資料',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors?.subtleText ?? Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: sections
            .map((section) => FormRunSectionWidget(
                  section: section,
                  fieldValues: fieldValues,
                  dropdownOptionsOverride: dropdownOptionsOverride,
                  computedValues: computedValues,
                  onValueChanged: onValueChanged,
                  onButtonPressed: onButtonPressed,
                  onDropdownChanged: onDropdownChanged,
                ))
            .toList(),
      ),
    );
  }
}
