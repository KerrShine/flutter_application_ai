import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title:
            Text(section.name, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(
          '${section.items.length} 個元件',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Wrap(
          spacing: 4,
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
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: '刪除 Section',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
