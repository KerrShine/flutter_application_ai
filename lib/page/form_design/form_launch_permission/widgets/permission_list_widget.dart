import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/theme/form_launch_permission_theme_colors.dart';

class PermissionListWidget extends StatelessWidget {
  final List<FormLaunchPermissionModel> permissions;
  final List<EmpRoleModel> roles;
  final List<OrgDepartmentNode> departments;
  final void Function(String permissionId) onEdit;
  final void Function(String permissionId) onDelete;

  const PermissionListWidget({
    super.key,
    required this.permissions,
    required this.roles,
    required this.departments,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormLaunchPermissionThemeColors>()!;

    if (permissions.isEmpty) {
      return Center(
        child: Text(
          '尚未設定任何發起權限\n請點擊「新增權限」開始設定',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: themeColors.emptyText),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: permissions.map((perm) {
          final roleNames = perm.allowedRoleIds.isEmpty
              ? '不限'
              : perm.allowedRoleIds
                  .map((id) {
                    final role = roles.firstWhere(
                      (r) => r.roleId == id,
                      orElse: () => const EmpRoleModel(),
                    );
                    return role.roleName.isNotEmpty ? role.roleName : id;
                  })
                  .join(', ');

          final deptNames = perm.allowedDepartmentIds.isEmpty
              ? '不限'
              : perm.allowedDepartmentIds
                  .map((id) {
                    final dept = departments.firstWhere(
                      (d) => d.departmentId == id,
                      orElse: () => const OrgDepartmentNode(
                        departmentId: '',
                        name: '',
                      ),
                    );
                    return dept.name.isNotEmpty ? dept.name : id;
                  })
                  .join(', ');

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Icon(
                perm.isActive ? Icons.check_circle : Icons.cancel,
                color: perm.isActive
                    ? themeColors.activeIcon
                    : themeColors.inactiveIcon,
                size: 28,
              ),
              title: Text(
                perm.formName.isNotEmpty ? perm.formName : perm.formId,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxChipWidth = constraints.maxWidth;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(Icons.people, '角色: $roleNames',
                            themeColors, maxChipWidth),
                        _buildInfoChip(Icons.business, '部門: $deptNames',
                            themeColors, maxChipWidth),
                        if (perm.requireManagerRole)
                          _buildInfoChip(
                              Icons.star, '僅主管', themeColors, maxChipWidth),
                        if (perm.requireActiveStatus)
                          _buildInfoChip(Icons.verified_user, '須在職',
                              themeColors, maxChipWidth),
                      ],
                    );
                  },
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: '編輯',
                    onPressed: () => onEdit(perm.permissionId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '刪除',
                    color: themeColors.deleteButton,
                    onPressed: () => onDelete(perm.permissionId),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    FormLaunchPermissionThemeColors themeColors,
    double maxWidth,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 14, color: themeColors.chipIcon),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: themeColors.chipText),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
