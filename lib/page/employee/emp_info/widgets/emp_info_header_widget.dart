import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/emp_info_theme_colors.dart';

class EmpInfoHeaderWidget extends StatelessWidget {
  final VoidCallback onCreateEmployee;
  final VoidCallback onExportJson;

  const EmpInfoHeaderWidget({
    super.key,
    required this.onCreateEmployee,
    required this.onExportJson,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EmpInfoThemeColors>()!;

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
                      color: colors.breadcrumbText,
                      letterSpacing: 0.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '職員資料管理',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.headlineText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: onExportJson,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.actionColor,
            side: BorderSide(color: colors.actionColor.withValues(alpha: 0.5)),
          ),
          icon: Icon(Icons.data_object_outlined, color: colors.actionColor),
          label: Text(
            '匯出Json',
            style: TextStyle(color: colors.actionColor),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onCreateEmployee,
          style: FilledButton.styleFrom(
            backgroundColor: colors.actionColor,
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
