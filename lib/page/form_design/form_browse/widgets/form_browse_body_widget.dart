import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_event.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_state.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/form_browse_property_panel_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/form_browse_section_list_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/section_preview_widget.dart';
import 'package:flutter_application_ai/theme/form_browse_preview_theme.dart';
import 'package:flutter_application_ai/theme/form_browse_theme_colors.dart';

class FormBrowseBodyWidget extends StatelessWidget {
  final FormBrowseState state;

  const FormBrowseBodyWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormBrowseThemeColors>()!;

    if (state.status == FormBrowseStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == FormBrowseStatus.failure) {
      return Center(
        child: Text(
          state.message,
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.mutedText),
        ),
      );
    }
    if (state.sections.isEmpty) {
      return Center(
        child: Text(
          '目前沒有可瀏覽的 Section',
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.mutedText),
        ),
      );
    }

    // 根據 selectedSectionId 決定要顯示的 sections
    final displayedSections = state.selectedSectionId == null
        ? state.sections
        : state.sections.where((s) => s.id == state.selectedSectionId).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBrowseSectionListWidget(
          sections: state.sections,
          selectedSectionId: state.selectedSectionId,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.previewFrameBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.previewFrameBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.previewFrameShadow,
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Theme(
              data: FormBrowsePreviewTheme.resolve(theme),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: displayedSections.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '沒有可顯示的內容',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: displayedSections.indexed.map((entry) {
                          final index = entry.$1;
                          final section = entry.$2;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == displayedSections.length - 1
                                  ? 0
                                  : 18,
                            ),
                            child: SectionPreviewWidget(
                              section: section,
                              selectedFieldKey: state.selectedFieldKey,
                              onFieldTap: (sectionId, itemId) {
                                context.read<FormBrowseBloc>().add(
                                      SelectFieldEvent(
                                        sectionId: sectionId,
                                        itemId: itemId,
                                      ),
                                    );
                              },
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 360,
          child: FormBrowsePropertyPanelWidget(
            sections: displayedSections,
            selectedFieldKey: state.selectedFieldKey,
            expandedFieldKey: state.expandedFieldKey,
          ),
        ),
      ],
    );
  }
}
