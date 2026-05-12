import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/form_run_field_value.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_run/widgets/form_run_widget_factory.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 表單執行頁的單一 Section 渲染 Widget。
/// 顯示 Section 標題，並透過 FormRunWidgetFactory 逐一渲染該 Section 下的欄位元件。
class FormRunSectionWidget extends StatelessWidget {
  final SectionModel section;
  final Map<String, FormRunFieldValue> fieldValues;
  final Map<String, List<String>> dropdownOptionsOverride;
  final Map<String, String> computedValues;
  final void Function(String itemId, String value) onValueChanged;
  final void Function(String itemId) onButtonPressed;
  final void Function(String itemId, String value) onDropdownChanged;

  const FormRunSectionWidget({
    super.key,
    required this.section,
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

    final rowIndexes =
        section.items.map((item) => item.rowIndex).toSet().toList()..sort();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors?.sectionCardBackground ?? const Color(0xFF262B38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors?.sectionCardBorder ?? const Color(0xFF3A3F4E),
        ),
        boxShadow: [
          BoxShadow(
            color: colors?.sectionCardShadow ?? Colors.black26,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors?.headerAccentBackground ?? const Color(0xFF2A3040),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors?.headerAccentForeground ??
                              Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (section.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          section.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors?.faintText ?? Colors.white54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: section.items.isEmpty
                ? Text(
                    '此 Section 無欄位',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors?.faintText ?? Colors.white38,
                    ),
                  )
                : Column(
                    children: rowIndexes.map((rowIndex) {
                      final rowItems = section.items
                          .where((item) => item.rowIndex == rowIndex)
                          .toList();
                      final totalFlex = rowItems.fold<int>(
                        0,
                        (sum, item) =>
                            sum + (item.widthPercentage * 100).round(),
                      );
                      final remaining = 100 - totalFlex;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...rowItems.map((item) {
                                return Expanded(
                                  flex: (item.widthPercentage * 100).round(),
                                  child: _buildItemWidget(context, item),
                                );
                              }),
                              if (remaining > 0)
                                Expanded(
                                  flex: remaining,
                                  child: const SizedBox(),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(BuildContext context, DesignerItem item) {
    final fv = fieldValues[item.id];
    final currentValue = fv?.value ?? '';
    final options = dropdownOptionsOverride[item.id];

    return FormRunWidgetFactory.buildInteractiveWidget(
      context: context,
      item: item,
      currentValue: currentValue,
      dropdownOptionsOverride: options,
      computedValues: computedValues,
      onValueChanged: (v) => onValueChanged(item.id, v),
      onButtonPressed: () => onButtonPressed(item.id),
    );
  }
}
