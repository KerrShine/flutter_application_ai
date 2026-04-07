import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SectionCardWidget extends StatelessWidget {
  final SectionModel section;
  final VoidCallback onAdd;
  final VoidCallback onBrowse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SectionCardWidget({
    super.key,
    required this.section,
    required this.onAdd,
    required this.onBrowse,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      width: double.infinity,
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
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: SizedBox(
                    height: 42,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        section.name,
                        textAlign: TextAlign.left,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.sectionCardBorder),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.visibility_outlined),
                    tooltip: '瀏覽 Section',
                    onPressed: onBrowse,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: '編輯 Section',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: '加入表單',
                    onPressed: onAdd,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: '刪除 Section',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
