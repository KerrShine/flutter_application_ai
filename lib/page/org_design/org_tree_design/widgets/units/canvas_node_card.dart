part of '../org_tree_canvas_panel_widget.dart';

class _CanvasNodeCard extends StatelessWidget {
  final OrgDepartmentNode department;
  final bool isSelected;
  final bool isHighlightedParent;

  const _CanvasNodeCard({
    required this.department,
    required this.isSelected,
    required this.isHighlightedParent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OrgTreeDesignThemeColors>()!;
    final backgroundColor = isSelected
        ? colors.nodeSelectedBackground
        : isHighlightedParent
            ? colors.nodeHighlightedBackground
            : colors.nodeBackground;
    final borderColor = isSelected
        ? colors.nodeSelectedBorder
        : isHighlightedParent
            ? colors.nodeHighlightedBorder
            : colors.nodeBorder;
    final borderWidth = isSelected || isHighlightedParent ? 2.2 : 1.0;
    final titleColor = isSelected
        ? colors.nodeSelectedTitle
        : isHighlightedParent
            ? colors.nodeHighlightedTitle
            : colors.nodeTitle;
    final subtitleColor = isSelected
        ? colors.nodeSelectedSubtitle
        : isHighlightedParent
            ? colors.nodeHighlightedSubtitle
            : colors.nodeSubtitle;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: OrgTreeCanvasPanelWidget.nodeWidth,
      height: OrgTreeCanvasPanelWidget.nodeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlightedParent
                ? colors.nodeHighlightedShadow
                : colors.nodeShadow,
            blurRadius: isHighlightedParent ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            department.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            department.departmentCode.isEmpty
                ? '未設定代碼'
                : department.departmentCode,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                  fontWeight: isHighlightedParent ? FontWeight.w600 : null,
                ),
          ),
        ],
      ),
    );
  }
}
