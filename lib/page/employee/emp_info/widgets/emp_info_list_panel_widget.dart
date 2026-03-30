import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/page/employee/emp_info/widgets/emp_info_list_row_widget.dart';

class EmpInfoListPanelWidget extends StatelessWidget {
  final List<EmployeeModel> employees;
  final List<OrgDepartmentNode> departments;
  final ValueChanged<EmployeeModel> onEditEmployee;
  final ValueChanged<EmployeeModel> onDeleteEmployee;
  final ValueChanged<EmployeeModel> onOpenDepartmentBinding;

  const EmpInfoListPanelWidget({
    super.key,
    required this.employees,
    required this.departments,
    required this.onEditEmployee,
    required this.onDeleteEmployee,
    required this.onOpenDepartmentBinding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 840;
              if (isCompact) {
                return const SizedBox.shrink();
              }

              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '工號',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '姓名',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '職位',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '部門名稱',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '狀態',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 188,
                      child: SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
          if (employees.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                '尚未有職員資料，請前往新增職員',
                style: TextStyle(color: Color(0xFF424242)),
              ),
            )
          else
            ...employees.map(
              (employee) => EmpInfoListRowWidget(
                employee: employee,
                departmentName: _resolveDepartmentName(employee.departmentId),
                roleName: _resolveRoleName(employee),
                onEdit: () => onEditEmployee(employee),
                onDelete: () => onDeleteEmployee(employee),
                onTap: () => onOpenDepartmentBinding(employee),
              ),
            ),
        ],
      ),
    );
  }

  String _resolveRoleName(EmployeeModel employee) {
    return employee.roleName.isEmpty ? '未指定角色' : employee.roleName;
  }

  String _resolveDepartmentName(String departmentId) {
    final department = departments.cast<OrgDepartmentNode?>().firstWhere(
          (item) => item?.departmentId == departmentId,
          orElse: () => null,
        );

    if (department == null) {
      return departmentId.isEmpty ? '待指定' : departmentId;
    }

    if (department.departmentCode.isEmpty) {
      return department.name;
    }

    return '${department.departmentCode} - ${department.name}';
  }
}
