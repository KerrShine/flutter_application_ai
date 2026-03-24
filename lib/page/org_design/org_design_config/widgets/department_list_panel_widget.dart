import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';

class DepartmentListPanelWidget extends StatelessWidget {
  final String orgName;
  final List<OrgDepartmentNode> departmentNodes;
  final String selectedDepartmentId;
  final bool useInnerScroll;
  final ValueChanged<String> onSelectDepartmentNode;

  const DepartmentListPanelWidget({
    super.key,
    required this.orgName,
    required this.departmentNodes,
    required this.selectedDepartmentId,
    this.useInnerScroll = false,
    required this.onSelectDepartmentNode,
  });

  @override
  Widget build(BuildContext context) {
    final flatNodes = List<OrgDepartmentNode>.from(departmentNodes)
      ..sort((left, right) {
        final codeCompare = left.departmentCode.compareTo(right.departmentCode);
        if (codeCompare != 0) {
          return codeCompare;
        }
        return left.name.compareTo(right.name);
      });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '部門節點清單',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              orgName.isEmpty ? '組織設定' : orgName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (flatNodes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('目前尚未建立任何部門節點'),
              )
            else if (useInnerScroll)
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.separated(
                    itemCount: flatNodes.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final node = flatNodes[index];
                      final isSelected =
                          node.departmentId == selectedDepartmentId;
                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        onTap: () => onSelectDepartmentNode(node.departmentId),
                        leading: const Icon(Icons.business_outlined),
                        title: Text(node.name),
                        subtitle: Text(
                          '代碼: ${node.departmentCode.isEmpty ? '-' : node.departmentCode}',
                        ),
                        trailing: Text(node.isActive ? '啟用' : '停用'),
                      );
                    },
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: flatNodes.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final node = flatNodes[index];
                  final isSelected = node.departmentId == selectedDepartmentId;
                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    onTap: () => onSelectDepartmentNode(node.departmentId),
                    leading: const Icon(Icons.business_outlined),
                    title: Text(node.name),
                    subtitle: Text(
                      '代碼: ${node.departmentCode.isEmpty ? '-' : node.departmentCode}',
                    ),
                    trailing: Text(node.isActive ? '啟用' : '停用'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
