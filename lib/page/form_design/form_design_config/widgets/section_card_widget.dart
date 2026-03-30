import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SectionCardWidget extends StatelessWidget {
  final SectionModel section;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SectionCardWidget({
    super.key,
    required this.section,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.sectionCardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.sectionCardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.sectionCardShadow,
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.sectionIconBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.widgets_outlined,
                color: colors.sectionIconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${section.items.length} 個元件',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subtleText,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 2,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: '編輯 Section',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: '加入表單',
                  onPressed: onAdd,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: '刪除 Section',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
