import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffOrgSourcePanelWidget extends StatefulWidget {
  final List<OrgDepartmentNode> departments;
  final Set<String> placedDepartmentIds;
  final String? highlightedId;
  final void Function(String departmentId) onSelectAvailable;
  final VoidCallback onAddApplicantOrigin;
  final VoidCallback onAddApplicantSelf;
  final VoidCallback onAddApplicantAncestorManager;
  final void Function(int depthLevel) onAddApplicantManagerAtDepth;
  final VoidCallback onAddApplicantAgent;
  final bool hasApplicantOrigin;

  const SignOffOrgSourcePanelWidget({
    super.key,
    required this.departments,
    required this.placedDepartmentIds,
    required this.highlightedId,
    required this.onSelectAvailable,
    required this.onAddApplicantOrigin,
    required this.onAddApplicantSelf,
    required this.onAddApplicantAncestorManager,
    required this.onAddApplicantManagerAtDepth,
    required this.onAddApplicantAgent,
    required this.hasApplicantOrigin,
  });

  @override
  State<SignOffOrgSourcePanelWidget> createState() =>
      _SignOffOrgSourcePanelWidgetState();
}

class _SignOffOrgSourcePanelWidgetState
    extends State<SignOffOrgSourcePanelWidget> {
  final TextEditingController _filterController = TextEditingController();
  String _filterText = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  /// 相對申請人類 node 的小型「新增」按鈕（2×2 排列共用）。
  Widget _relativeAddButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: TextStyle(
          fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    var selectable = widget.departments
        .where((d) => d.depthLevel >= 1 && d.isActive)
        .toList()
      ..sort((a, b) {
        final cmp = a.depthLevel.compareTo(b.depthLevel);
        return cmp != 0 ? cmp : a.sortOrder.compareTo(b.sortOrder);
      });

    if (_filterText.isNotEmpty) {
      final keyword = _filterText.toLowerCase();
      selectable = selectable
          .where((d) =>
              d.name.toLowerCase().contains(keyword) ||
              d.departmentCode.toLowerCase().contains(keyword))
          .toList();
    }

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colors.sectionPanelBackground,
        border: Border(right: BorderSide(color: colors.panelBorder)),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header accent
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.headerAccentBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.panelBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.headerAccentForeground
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_tree,
                      color: colors.headerAccentForeground,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '組織架構',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize:
                                (theme.textTheme.titleSmall?.fontSize ?? 14) + 2,
                            fontWeight: FontWeight.w700,
                            color: colors.headerAccentForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '拖曳部門到中央畫布',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize:
                                (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                            color: colors.subtleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.headerChipBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${selectable.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize:
                            (theme.textTheme.labelLarge?.fontSize ?? 14) + 2,
                        color: colors.headerChipText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Filter
            TextField(
              controller: _filterController,
              onChanged: (value) => setState(() => _filterText = value),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize:
                    (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
              ),
              decoration: InputDecoration(
                labelText: '篩選部門名稱 / 代碼',
                hintText: '輸入關鍵字模糊比對',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _filterText.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _filterController.clear();
                          setState(() => _filterText = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Add applicant origin
            OutlinedButton.icon(
              onPressed:
                  widget.hasApplicantOrigin ? null : widget.onAddApplicantOrigin,
              icon: const Icon(Icons.person_pin_circle_outlined, size: 18),
              label: Text(
                '新增申請起點',
                style: TextStyle(
                  fontSize:
                      (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            // Add relative applicant nodes — 2x2 排列以節省垂直空間
            Row(
              children: [
                Expanded(
                  child: _relativeAddButton(
                    theme,
                    icon: Icons.person_outline,
                    label: '申請人',
                    onPressed: widget.onAddApplicantSelf,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _relativeAddButton(
                    theme,
                    icon: Icons.supervisor_account_outlined,
                    label: '上層主管',
                    onPressed: widget.onAddApplicantAncestorManager,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _relativeAddButton(
                    theme,
                    icon: Icons.business_center_outlined,
                    label: '指定層級',
                    onPressed: () => widget.onAddApplicantManagerAtDepth(1),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _relativeAddButton(
                    theme,
                    icon: Icons.swap_horiz,
                    label: '代理人',
                    onPressed: widget.onAddApplicantAgent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // List — shrinkWrap 並交由外層 SingleChildScrollView 捲動
            if (selectable.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    _filterText.isEmpty ? '目前沒有可用的組織節點' : '沒有符合條件的部門',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize:
                          (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                      color: colors.faintText,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectable.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                        final dept = selectable[index];
                        final isPlaced = widget.placedDepartmentIds
                            .contains(dept.departmentId);
                        final isHighlighted =
                            widget.highlightedId == dept.departmentId;

                        return Draggable<String>(
                          data: dept.departmentId,
                          maxSimultaneousDrags: isPlaced ? 0 : 1,
                          dragAnchorStrategy: pointerDragAnchorStrategy,
                          onDragStarted: () =>
                              widget.onSelectAvailable(dept.departmentId),
                          feedback: _DepartmentDragFeedback(
                            department: dept,
                            colors: colors,
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.35,
                            child: _DepartmentTile(
                              department: dept,
                              colors: colors,
                              isPlaced: isPlaced,
                              isHighlighted: isHighlighted,
                              onTap: () =>
                                  widget.onSelectAvailable(dept.departmentId),
                            ),
                          ),
                          child: _DepartmentTile(
                            department: dept,
                            colors: colors,
                            isPlaced: isPlaced,
                            isHighlighted: isHighlighted,
                            onTap: () =>
                                widget.onSelectAvailable(dept.departmentId),
                          ),
                        );
                      },
                    ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentDragFeedback extends StatelessWidget {
  final OrgDepartmentNode department;
  final FormDesignThemeColors colors;

  const _DepartmentDragFeedback({
    required this.department,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 220,
        child: Container(
          decoration: BoxDecoration(
            color: colors.sectionCardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.actionButtonAccent, width: 1.6),
            boxShadow: [
              BoxShadow(
                color: colors.sectionCardShadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.sectionIconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_tree_outlined,
                  color: colors.sectionIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize:
                            (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      department.departmentCode.isEmpty
                          ? '未設定代碼'
                          : department.departmentCode,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize:
                            (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                        color: colors.subtleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartmentTile extends StatelessWidget {
  final OrgDepartmentNode department;
  final FormDesignThemeColors colors;
  final bool isPlaced;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _DepartmentTile({
    required this.department,
    required this.colors,
    required this.isPlaced,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = isPlaced
        ? colors.sectionCardBackground.withValues(alpha: 0.5)
        : (isHighlighted
            ? colors.sectionCardBackground
            : colors.sectionCardBackground.withValues(alpha: 0.85));
    final borderColor = isHighlighted
        ? colors.actionButtonAccent
        : colors.sectionCardBorder;

    return MouseRegion(
      cursor: isPlaced ? SystemMouseCursors.basic : SystemMouseCursors.grab,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              10.0 + (department.depthLevel - 1) * 14,
              10,
              10,
              10,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: isHighlighted ? 1.6 : 1,
              ),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: colors.actionButtonAccent.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.sectionIconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_tree_outlined,
                    size: 18,
                    color: isPlaced
                        ? colors.faintText
                        : colors.sectionIconColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize:
                              (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
                          fontWeight: isHighlighted
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isPlaced ? colors.faintText : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        department.departmentCode.isEmpty
                            ? '-'
                            : department.departmentCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize:
                              (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                          color: colors.subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPlaced)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.check_circle,
                        size: 18, color: colors.actionSuccess),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
