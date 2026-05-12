import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';
import 'package:flutter_application_ai/page/form_design/form_readonly/read_only_field_widget_factory.dart';

/// 單一 Section 的唯讀渲染元件 — 重用 form_run 的 rowIndex 分行 + widthPercentage
/// 寬度比例排版，但所有欄位走 [ReadOnlyFieldWidgetFactory] 渲染為唯讀。
class ReadOnlySectionWidget extends StatelessWidget {
  final SectionModel section;
  final Map<String, dynamic> fieldValues;
  final Map<String, String> computedValues;

  const ReadOnlySectionWidget({
    super.key,
    required this.section,
    required this.fieldValues,
    this.computedValues = const {},
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors?.headerAccentBackground ?? const Color(0xFF2A3040),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color:
                        colors?.headerAccentForeground ?? Colors.white,
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
                      // 唯讀模式下隱藏 button 欄位 — 不參與寬度分配
                      final visibleItems = rowItems
                          .where((item) => item.type != DesignerItemType.button)
                          .toList();
                      if (visibleItems.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final totalFlex = visibleItems.fold<int>(
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
                              ...visibleItems.map((item) {
                                return Expanded(
                                  flex:
                                      (item.widthPercentage * 100).round(),
                                  child: _buildItem(context, item),
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

  Widget _buildItem(BuildContext context, DesignerItem item) {
    final rawValue = fieldValues[item.id];
    final value = rawValue == null ? '' : rawValue.toString();
    return ReadOnlyFieldWidgetFactory.buildReadOnlyField(
      context: context,
      item: item,
      value: value,
      computedValues: computedValues,
    );
  }
}
