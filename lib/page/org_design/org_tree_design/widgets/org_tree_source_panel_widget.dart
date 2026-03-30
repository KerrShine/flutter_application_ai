import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/theme/org_tree_design_theme_colors.dart';

class OrgTreeSourcePanelWidget extends StatelessWidget {
  final String orgName;
  final List<OrgDepartmentNode> departments;
  final Set<String> placedDepartmentIds;
  final String selectedDepartmentId;
  final TextEditingController filterController;
  final ValueChanged<String> onSelectDepartment;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClearFilter;
  final void Function(String departmentId) onDragStarted;
  final VoidCallback onAddOrganization;

  const OrgTreeSourcePanelWidget({
    super.key,
    required this.orgName,
    required this.departments,
    required this.placedDepartmentIds,
    required this.selectedDepartmentId,
    required this.filterController,
    required this.onSelectDepartment,
    required this.onFilterChanged,
    required this.onClearFilter,
    required this.onDragStarted,
    required this.onAddOrganization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<OrgTreeDesignThemeColors>()!;
    final orgTitleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.2,
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
                    child: Icon(
                      Icons.account_tree_outlined,
                      color: colors.headerForeground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orgName.isEmpty ? '簽核系統組織' : orgName,
                          style: orgTitleStyle?.copyWith(
                            color: colors.headerForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '從左側清單拖曳部門到中央畫布。',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.subtleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.headerChipBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${departments.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.headerChipForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: filterController,
              onChanged: onFilterChanged,
              decoration: InputDecoration(
                labelText: '篩選部門名稱 / 代碼',
                hintText: '輸入關鍵字模糊比對',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filterController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: onClearFilter,
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: departments.isEmpty
                  ? const Center(child: Text('目前沒有可用的組織節點'))
                  : ListView.separated(
                      itemCount: departments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final department = departments[index];
                        final isPlaced = placedDepartmentIds
                            .contains(department.departmentId);
                        return Draggable<String>(
                          data: department.departmentId,
                          onDragStarted: () {
                            onDragStarted(department.departmentId);
                          },
                          maxSimultaneousDrags: 1,
                          dragAnchorStrategy: pointerDragAnchorStrategy,
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 220,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.panelBackground,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: colors.panelBorder),
                                ),
                                child: ListTile(
                                  leading:
                                      const Icon(Icons.account_tree_outlined),
                                  title: Text(department.name),
                                  subtitle: Text(
                                    department.departmentCode.isEmpty
                                        ? '未設定代碼'
                                        : department.departmentCode,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.35,
                            child: _DepartmentTile(
                              department: department,
                              selectedDepartmentId: selectedDepartmentId,
                              isPlaced: isPlaced,
                              onTap: onSelectDepartment,
                            ),
                          ),
                          child: _DepartmentTile(
                            department: department,
                            selectedDepartmentId: selectedDepartmentId,
                            isPlaced: isPlaced,
                            onTap: onSelectDepartment,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddOrganization,
                icon: const Icon(Icons.add),
                label: const Text('新增組織'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentTile extends StatelessWidget {
  final OrgDepartmentNode department;
  final String selectedDepartmentId;
  final bool isPlaced;
  final ValueChanged<String> onTap;

  const _DepartmentTile({
    required this.department,
    required this.selectedDepartmentId,
    required this.isPlaced,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<OrgTreeDesignThemeColors>()!;
    final isSelected = department.departmentId == selectedDepartmentId;

    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Material(
        color: isSelected
            ? colors.sourceSelectedBackground
            : isPlaced
                ? colors.sourcePlacedBackground
                : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: isSelected ? colors.panelBorder : Colors.transparent,
            ),
          ),
          leading: const Icon(Icons.account_tree_outlined),
          title: Text(department.name),
          subtitle: Text(
            '代碼: ${department.departmentCode.isEmpty ? '-' : department.departmentCode}',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.mutedText),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(department.isActive ? '啟用' : '停用'),
              if (isPlaced)
                Text(
                  '已加入',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.mutedText,
                  ),
                ),
            ],
          ),
          onTap: () {
            onTap(department.departmentId);
          },
        ),
      ),
    );
  }
}
