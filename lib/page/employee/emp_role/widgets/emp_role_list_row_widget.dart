import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/page/employee/emp_role/widgets/emp_role_status_chip_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_role/widgets/emp_role_type_chip_widget.dart';

class EmpRoleListRowWidget extends StatelessWidget {
  final EmpRoleModel role;
  final VoidCallback onEdit;

  const EmpRoleListRowWidget({
    super.key,
    required this.role,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Color(0xFF111111), fontSize: 14);
    const secondaryStyle = TextStyle(color: Color(0xFF616161), fontSize: 13);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.roleName,
                  style: textStyle.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(role.roleCode, style: secondaryStyle),
                const SizedBox(height: 12),
                Row(
                  children: [
                    EmpRoleTypeChipWidget(
                      isManagerLevel: role.isManagerLevel,
                    ),
                    const SizedBox(width: 12),
                    EmpRoleStatusChipWidget(isActive: role.isActive),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111111),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFBDBDBD)),
                      ),
                      child: const Text('編輯'),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  role.roleName,
                  style: textStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(role.roleCode, style: secondaryStyle),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: EmpRoleTypeChipWidget(
                    isManagerLevel: role.isManagerLevel,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: EmpRoleStatusChipWidget(isActive: role.isActive),
                ),
              ),
              SizedBox(
                width: 92,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111111),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    child: const Text('編輯'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
