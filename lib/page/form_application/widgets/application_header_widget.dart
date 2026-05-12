import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';

/// 申請相關頁面共用 header — 顯示頁面標題、當前員工、可選右側 actions。
///
/// 三個申請頁（新增申請 / 我的申請 / 待我簽核）皆使用此 widget；
/// 各頁透過 [title] 自訂標題，透過 [actions] 注入右側按鈕（如匯出 JSON）。
class ApplicationHeaderWidget extends StatelessWidget {
  final String title;
  final EmployeeModel currentEmployee;
  final List<Widget> actions;

  const ApplicationHeaderWidget({
    super.key,
    required this.title,
    required this.currentEmployee,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;

    return Row(
      children: [
        const Icon(Icons.assignment, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (currentEmployee.employeeName.isNotEmpty)
              Text(
                '${currentEmployee.employeeName} - ${currentEmployee.roleName}',
                style: TextStyle(fontSize: 14, color: themeColors.subtitleText),
              ),
          ],
        ),
        const Spacer(),
        ...actions,
      ],
    );
  }
}
