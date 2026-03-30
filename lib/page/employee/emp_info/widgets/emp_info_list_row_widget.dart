import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/page/employee/emp_info/widgets/emp_info_status_chip_widget.dart';

class EmpInfoListRowWidget extends StatelessWidget {
  final EmployeeModel employee;
  final String departmentName;
  final String roleName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const EmpInfoListRowWidget({
    super.key,
    required this.employee,
    required this.departmentName,
    required this.roleName,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryStyle = TextStyle(color: Color(0xFF111111), fontSize: 14);
    const secondaryStyle = TextStyle(color: Color(0xFF616161), fontSize: 13);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 840;
              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.employeeName,
                      style: primaryStyle.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text('工號：${employee.employeeCode}', style: secondaryStyle),
                    const SizedBox(height: 4),
                    Text('職位：$roleName', style: secondaryStyle),
                    const SizedBox(height: 4),
                    Text('部門：$departmentName', style: secondaryStyle),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111111),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFBDBDBD)),
                      ),
                      child: const Text('編輯'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: onDelete,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('刪除'),
                    ),
                    const SizedBox(height: 12),
                    EmpInfoStatusChipWidget(isActive: employee.isActive),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      employee.employeeCode,
                      style: primaryStyle.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(employee.employeeName, style: primaryStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(roleName, style: secondaryStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(departmentName, style: secondaryStyle),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                          EmpInfoStatusChipWidget(isActive: employee.isActive),
                    ),
                  ),
                  SizedBox(
                    width: 188,
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF111111),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFBDBDBD)),
                          ),
                          child: const Text('編輯'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: onDelete,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('刪除'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
