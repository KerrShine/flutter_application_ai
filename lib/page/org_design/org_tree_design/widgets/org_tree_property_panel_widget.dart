import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/page/org_design/org_tree_design/widgets/units/property_item_widget.dart';
import 'package:flutter_application_ai/theme/org_tree_design_theme_colors.dart';

class OrgTreePropertyPanelWidget extends StatelessWidget {
  final OrgDepartmentNode? department;
  final bool isOnCanvas;
  final String draftParentDepartmentId;
  final List<OrgDepartmentNode> parentDepartments;
  final Map<String, String> departmentNameMap;
  final ValueChanged<String?> onParentChanged;
  final VoidCallback onApplyParentDepartment;
  final VoidCallback onRemoveCanvasNode;

  const OrgTreePropertyPanelWidget({
    super.key,
    required this.department,
    required this.isOnCanvas,
    required this.draftParentDepartmentId,
    required this.parentDepartments,
    required this.departmentNameMap,
    required this.onParentChanged,
    required this.onApplyParentDepartment,
    required this.onRemoveCanvasNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<OrgTreeDesignThemeColors>()!;
    final availableParentIds = {
      '',
      ...parentDepartments.map((item) => item.departmentId),
    };
    final dropdownValue = availableParentIds.contains(draftParentDepartmentId)
        ? draftParentDepartmentId
        : '';
    final currentParentName = department == null
        ? '未設定'
        : department!.parentDepartmentId.isEmpty
            ? '未設定'
            : departmentNameMap[department!.parentDepartmentId] ??
                department!.parentDepartmentId;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      height: 1.5,
    );
    final helperStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 15,
      height: 1.5,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.panelBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.headerBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.panelBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.tune, color: colors.headerForeground),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Node 屬性',
                          style: titleStyle?.copyWith(
                            color: colors.headerForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '選取節點後可設定上層部門或移除。',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.subtleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (department == null)
              Expanded(
                child: Center(
                  child: Text(
                    '尚未選取任何組織節點',
                    style: bodyStyle,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    PropertyItemWidget(
                      label: '部門名稱',
                      value: department!.name,
                      labelStyle: helperStyle?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      valueStyle: bodyStyle?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    PropertyItemWidget(
                      label: '部門代碼',
                      value: department!.departmentCode.isEmpty
                          ? '-'
                          : department!.departmentCode,
                      labelStyle: helperStyle,
                      valueStyle: bodyStyle,
                    ),
                    PropertyItemWidget(
                      label: '啟用狀態',
                      value: department!.isActive ? '啟用' : '停用',
                      labelStyle: helperStyle,
                      valueStyle: bodyStyle,
                    ),
                    PropertyItemWidget(
                      label: '上級部門',
                      value: currentParentName,
                      labelStyle: helperStyle,
                      valueStyle: bodyStyle,
                    ),
                    const SizedBox(height: 12),
                    if (!isOnCanvas)
                      Text(
                        '請先將此部門拖曳到畫布後，再設定上層部門。',
                        style: helperStyle,
                      )
                    else ...[
                      DropdownButtonFormField<String>(
                        value: dropdownValue,
                        style: bodyStyle,
                        decoration: InputDecoration(
                          labelText: '設定上層部門',
                          labelStyle: helperStyle?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text(
                              '無上層部門',
                              style: bodyStyle,
                            ),
                          ),
                          ...parentDepartments.map(
                            (item) => DropdownMenuItem<String>(
                              value: item.departmentId,
                              child: Text(item.name, style: bodyStyle),
                            ),
                          ),
                        ],
                        onChanged: onParentChanged,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onApplyParentDepartment,
                          child: Text(
                            '套用上層部門',
                            style: bodyStyle?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onRemoveCanvasNode,
                          icon: const Icon(Icons.delete_outline),
                          label: Text('刪除節點與子節點', style: bodyStyle),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
