import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/theme/emp_agent_theme_colors.dart';

class EmpAgentEmployeeSummaryWidget extends StatelessWidget {
  final EmployeeModel employee;
  final String departmentDisplayName;

  const EmpAgentEmployeeSummaryWidget({
    super.key,
    required this.employee,
    required this.departmentDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;
    final employmentText = employee.employeeId.isEmpty
        ? '請先選擇員工'
        : '${employee.hireDate.isEmpty ? '未設定' : employee.hireDate} / '
            '${employee.leaveDate.isEmpty ? '在職中' : employee.leaveDate}';
    final roleName = employee.roleName.isEmpty ? '未指定角色' : employee.roleName;
    final isActive = employee.employeeId.isNotEmpty && employee.isActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColors.summaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: themeColors.summaryBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: themeColors.summaryAvatarBackground,
            child: Text(
              employee.employeeId.isEmpty
                  ? '?'
                  : employee.employeeName.characters.first,
              style: TextStyle(
                color: themeColors.summaryAvatarText,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.employeeId.isEmpty
                      ? '尚未選擇員工'
                      : employee.employeeName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: themeColors.inputText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  employee.employeeId.isEmpty
                      ? '請先完成上方選擇'
                      : '$roleName ｜ $departmentDisplayName',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeColors.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  employmentText,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeColors.subtleText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? themeColors.statusActiveBackground
                  : themeColors.statusInactiveBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? '在職' : '未選擇',
              style: TextStyle(
                color: isActive
                    ? themeColors.statusActiveText
                    : themeColors.statusInactiveText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
