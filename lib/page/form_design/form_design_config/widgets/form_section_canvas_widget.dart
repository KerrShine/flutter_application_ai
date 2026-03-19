import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/bloc/form_design_bloc.dart';

class FormSectionCanvasWidget extends StatelessWidget {
  final FormDesignState state;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onRemoveSection;
  final ValueChanged<SectionModel> onBrowseSection;

  const FormSectionCanvasWidget({
    super.key,
    required this.state,
    required this.onReorder,
    required this.onRemoveSection,
    required this.onBrowseSection,
  });

  @override
  Widget build(BuildContext context) {
    if (state.selectedSections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              '從左側將 Section 加入表單',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '表單結構（共 ${state.selectedSections.length} 個 Section）',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: state.selectedSections.length,
            onReorder: onReorder,
            itemBuilder: (context, index) {
              final section = state.selectedSections[index];
              return _SectionCanvasCardWidget(
                key: ValueKey(section.id),
                section: section,
                onRemove: () => onRemoveSection(section.id),
                onBrowse: () => onBrowseSection(section),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionCanvasCardWidget extends StatelessWidget {
  final SectionModel section;
  final VoidCallback onRemove;
  final VoidCallback onBrowse;

  const _SectionCanvasCardWidget({
    super.key,
    required this.section,
    required this.onRemove,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.drag_indicator),
        title: Text(section.name),
        subtitle: Text('${section.items.length} 個元件'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              tooltip: '瀏覽 Section',
              onPressed: onBrowse,
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Theme.of(context).colorScheme.error,
              tooltip: '移除 Section',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
