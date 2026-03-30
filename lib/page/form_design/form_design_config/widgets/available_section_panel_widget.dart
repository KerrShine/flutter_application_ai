import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/bloc/form_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/widgets/section_card_widget.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class AvailableSectionPanelWidget extends StatelessWidget {
  final FormDesignState state;
  final ValueChanged<SectionModel> onAddSection;
  final ValueChanged<SectionModel> onEditSection;
  final VoidCallback onCreateSection;
  final ValueChanged<SectionModel> onDeleteSection;

  const AvailableSectionPanelWidget({
    super.key,
    required this.state,
    required this.onAddSection,
    required this.onEditSection,
    required this.onCreateSection,
    required this.onDeleteSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: colors.sectionPanelBackground,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.headerAccentBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.sectionIconBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.view_sidebar_outlined,
                    color: colors.sectionIconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '可用 Section',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '維護與加入可重複使用的區塊',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeaderCountChip(
                  text: '${state.availableSections.length}',
                  backgroundColor: colors.headerChipBackground,
                  foregroundColor: colors.headerChipText,
                ),
              ],
            ),
          ),
          Expanded(
            child: state.availableSections.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.emptyStateBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.emptyStateBorder),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colors.emptyStateIconBackground,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.layers_outlined,
                                size: 28,
                                color: colors.emptyStateIconColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '尚無 Section',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '先建立一個區塊，再加入到表單畫布。',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.faintText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.availableSections.length,
                    itemBuilder: (context, index) {
                      final section = state.availableSections[index];
                      return SectionCardWidget(
                        section: section,
                        onAdd: () => onAddSection(section),
                        onEdit: () => onEditSection(section),
                        onDelete: () => onDeleteSection(section),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCreateSection,
                icon: const Icon(Icons.add),
                label: const Text('新建 Section'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCountChip extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  const _HeaderCountChip({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
