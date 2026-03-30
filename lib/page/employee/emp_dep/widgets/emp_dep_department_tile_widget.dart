import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';

class EmpDepDepartmentTileWidget extends StatelessWidget {
  final OrgDepartmentNode department;
  final int employeeCount;
  final bool isSelected;
  final VoidCallback onTap;

  const EmpDepDepartmentTileWidget({
    super.key,
    required this.department,
    required this.employeeCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? const Color(0xFF111111) : const Color(0xFFE0E0E0);
    final backgroundColor = isSelected ? const Color(0xFFF3F3F3) : Colors.white;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.departmentCode.isEmpty
                      ? department.name
                      : '${department.departmentCode} - ${department.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '既有員工 $employeeCount 人',
                  style: const TextStyle(
                    color: Color(0xFF616161),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
