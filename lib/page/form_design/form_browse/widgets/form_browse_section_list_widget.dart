import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_event.dart';
import 'package:flutter_application_ai/theme/form_browse_theme_colors.dart';

class FormBrowseSectionListWidget extends StatelessWidget {
  final List<SectionModel> sections;
  final String? selectedSectionId;

  const FormBrowseSectionListWidget({
    super.key,
    required this.sections,
    this.selectedSectionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormBrowseThemeColors>()!;

    return SizedBox(
      width: 240,
      child: Container(
        decoration: BoxDecoration(
          color: colors.panelBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.panelBorder),
          boxShadow: [
            BoxShadow(
              color: colors.panelShadow,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.headerBackground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.panelBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.view_list_outlined,
                          color: colors.headerForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Section 清單',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.headerForeground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.chipBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${sections.length}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.chipForeground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '切換單一 Section 或全部預覽。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subtleText,
                    ),
                  ),
                ],
              ),
            ),
            _SectionBrowseTile(
              title: '全部瀏覽',
              isSelected: selectedSectionId == null,
              onTap: () {
                context.read<FormBrowseBloc>().add(
                      const SelectSectionEvent(sectionId: null),
                    );
              },
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return _SectionBrowseTile(
                    title: section.name,
                    isSelected: selectedSectionId == section.id,
                    onTap: () {
                      context.read<FormBrowseBloc>().add(
                            SelectSectionEvent(sectionId: section.id),
                          );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBrowseTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectionBrowseTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormBrowseThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Material(
        color: isSelected ? colors.listSelectedBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
