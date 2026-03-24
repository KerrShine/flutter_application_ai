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
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isSelected
        ? colorScheme.primaryContainer
        : isHighlightedParent
            ? Colors.green.shade50
            : Colors.white;
    final borderColor = isSelected
        ? colorScheme.primary
        : isHighlightedParent
            ? Colors.green.shade600
            : Colors.grey.shade400;
    final borderWidth = isSelected || isHighlightedParent ? 2.2 : 1.0;
    final titleColor = isSelected
        ? colorScheme.onPrimaryContainer
        : isHighlightedParent
            ? Colors.green.shade900
            : Colors.black87;
    final subtitleColor = isSelected
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.82)
        : isHighlightedParent
            ? Colors.green.shade800
            : Theme.of(context).textTheme.bodySmall?.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: OrgTreeCanvasPanelWidget.nodeWidth,
      height: OrgTreeCanvasPanelWidget.nodeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlightedParent
                ? Colors.green.withValues(alpha: 0.16)
                : Colors.black.withValues(alpha: 0.06),
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
