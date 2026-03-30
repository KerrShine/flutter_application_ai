import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/page/employee/emp_role/widgets/emp_role_list_row_widget.dart';

class EmpRoleListPanelWidget extends StatelessWidget {
  final List<EmpRoleModel> roles;
  final ValueChanged<EmpRoleModel> onEditRole;

  const EmpRoleListPanelWidget({
    super.key,
    required this.roles,
    required this.onEditRole,
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
              final isCompact = constraints.maxWidth < 760;
              if (isCompact) {
                return const SizedBox.shrink();
              }

              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        '角色名稱',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '職務代碼',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '類型',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '狀態',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 92),
                  ],
                ),
              );
            },
          ),
          if (roles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                '尚未有角色設定，請前往新增角色',
                style: TextStyle(color: Color(0xFF424242)),
              ),
            )
          else
            ...roles.map(
              (role) => EmpRoleListRowWidget(
                role: role,
                onEdit: () => onEditRole(role),
              ),
            ),
        ],
      ),
    );
  }
}
