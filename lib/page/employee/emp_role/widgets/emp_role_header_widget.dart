import 'package:flutter/material.dart';

class EmpRoleHeaderWidget extends StatelessWidget {
  final VoidCallback onExportJson;
  final VoidCallback onCreateRole;

  const EmpRoleHeaderWidget({
    super.key,
    required this.onExportJson,
    required this.onCreateRole,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '職員設定 / 建立組織角色',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF616161),
                      letterSpacing: 0.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '組織角色管理',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF111111),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: onExportJson,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111111),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFBDBDBD)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.data_object_outlined),
              label: const Text('匯出Json'),
            ),
            FilledButton.icon(
              onPressed: onCreateRole,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                elevation: 0,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFBDBDBD)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('新增角色'),
            ),
          ],
        ),
      ],
    );
  }
}
