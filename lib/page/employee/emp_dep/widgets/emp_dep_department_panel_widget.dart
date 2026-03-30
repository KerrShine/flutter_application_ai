import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/page/employee/emp_dep/widgets/emp_dep_department_tile_widget.dart';

class EmpDepDepartmentPanelWidget extends StatelessWidget {
  final List<OrgDepartmentNode> departments;
  final Map<String, int> departmentEmployeeCounts;
  final String selectedDepartmentId;
  final ValueChanged<String> onSelectDepartment;
  final bool scrollable;

  const EmpDepDepartmentPanelWidget({
    super.key,
    required this.departments,
    required this.departmentEmployeeCounts,
    required this.selectedDepartmentId,
    required this.onSelectDepartment,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '現有部門',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 12),
        if (departments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '目前沒有部門資料',
              style: TextStyle(color: Color(0xFF757575)),
            ),
          )
        else
          ...departments.map(
            (department) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EmpDepDepartmentTileWidget(
                department: department,
                employeeCount:
                    departmentEmployeeCounts[department.departmentId] ?? 0,
                isSelected: selectedDepartmentId == department.departmentId,
                onTap: () => onSelectDepartment(department.departmentId),
              ),
            ),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: scrollable ? SingleChildScrollView(child: content) : content,
    );
  }
}
