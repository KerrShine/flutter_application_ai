import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class EditorRoleSectionWidget extends StatelessWidget {
  final List<EmpRoleModel> roles;
  final List<String> selectedRoleIds;
  final void Function(String roleId) onToggleRole;
  final VoidCallback onClearAll;

  const EditorRoleSectionWidget({
    super.key,
    required this.roles,
    required this.selectedRoleIds,
    required this.onToggleRole,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final activeRoles = roles.where((r) => r.isActive).toList();

    return Container(
      decoration: BoxDecoration(
        color: colors.sectionPanelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.headerAccentBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.sectionIconBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    color: colors.sectionIconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '允許角色',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '未選擇任何角色時，代表「不限角色」皆可發起',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtleText,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedRoleIds.isNotEmpty)
                  TextButton(
                    onPressed: onClearAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 17),
                    ),
                    child: const Text('清除選擇'),
                  ),
              ],
            ),
          ),

          // ListView
          if (activeRoles.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '目前沒有可用的角色',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.faintText,
                    fontSize: 17,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: activeRoles.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.panelBorder,
              ),
              itemBuilder: (context, index) {
                final role = activeRoles[index];
                final selected = selectedRoleIds.contains(role.roleId);
                return CheckboxListTile(
                  value: selected,
                  onChanged: (_) => onToggleRole(role.roleId),
                  title: Text(
                    role.roleName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 19,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
