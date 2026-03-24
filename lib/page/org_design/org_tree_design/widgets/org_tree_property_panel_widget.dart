import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';

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
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.5,
        );
    final helperStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.5,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Node 屬性',
              style: titleStyle,
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
                    _PropertyItem(
                      label: '部門名稱',
                      value: department!.name,
                      labelStyle: helperStyle?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      valueStyle: bodyStyle?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _PropertyItem(
                      label: '部門代碼',
                      value: department!.departmentCode.isEmpty
                          ? '-'
                          : department!.departmentCode,
                      labelStyle: helperStyle,
                      valueStyle: bodyStyle,
                    ),
                    _PropertyItem(
                      label: '啟用狀態',
                      value: department!.isActive ? '啟用' : '停用',
                      labelStyle: helperStyle,
                      valueStyle: bodyStyle,
                    ),
                    _PropertyItem(
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
                          border: const OutlineInputBorder(),
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

class _PropertyItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _PropertyItem({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: (labelStyle ?? Theme.of(context).textTheme.labelLarge)
                ?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:
                (valueStyle ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
