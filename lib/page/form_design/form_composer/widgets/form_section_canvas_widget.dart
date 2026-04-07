import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_composer/bloc/form_design_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormSectionCanvasWidget extends StatelessWidget {
  final FormDesignState state;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onRemoveSection;

  const FormSectionCanvasWidget({
    super.key,
    required this.state,
    required this.onReorder,
    required this.onRemoveSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    if (state.selectedSections.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: colors.canvasPanelBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.panelBorder),
          boxShadow: [
            BoxShadow(
              color: colors.panelShadow,
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: colors.emptyStateBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.emptyStateBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: colors.emptyStateIconBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.inbox_outlined,
                    size: 32,
                    color: colors.emptyStateIconColor,
                  ),
                ),
                const SizedBox(height: 14),
                Text('從左側將 Section 加入表單', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  '建立內容區塊後，可以在這裡調整顯示順序並預覽每個 Section。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.faintText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.canvasPanelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: colors.headerAccentBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.headerChipBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.account_tree_outlined,
                    color: colors.headerChipText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '表單結構',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '拖曳調整排序，並隨時移除或預覽指定 Section。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.headerChipBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${state.selectedSections.length} 個 Section',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.headerChipText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              itemCount: state.selectedSections.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final section = state.selectedSections[index];
                return _SectionCanvasCardWidget(
                  key: ValueKey(section.id),
                  section: section,
                  orderLabel: '${index + 1}'.padLeft(2, '0'),
                  onRemove: () => onRemoveSection(section.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCanvasCardWidget extends StatelessWidget {
  final SectionModel section;
  final String orderLabel;
  final VoidCallback onRemove;

  const _SectionCanvasCardWidget({
    super.key,
    required this.section,
    required this.orderLabel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.canvasCardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.canvasCardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.canvasCardShadow,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.headerChipBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    orderLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.headerChipText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: colors.headerChipText,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    section.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (section.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      section.description.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.subtleText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: '移除 Section',
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
