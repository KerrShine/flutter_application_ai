import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/service/form_launch_permission_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class EditorSummarySidebarWidget extends StatelessWidget {
  final String selectedFormName;
  final List<String> allowedRoleIds;
  final List<EmpRoleModel> roles;
  final List<String> allowedDepartmentIds;
  final List<OrgDepartmentNode> departments;
  final List<EligibleEmployeeInfo> eligibleEmployees;
  final VoidCallback onPreviewEmployees;

  const EditorSummarySidebarWidget({
    super.key,
    required this.selectedFormName,
    required this.allowedRoleIds,
    required this.roles,
    required this.allowedDepartmentIds,
    required this.departments,
    required this.eligibleEmployees,
    required this.onPreviewEmployees,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    final selectedRoleNames = allowedRoleIds
        .map((id) {
          final role = roles.where((r) => r.roleId == id).firstOrNull;
          return role?.roleName ?? id;
        })
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: colors.infoPanelBackground,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
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
                    Icons.summarize_outlined,
                    color: colors.sectionIconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '設定摘要',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.headerAccentForeground,
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 表單
                _buildStatCard(
                  context,
                  colors: colors,
                  label: '表單',
                  value: selectedFormName.isNotEmpty
                      ? selectedFormName
                      : '尚未選擇',
                ),
                const SizedBox(height: 10),

                // 角色
                _buildStatCard(
                  context,
                  colors: colors,
                  label: '允許角色',
                  value: allowedRoleIds.isEmpty
                      ? '不限角色'
                      : '${allowedRoleIds.length} 個角色',
                  detail: allowedRoleIds.isEmpty
                      ? '所有角色皆可發起'
                      : selectedRoleNames.join('、'),
                ),
                const SizedBox(height: 10),

                // 部門
                _buildStatCard(
                  context,
                  colors: colors,
                  label: '允許部門',
                  value: allowedDepartmentIds.isEmpty
                      ? '尚未選擇'
                      : '${allowedDepartmentIds.length} 個部門',
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colors.panelBorder),

          // 符合人員
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '符合人員',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.subtleText,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '${eligibleEmployees.length}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onPreviewEmployees,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('查看名單 →'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required FormDesignThemeColors colors,
    required String label,
    required String value,
    String? detail,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.statsCardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.statsCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.subtleText,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 19,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.faintText,
                fontSize: 17,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
