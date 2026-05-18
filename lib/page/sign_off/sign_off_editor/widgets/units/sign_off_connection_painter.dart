import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/sign_off_approver_mode.dart';
import 'package:flutter_application_ai/enum/sign_off_node_type.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';

const double signOffNodeWidth = 200;
const double signOffNodeHeight = 88;
const double signOffCanvasInset = 120;

/// 連線錨點：節點外框四個中點之一。
class _EdgeAnchorPair {
  final Offset from;
  final Offset to;
  final bool isVerticalDominant;
  const _EdgeAnchorPair({
    required this.from,
    required this.to,
    required this.isVerticalDominant,
  });
}

class SignOffConnectionPainter extends CustomPainter {
  final List<SignOffCanvasNode> nodes;
  final Map<String, OrgDepartmentNode> deptById;
  final Color hierarchyColor;
  final Color crossLevelColor;

  /// 簽核流向線色 — 依目標節點 nodeType 區分（A2 UX 增強）：
  /// approve = 綠 / countersign = 紫 / notify = 琥珀。
  /// 找不到對應 key 時用 fallback (approve 色) 避免崩潰。
  final Map<SignOffNodeType, Color> flowColorByNodeType;

  final bool showHierarchy;

  SignOffConnectionPainter({
    required this.nodes,
    required this.deptById,
    required this.hierarchyColor,
    required this.crossLevelColor,
    required this.flowColorByNodeType,
    required this.showHierarchy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerByNodeId = <String, Offset>{};
    final centerByDeptId = <String, Offset>{};

    for (final node in nodes) {
      final cx = signOffCanvasInset + node.offsetDx + signOffNodeWidth / 2;
      final cy = signOffCanvasInset + node.offsetDy + signOffNodeHeight / 2;
      centerByNodeId[node.nodeId] = Offset(cx, cy);
      if (node.departmentId.isNotEmpty) {
        centerByDeptId[node.departmentId] = Offset(cx, cy);
      }
    }

    // 1. 組織連線（淡灰虛線右角折線）
    if (showHierarchy) {
      final hierarchyPaint = Paint()
        ..color = hierarchyColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;

      for (final node in nodes) {
        if (node.isApplicantOrigin) continue;
        final dept = deptById[node.departmentId];
        if (dept == null) continue;
        final parentCenter = centerByDeptId[dept.parentDepartmentId];
        if (parentCenter == null) continue;

        final childCenter = centerByNodeId[node.nodeId]!;
        final anchors = _pickEdgeAnchors(parentCenter, childCenter);
        _drawDashedRightAngle(canvas, hierarchyPaint, anchors);
      }
    }

    // 2. 同層互簽（藍色虛線雙向直線）
    final crossPaint = Paint()
      ..color = crossLevelColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final node in nodes) {
      if (node.approverMode != SignOffApproverMode.crossLevel) continue;
      if (node.crossLevelTargetNodeId.isEmpty) continue;
      final fromC = centerByNodeId[node.nodeId];
      final toC = centerByNodeId[node.crossLevelTargetNodeId];
      if (fromC == null || toC == null) continue;

      final anchors = _pickEdgeAnchors(fromC, toC);
      _drawDashedLine(canvas, crossPaint, anchors.from, anchors.to);
    }

    // 3. 簽核流向連線（實線含箭頭，依目標節點 nodeType 取色）
    final fallbackFlowColor =
        flowColorByNodeType[SignOffNodeType.approve] ?? Colors.green;

    final sortedNodes = List<SignOffCanvasNode>.from(nodes)
      ..sort((a, b) {
        if (a.isApplicantOrigin && !b.isApplicantOrigin) return -1;
        if (!a.isApplicantOrigin && b.isApplicantOrigin) return 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });

    for (var i = 0; i < sortedNodes.length - 1; i++) {
      final fromC = centerByNodeId[sortedNodes[i].nodeId];
      final toC = centerByNodeId[sortedNodes[i + 1].nodeId];
      if (fromC == null || toC == null) continue;

      final targetType = sortedNodes[i + 1].nodeType;
      final color = flowColorByNodeType[targetType] ?? fallbackFlowColor;
      final flowPaint = Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final flowFillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final anchors = _pickEdgeAnchors(fromC, toC);
      _drawArrowLine(canvas, flowPaint, flowFillPaint, anchors.from, anchors.to);
    }
  }

  /// 依兩節點 center 的相對位置，挑選最合適的「邊框中點」對。
  /// 比較 |dx| vs |dy|：
  ///   水平佔優 → 使用 left/right 中點
  ///   垂直佔優 → 使用 top/bottom 中點
  _EdgeAnchorPair _pickEdgeAnchors(Offset fromCenter, Offset toCenter) {
    final dx = toCenter.dx - fromCenter.dx;
    final dy = toCenter.dy - fromCenter.dy;
    const halfW = signOffNodeWidth / 2;
    const halfH = signOffNodeHeight / 2;

    if (dx.abs() >= dy.abs()) {
      // 水平佔優：使用左右中點
      if (dx >= 0) {
        return _EdgeAnchorPair(
          from: Offset(fromCenter.dx + halfW, fromCenter.dy),
          to: Offset(toCenter.dx - halfW, toCenter.dy),
          isVerticalDominant: false,
        );
      }
      return _EdgeAnchorPair(
        from: Offset(fromCenter.dx - halfW, fromCenter.dy),
        to: Offset(toCenter.dx + halfW, toCenter.dy),
        isVerticalDominant: false,
      );
    }

    // 垂直佔優：使用上下中點
    if (dy >= 0) {
      return _EdgeAnchorPair(
        from: Offset(fromCenter.dx, fromCenter.dy + halfH),
        to: Offset(toCenter.dx, toCenter.dy - halfH),
        isVerticalDominant: true,
      );
    }
    return _EdgeAnchorPair(
      from: Offset(fromCenter.dx, fromCenter.dy - halfH),
      to: Offset(toCenter.dx, toCenter.dy + halfH),
      isVerticalDominant: true,
    );
  }

  /// 直角折線（用於組織連線）。
  /// - 垂直佔優：vertical → horizontal → vertical（在中間 Y 轉折）
  /// - 水平佔優：horizontal → vertical → horizontal（在中間 X 轉折）
  void _drawDashedRightAngle(Canvas canvas, Paint paint, _EdgeAnchorPair a) {
    if (a.isVerticalDominant) {
      final midY = (a.from.dy + a.to.dy) / 2;
      _drawDashedLine(canvas, paint, a.from, Offset(a.from.dx, midY));
      _drawDashedLine(
          canvas, paint, Offset(a.from.dx, midY), Offset(a.to.dx, midY));
      _drawDashedLine(canvas, paint, Offset(a.to.dx, midY), a.to);
    } else {
      final midX = (a.from.dx + a.to.dx) / 2;
      _drawDashedLine(canvas, paint, a.from, Offset(midX, a.from.dy));
      _drawDashedLine(
          canvas, paint, Offset(midX, a.from.dy), Offset(midX, a.to.dy));
      _drawDashedLine(canvas, paint, Offset(midX, a.to.dy), a.to);
    }
  }

  /// 虛線（dashLen=8, gap=5）。
  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    const dashLen = 8.0;
    const gapLen = 5.0;
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) return;
    final direction = delta / distance;

    double drawn = 0;
    while (drawn < distance) {
      final segStart = start + direction * drawn;
      final segEnd = start +
          direction *
              (drawn + dashLen > distance ? distance : drawn + dashLen);
      canvas.drawLine(segStart, segEnd, paint);
      drawn += dashLen + gapLen;
    }
  }

  /// 帶箭頭的實線（用於簽核流向）。起終點已在邊框上。
  void _drawArrowLine(
    Canvas canvas,
    Paint linePaint,
    Paint fillPaint,
    Offset from,
    Offset to,
  ) {
    final delta = to - from;
    final distance = delta.distance;
    if (distance == 0) return;
    final direction = delta / distance;

    canvas.drawLine(from, to, linePaint);

    // 箭頭三角形：tip 落在終點邊框上，base 沿反方向退 arrowLength
    const arrowLength = 12.0;
    const arrowWidth = 8.0;
    final tip = to;
    final base = tip - direction * arrowLength;
    final perpendicular = Offset(-direction.dy, direction.dx);
    final leftPoint = base + perpendicular * (arrowWidth / 2);
    final rightPoint = base - perpendicular * (arrowWidth / 2);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftPoint.dx, leftPoint.dy)
      ..lineTo(rightPoint.dx, rightPoint.dy)
      ..close();
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant SignOffConnectionPainter old) =>
      old.nodes != nodes ||
      old.deptById != deptById ||
      old.hierarchyColor != hierarchyColor ||
      old.crossLevelColor != crossLevelColor ||
      !_mapEquals(old.flowColorByNodeType, flowColorByNodeType) ||
      old.showHierarchy != showHierarchy;

  static bool _mapEquals(
    Map<SignOffNodeType, Color> a,
    Map<SignOffNodeType, Color> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
