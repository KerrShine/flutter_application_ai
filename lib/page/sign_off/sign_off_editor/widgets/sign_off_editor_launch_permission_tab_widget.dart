import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffEditorLaunchPermissionTabWidget extends StatelessWidget {
  final FormLaunchPermissionModel? permission;
  final List<OrgDepartmentNode> departments;
  final String formName;

  const SignOffEditorLaunchPermissionTabWidget({
    super.key,
    required this.permission,
    required this.departments,
    required this.formName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    if (permission == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.emptyStateIconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 40,
                  color: colors.emptyStateIconColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                formName.isEmpty ? '請先選擇表單' : '此表單尚未設定發起權限',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize:
                      (theme.textTheme.titleMedium?.fontSize ?? 16) + 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '請至「表單管理 → 表單權限設定」建立發起權限後再回來。',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                  color: colors.subtleText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final p = permission!;
    final deptNames = departments
        .where((d) => p.allowedDepartmentIds.contains(d.departmentId))
        .map((d) => d.name)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.sectionCardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.sectionCardBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.sectionCardShadow,
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.sectionIconBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: colors.sectionIconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '發起資格設定（引用既有權限）',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize:
                              (theme.textTheme.titleMedium?.fontSize ?? 16) + 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _row(theme, colors, '對應表單', formName.isEmpty ? '-' : formName),
                  _row(
                    theme,
                    colors,
                    '允許角色',
                    p.allowedRoleIds.isEmpty
                        ? '不限'
                        : '${p.allowedRoleIds.length} 個角色',
                  ),
                  _row(
                    theme,
                    colors,
                    '允許部門',
                    deptNames.isEmpty ? '不限' : deptNames.join('、'),
                  ),
                  _row(theme, colors, '須在職', p.requireActiveStatus ? '是' : '否'),
                  _row(theme, colors, '僅限主管', p.requireManagerRole ? '是' : '否'),
                  _row(theme, colors, '啟用狀態', p.isActive ? '啟用中' : '已停用'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.infoRowBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.infoRowBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 20, color: colors.actionInfo),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '此處為唯讀展示。如需調整發起權限，請至「表單管理 → 表單權限設定」修改。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize:
                          (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                      color: colors.subtleText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    ThemeData theme,
    FormDesignThemeColors colors,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
                color: colors.subtleText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
