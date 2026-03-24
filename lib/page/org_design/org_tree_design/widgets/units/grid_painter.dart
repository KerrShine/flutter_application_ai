part of '../org_tree_canvas_panel_widget.dart';

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.34)
      ..strokeWidth = 1.2;

    const spacing = 24.0;
    var columnIndex = 0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        columnIndex % 5 == 0 ? majorPaint : minorPaint,
      );
      columnIndex++;
    }
    var rowIndex = 0;
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        rowIndex % 5 == 0 ? majorPaint : minorPaint,
      );
      rowIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
