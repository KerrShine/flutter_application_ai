import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/condition_compute_function.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 已定義條件欄位卡片 — 顯示 fieldKey / label / type / 計算公式摘要 + 編輯/刪除。
class ConditionFieldDefinitionCard extends StatelessWidget {
  final ConditionFieldDefinition definition;
  final List<ConditionArgItemChoice> availableItems;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ConditionFieldDefinitionCard({
    super.key,
    required this.definition,
    required this.availableItems,
    required this.onEdit,
    required this.onRemove,
  });

  String _argSummary() {
    final names = definition.argDesignerItemIds.map((id) {
      final item = availableItems.cast<ConditionArgItemChoice?>().firstWhere(
            (c) => c?.itemId == id,
            orElse: () => null,
          );
      return item?.label ?? '⚠ 找不到 ($id)';
    }).join(', ');
    return '${definition.function.label}($names)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.sectionCardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.sectionCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      definition.fieldKey,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.statsCardBackground,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colors.statsCardBorder),
                      ),
                      child: Text(
                        definition.outputType.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.subtleText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('顯示：${definition.label}',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  '計算：${_argSummary()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtleText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '編輯',
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: '移除',
            icon: Icon(Icons.close,
                size: 18, color: theme.colorScheme.error),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
