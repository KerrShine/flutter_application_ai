import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_event.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_state.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/form_browse_property_panel_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/form_browse_section_list_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/section_preview_widget.dart';

class FormBrowseBodyWidget extends StatelessWidget {
  final FormBrowseState state;

  const FormBrowseBodyWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == FormBrowseStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == FormBrowseStatus.failure) {
      return Center(child: Text(state.message));
    }
    if (state.sections.isEmpty) {
      return const Center(child: Text('目前沒有可瀏覽的 Section'));
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
        const VerticalDivider(width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: displayedSections.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '沒有可顯示的內容',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: displayedSections.indexed.map((entry) {
                          final index = entry.$1;
                          final section = entry.$2;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == displayedSections.length - 1
                                  ? 0
                                  : 12,
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
        const VerticalDivider(width: 1),
        SizedBox(
          width: 360,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FormBrowsePropertyPanelWidget(
              sections: displayedSections,
              selectedFieldKey: state.selectedFieldKey,
              expandedFieldKey: state.expandedFieldKey,
            ),
          ),
        ),
      ],
    );
  }
}
