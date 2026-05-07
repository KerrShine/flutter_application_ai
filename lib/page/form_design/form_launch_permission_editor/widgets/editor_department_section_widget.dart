import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class EditorDepartmentSectionWidget extends StatelessWidget {
  final List<OrgDepartmentNode> departments;
  final List<String> selectedDepartmentIds;
  final void Function(String departmentId) onToggleDepartment;
  final void Function(String departmentId) onToggleDepartmentTree;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;

  const EditorDepartmentSectionWidget({
    super.key,
    required this.departments,
    required this.selectedDepartmentIds,
    required this.onToggleDepartment,
    required this.onToggleDepartmentTree,
    required this.onSelectAll,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    // Exclude top-level management (depthLevel 0) — 總管理部門預設有所有權限
    final selectableDepts = departments.where((d) => d.depthLevel > 0).toList();
    final totalCount = selectableDepts.length;
    final selectedCount = selectedDepartmentIds
        .where((id) => selectableDepts.any((d) => d.departmentId == id))
        .length;

    // Tree roots: depthLevel == 1 (事業群層級)
    final roots = selectableDepts
        .where((d) => d.depthLevel == 1)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

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
                    Icons.apartment_outlined,
                    color: colors.sectionIconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '允許部門',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '已選 $selectedCount / $totalCount',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtleText,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: onSelectAll,
                      style: _miniButtonStyle(),
                      child: const Text('全選'),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed:
                          selectedDepartmentIds.isNotEmpty ? onClearAll : null,
                      style: _miniButtonStyle(),
                      child: const Text('清除'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tree list
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: roots.isEmpty
                ? _buildEmptyState(context, colors)
                : Column(
                    children: [
                      for (final root in roots)
                        _DepartmentTreeNode(
                          node: root,
                          allDepartments: selectableDepts,
                          selectedDepartmentIds: selectedDepartmentIds,
                          onToggleSingle: onToggleDepartment,
                          onToggleTree: onToggleDepartmentTree,
                          depth: 0,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, FormDesignThemeColors colors) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.emptyStateBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.emptyStateBorder),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.emptyStateIconBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.apartment_outlined,
                  size: 24,
                  color: colors.emptyStateIconColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '目前沒有可用的部門',
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 4),
              Text(
                '尚無部門資料可供選擇。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.faintText,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _miniButtonStyle() {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const TextStyle(fontSize: 17),
    );
  }
}

/// A single node in the department tree. Recursively builds children.
class _DepartmentTreeNode extends StatelessWidget {
  final OrgDepartmentNode node;
  final List<OrgDepartmentNode> allDepartments;
  final List<String> selectedDepartmentIds;
  final void Function(String) onToggleSingle;
  final void Function(String) onToggleTree;
  final int depth;

  const _DepartmentTreeNode({
    required this.node,
    required this.allDepartments,
    required this.selectedDepartmentIds,
    required this.onToggleSingle,
    required this.onToggleTree,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final children = allDepartments
        .where((d) =>
            d.parentDepartmentId == node.departmentId &&
            d.departmentId != node.departmentId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final hasChildren = children.isNotEmpty;

    // Compute check state for this node
    final allDescendantIds = _collectAllIds(node);
    final selectedInTree =
        allDescendantIds.where(selectedDepartmentIds.contains).length;
    final isAllSelected = selectedInTree == allDescendantIds.length;
    final isSomeSelected = selectedInTree > 0 && !isAllSelected;

    if (!hasChildren) {
      // Leaf node — simple checkbox row
      final isSelected = selectedDepartmentIds.contains(node.departmentId);
      return Padding(
        padding: EdgeInsets.only(left: depth * 24.0),
        child: CheckboxListTile(
          value: isSelected,
          onChanged: (_) => onToggleSingle(node.departmentId),
          title: Text(
            node.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 19,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      );
    }

    // Parent node — expandable
    return Padding(
      padding: EdgeInsets.only(left: depth * 24.0),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: depth == 0,
          tilePadding: const EdgeInsets.only(left: 4, right: 16),
          leading: Checkbox(
            value: isAllSelected ? true : (isSomeSelected ? null : false),
            tristate: true,
            onChanged: (_) => onToggleTree(node.departmentId),
          ),
          title: Text(
            node.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            for (final child in children)
              _DepartmentTreeNode(
                node: child,
                allDepartments: allDepartments,
                selectedDepartmentIds: selectedDepartmentIds,
                onToggleSingle: onToggleSingle,
                onToggleTree: onToggleTree,
                depth: depth + 1,
              ),
          ],
        ),
      ),
    );
  }

  /// Collect this node's ID + all descendant IDs recursively.
  Set<String> _collectAllIds(OrgDepartmentNode dept) {
    final result = <String>{dept.departmentId};
    final children = allDepartments.where((d) =>
        d.parentDepartmentId == dept.departmentId &&
        d.departmentId != dept.departmentId);
    for (final child in children) {
      result.addAll(_collectAllIds(child));
    }
    return result;
  }

}
