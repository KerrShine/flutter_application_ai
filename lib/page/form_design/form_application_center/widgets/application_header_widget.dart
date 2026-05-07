import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/theme/form_application_center_theme_colors.dart';

class ApplicationHeaderWidget extends StatelessWidget {
  final EmployeeModel currentEmployee;
  final VoidCallback onExportJson;

  const ApplicationHeaderWidget({
    super.key,
    required this.currentEmployee,
    required this.onExportJson,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormApplicationCenterThemeColors>()!;

    return Row(
      children: [
        const Icon(Icons.assignment, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '申請中心',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (currentEmployee.employeeName.isNotEmpty)
              Text(
                '${currentEmployee.employeeName} - ${currentEmployee.roleName}',
                style: TextStyle(fontSize: 14, color: themeColors.subtitleText),
              ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('匯出申請紀錄'),
          onPressed: onExportJson,
        ),
      ],
    );
  }
}
