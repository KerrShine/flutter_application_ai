import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';

class OrgTreePropertyPanelWidget extends StatelessWidget {
  final OrgDepartmentNode? department;
  final bool isOnCanvas;
  final String draftParentDepartmentId;
  final List<OrgDepartmentNode> parentDepartments;
  final ValueChanged<String?> onParentChanged;
  final VoidCallback onApplyParentDepartment;
  final VoidCallback onRemoveCanvasNode;

  const OrgTreePropertyPanelWidget({
    super.key,
    required this.department,
    required this.isOnCanvas,
    required this.draftParentDepartmentId,
    required this.parentDepartments,
    required this.onParentChanged,
    required this.onApplyParentDepartment,
    required this.onRemoveCanvasNode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Node 屬性',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (department == null)
              const Expanded(
                child: Center(
                  child: Text('尚未選取任何組織節點'),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    _PropertyItem(label: '部門名稱', value: department!.name),
                    _PropertyItem(
                      label: '部門代碼',
                      value: department!.departmentCode.isEmpty
                          ? '-'
                          : department!.departmentCode,
                    ),
                    _PropertyItem(
                      label: '啟用狀態',
                      value: department!.isActive ? '啟用' : '停用',
                    ),
                    _PropertyItem(
                      label: '上級部門',
                      value: department!.parentDepartmentId.isEmpty
                          ? '未設定'
                          : department!.parentDepartmentId,
                    ),
                    const SizedBox(height: 12),
                    if (!isOnCanvas)
                      const Text('請先將此部門拖曳到畫布後，再設定上層部門。')
                    else ...[
                      DropdownButtonFormField<String>(
                        value: draftParentDepartmentId,
                        decoration: const InputDecoration(
                          labelText: '設定上層部門',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('無上層部門'),
                          ),
                          ...parentDepartments.map(
                            (item) => DropdownMenuItem<String>(
                              value: item.departmentId,
                              child: Text(item.name),
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
                          child: const Text('套用上層部門'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onRemoveCanvasNode,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('刪除節點與子節點'),
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

  const _PropertyItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
