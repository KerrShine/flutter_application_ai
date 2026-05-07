import 'package:flutter/material.dart';

class PermissionHeaderWidget extends StatelessWidget {
  final VoidCallback onExportJson;
  final VoidCallback onCreatePermission;

  const PermissionHeaderWidget({
    super.key,
    required this.onExportJson,
    required this.onCreatePermission,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.security, size: 28),
        const SizedBox(width: 12),
        const Text(
          '表單發起權限',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        OutlinedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('匯出 JSON'),
          onPressed: onExportJson,
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('新增權限'),
          onPressed: onCreatePermission,
        ),
      ],
    );
  }
}
