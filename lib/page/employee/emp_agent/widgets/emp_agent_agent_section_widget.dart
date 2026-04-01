import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/page/employee/emp_agent/widgets/emp_agent_employee_summary_widget.dart';
import 'package:flutter_application_ai/theme/emp_agent_theme_colors.dart';

class EmpAgentAgentSectionWidget extends StatelessWidget {
  final List<OrgDepartmentNode> departments;
  final String agentDepartmentId;
  final List<EmployeeModel> agentCandidates;
  final String agentEmployeeId;
  final EmployeeModel selectedAgentEmployee;
  final ValueChanged<String> onSelectDepartment;
  final ValueChanged<String> onSelectEmployee;
  final VoidCallback onSubmitAssignment;

  const EmpAgentAgentSectionWidget({
    super.key,
    required this.departments,
    required this.agentDepartmentId,
    required this.agentCandidates,
    required this.agentEmployeeId,
    required this.selectedAgentEmployee,
    required this.onSelectDepartment,
    required this.onSelectEmployee,
    required this.onSubmitAssignment,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2   選擇代理人',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: themeColors.stepTitle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: themeColors.divider,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: agentDepartmentId.isEmpty ? null : agentDepartmentId,
          dropdownColor: themeColors.dropdownBackground,
          style: TextStyle(color: themeColors.inputText),
          decoration: _inputDecoration(context, '代理人來源部門'),
          items: departments
              .map(
                (department) => DropdownMenuItem<String>(
                  value: department.departmentId,
                  child: Text(
                    department.departmentCode.isEmpty
                        ? department.name
                        : '${department.departmentCode} - ${department.name}',
                    style: TextStyle(color: themeColors.inputText),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onSelectDepartment(value);
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: agentEmployeeId.isEmpty ? null : agentEmployeeId,
          dropdownColor: themeColors.dropdownBackground,
          style: TextStyle(color: themeColors.inputText),
          decoration: _inputDecoration(context, '代理人*'),
          items: agentCandidates
              .map(
                (employee) => DropdownMenuItem<String>(
                  value: employee.employeeId,
                  child: Text(
                    _buildEmployeeLabel(employee),
                    style: TextStyle(color: themeColors.inputText),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            onSelectEmployee(value ?? '');
          },
        ),
        const SizedBox(height: 16),
        EmpAgentEmployeeSummaryWidget(
          employee: selectedAgentEmployee,
          departmentDisplayName: _resolveDepartmentName(
            departments: departments,
            departmentId: selectedAgentEmployee.departmentId,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onSubmitAssignment,
            style: FilledButton.styleFrom(
              backgroundColor: themeColors.primaryAction,
              foregroundColor: themeColors.inputText,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('新增代理設定'),
          ),
        ),
      ],
    );
  }

  String _buildEmployeeLabel(EmployeeModel employee) {
    final roleName = employee.roleName.isEmpty ? '未指定角色' : employee.roleName;
    return '${employee.employeeName}（$roleName）';
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: themeColors.dropdownLabel),
      filled: true,
      fillColor: themeColors.dropdownBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: themeColors.dropdownBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: themeColors.dropdownFocus),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String _resolveDepartmentName({
    required List<OrgDepartmentNode> departments,
    required String departmentId,
  }) {
    final matched =
        departments.where((item) => item.departmentId == departmentId);
    if (matched.isEmpty) {
      return '未指定部門';
    }

    final department = matched.first;
    return department.departmentCode.isEmpty
        ? department.name
        : '${department.departmentCode} ${department.name}';
  }
}
