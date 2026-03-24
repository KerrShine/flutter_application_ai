part of '../org_tree_canvas_panel_widget.dart';

class _ConnectionPainter extends CustomPainter {
  final List<OrgTreeCanvasNode> canvasNodes;
  final List<OrgDepartmentNode> departments;
  final double nodeWidth;
  final double nodeHeight;
  final double canvasInset;

  const _ConnectionPainter({
    required this.canvasNodes,
    required this.departments,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.canvasInset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final positions = {
      for (final node in canvasNodes)
        node.departmentId: Offset(
          canvasInset + node.offsetDx + (nodeWidth / 2),
          canvasInset + node.offsetDy + (nodeHeight / 2),
        ),
    };
    final departmentLookup = {
      for (final department in departments) department.departmentId: department,
    };

    for (final canvasNode in canvasNodes) {
      final department = departmentLookup[canvasNode.departmentId];
      if (department == null || department.parentDepartmentId.isEmpty) {
        continue;
      }

      final parentOffset = positions[department.parentDepartmentId];
      final childOffset = positions[department.departmentId];
      if (parentOffset == null || childOffset == null) {
        continue;
      }

      final start = Offset(parentOffset.dx, parentOffset.dy + (nodeHeight / 4));
      final end = Offset(childOffset.dx, childOffset.dy - (nodeHeight / 4));
      final midY = (start.dy + end.dy) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(start.dx, midY)
        ..lineTo(end.dx, midY)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) {
    return oldDelegate.canvasNodes != canvasNodes ||
        oldDelegate.departments != departments;
  }
}
