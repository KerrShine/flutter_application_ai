import 'package:flutter/material.dart';

class SignOffGridPainter extends CustomPainter {
  final Color minor;
  final Color major;
  final double spacing;

  const SignOffGridPainter({
    required this.minor,
    required this.major,
    this.spacing = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintMinor = Paint()
      ..color = minor
      ..strokeWidth = 0.5;
    final paintMajor = Paint()
      ..color = major
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += spacing) {
      final isMajor = (x ~/ spacing) % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? paintMajor : paintMinor,
      );
    }
    for (double y = 0; y <= size.height; y += spacing) {
      final isMajor = (y ~/ spacing) % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? paintMajor : paintMinor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SignOffGridPainter old) =>
      old.minor != minor || old.major != major || old.spacing != spacing;
}
