part of '../org_tree_canvas_panel_widget.dart';

class _GridPainter extends CustomPainter {
  final Color minorColor;
  final Color majorColor;

  const _GridPainter({
    required this.minorColor,
    required this.majorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = minorColor
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = majorColor
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
