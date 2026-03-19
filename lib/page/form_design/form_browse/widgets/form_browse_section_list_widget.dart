import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_event.dart';

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
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 全部瀏覽
          Container(
            color: selectedSectionId == null
                ? Colors.blue.shade100
                : Colors.transparent,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                '全部瀏覽',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              selected: selectedSectionId == null,
              onTap: () {
                context.read<FormBrowseBloc>().add(
                      const SelectSectionEvent(sectionId: null),
                    );
              },
            ),
          ),
          const Divider(height: 1),
          // Section 清單
          Expanded(
            child: ListView.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Container(
                  color: selectedSectionId == section.id
                      ? Colors.blue.shade50
                      : Colors.transparent,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: Text(
                      section.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    selected: selectedSectionId == section.id,
                    onTap: () {
                      context.read<FormBrowseBloc>().add(
                            SelectSectionEvent(sectionId: section.id),
                          );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
