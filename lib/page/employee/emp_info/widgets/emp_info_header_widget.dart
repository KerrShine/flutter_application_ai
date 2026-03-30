import 'package:flutter/material.dart';

class EmpInfoHeaderWidget extends StatelessWidget {
  final VoidCallback onCreateEmployee;

  const EmpInfoHeaderWidget({
    super.key,
    required this.onCreateEmployee,
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
                '職員設定 / 職員資料',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF616161),
                      letterSpacing: 0.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '職員資料管理',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF111111),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: onCreateEmployee,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF111111),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('新增職員'),
        ),
      ],
    );
  }
}
