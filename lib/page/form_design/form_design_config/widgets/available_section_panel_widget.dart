import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/bloc/form_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/widgets/section_card_widget.dart';

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
    return Container(
      width: 260,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '可用 Section',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.availableSections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.layers_outlined,
                          size: 40,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '尚無 Section',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCreateSection,
                icon: const Icon(Icons.add),
                label: const Text('新建 Section'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
