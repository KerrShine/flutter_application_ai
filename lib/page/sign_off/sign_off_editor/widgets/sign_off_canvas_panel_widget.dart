import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/bloc/sign_off_editor_bloc.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/units/sign_off_connection_painter.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/units/sign_off_grid_painter.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/units/sign_off_node_card.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/units/sign_off_zoom_controls.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffCanvasPanelWidget extends StatelessWidget {
  static const double canvasMinWidth = 2600;
  static const double canvasMinHeight = 2000;
  static const double canvasContentPadding = 320;

  final List<SignOffCanvasNode> nodes;
  final List<OrgDepartmentNode> departments;
  final String? selectedNodeId;
  final TransformationController transformationController;
  final double currentScale;
  final bool showHierarchyConnections;

  /// 模擬模式啟用時，每個節點的 simulation 狀態。
  /// 非模擬模式傳 const {} 即可。
  final Map<String, SimulationStatus> simulationStatusByNodeId;

  /// 給定 nodeId 取得「已停留 / 已過期」天數的回呼。
  /// 非模擬模式時可傳 (_) => 0。
  final int Function(String nodeId) simulationOffsetForNode;

  /// Rule 預覽模式是否啟用 — 若啟用，被排除的節點將暗化。
  final bool rulePreviewMode;

  /// Rule 預覽模式下被啟用的 nodeId 集合（其餘非 origin 節點將被暗化）。
  final Set<String> rulePreviewActivatedNodeIds;

  final void Function(String departmentId, double dx, double dy)
      onDropDepartment;
  final void Function(String nodeId) onSelectNode;
  final void Function(String nodeId, double deltaDx, double deltaDy) onMoveNode;
  final void Function(List<double> values) onSyncTransform;
  final void Function(double width, double height) onViewportChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenterCanvas;
  final VoidCallback onToggleHierarchy;

  const SignOffCanvasPanelWidget({
    super.key,
    required this.nodes,
    required this.departments,
    required this.selectedNodeId,
    required this.transformationController,
    required this.currentScale,
    required this.showHierarchyConnections,
    required this.simulationStatusByNodeId,
    required this.simulationOffsetForNode,
    required this.rulePreviewMode,
    required this.rulePreviewActivatedNodeIds,
    required this.onDropDepartment,
    required this.onSelectNode,
    required this.onMoveNode,
    required this.onSyncTransform,
    required this.onViewportChanged,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenterCanvas,
    required this.onToggleHierarchy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = theme.extension<FormDesignThemeColors>()!;

    final deptById = {
      for (final d in departments) d.departmentId: d,
    };

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colors.canvasPanelBackground,
          border: Border.symmetric(
            vertical: BorderSide(color: colors.panelBorder),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onViewportChanged(constraints.maxWidth, constraints.maxHeight);
            });

            // 計算 canvas 尺寸：依節點 bounding box + viewport 比例
            var contentMaxRight = 0.0;
            var contentMaxBottom = 0.0;
            for (final node in nodes) {
              final right = node.offsetDx + signOffNodeWidth;
              final bottom = node.offsetDy + signOffNodeHeight;
              if (right > contentMaxRight) contentMaxRight = right;
              if (bottom > contentMaxBottom) contentMaxBottom = bottom;
            }

            final contentWidth = contentMaxRight +
                (signOffCanvasInset * 2) +
                canvasContentPadding;
            final contentHeight = contentMaxBottom +
                (signOffCanvasInset * 2) +
                canvasContentPadding;
            final viewportWidth = constraints.maxWidth * 2.4;
            final viewportHeight = constraints.maxHeight * 2.4;
            final canvasWidth = [
              canvasMinWidth,
              viewportWidth,
              contentWidth,
            ].reduce((a, b) => a > b ? a : b);
            final canvasHeight = [
              canvasMinHeight,
              viewportHeight,
              contentHeight,
            ].reduce((a, b) => a > b ? a : b);
            final actualCanvasWidth = canvasWidth - (signOffCanvasInset * 2);
            final actualCanvasHeight = canvasHeight - (signOffCanvasInset * 2);

            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRect(
                      child: Builder(
                        builder: (viewportContext) {
                          return InteractiveViewer(
                            transformationController: transformationController,
                            minScale: 0.6,
                            maxScale: 2.4,
                            panEnabled: true,
                            scaleEnabled: true,
                            constrained: false,
                            boundaryMargin: const EdgeInsets.all(800),
                            onInteractionUpdate: (_) {
                              onSyncTransform(
                                transformationController.value.storage.toList(),
                              );
                            },
                            onInteractionEnd: (_) {
                              onSyncTransform(
                                transformationController.value.storage.toList(),
                              );
                            },
                            child: DragTarget<String>(
                              onAcceptWithDetails: (details) {
                                final viewportBox = viewportContext
                                    .findRenderObject() as RenderBox;
                                final viewportOffset =
                                    viewportBox.globalToLocal(details.offset);
                                final sceneOffset = transformationController
                                    .toScene(viewportOffset);
                                onDropDepartment(
                                  details.data,
                                  sceneOffset.dx -
                                      signOffCanvasInset -
                                      (signOffNodeWidth / 2),
                                  sceneOffset.dy -
                                      signOffCanvasInset -
                                      (signOffNodeHeight / 2),
                                );
                              },
                              builder: (context, candidate, rejected) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                    width: canvasWidth,
                                    height: canvasHeight,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ColoredBox(
                                            color: colors.canvasPanelBackground,
                                          ),
                                        ),
                                        // Inner canvas surface (with border + shadow)
                                        Positioned(
                                          left: signOffCanvasInset,
                                          top: signOffCanvasInset,
                                          width: actualCanvasWidth,
                                          height: actualCanvasHeight,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: colors.canvasCardBackground,
                                              border: Border.all(
                                                color: colors.canvasCardBorder,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colors.canvasCardShadow,
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Grid (inside canvas surface only)
                                        Positioned(
                                          left: signOffCanvasInset,
                                          top: signOffCanvasInset,
                                          width: actualCanvasWidth,
                                          height: actualCanvasHeight,
                                          child: CustomPaint(
                                            painter: SignOffGridPainter(
                                              minor: colors.panelBorder
                                                  .withValues(alpha: 0.4),
                                              major: colors.panelBorder
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ),
                                        // Connections
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: SignOffConnectionPainter(
                                              nodes: nodes,
                                              deptById: deptById,
                                              hierarchyColor: scheme.outline,
                                              crossLevelColor:
                                                  colors.actionButtonAccent,
                                              flowColor: colors.actionSuccess,
                                              showHierarchy:
                                                  showHierarchyConnections,
                                            ),
                                          ),
                                        ),
                                        // Badge
                                        Positioned(
                                          left: signOffCanvasInset + 16,
                                          top: signOffCanvasInset + 12,
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 7,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  colors.headerAccentBackground,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                  color: colors.panelBorder),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colors.canvasCardShadow,
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.dashboard_customize,
                                                  size: 16,
                                                  color: colors
                                                      .headerAccentForeground,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '簽核流程畫布',
                                                  style: theme.textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                    fontSize:
                                                        (theme.textTheme.labelMedium?.fontSize ?? 12) +
                                                            2,
                                                    fontWeight: FontWeight.w700,
                                                    color: colors
                                                        .headerAccentForeground,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Nodes
                                        for (final node in nodes)
                                          Positioned(
                                            left: signOffCanvasInset +
                                                node.offsetDx,
                                            top: signOffCanvasInset +
                                                node.offsetDy,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  onSelectNode(node.nodeId),
                                              onPanUpdate: (details) {
                                                onMoveNode(
                                                  node.nodeId,
                                                  details.delta.dx,
                                                  details.delta.dy,
                                                );
                                              },
                                              child: SignOffNodeCard(
                                                node: node,
                                                department:
                                                    deptById[node.departmentId],
                                                isSelected:
                                                    selectedNodeId == node.nodeId,
                                                simulationStatus:
                                                    simulationStatusByNodeId[
                                                        node.nodeId],
                                                simulationOffsetDays:
                                                    simulationOffsetForNode(
                                                        node.nodeId),
                                                isInactivatedByRulePreview:
                                                    rulePreviewMode &&
                                                        !node.isApplicantOrigin &&
                                                        !rulePreviewActivatedNodeIds
                                                            .contains(node.nodeId),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: SignOffZoomControls(
                    currentScale: currentScale,
                    showHierarchyConnections: showHierarchyConnections,
                    onCenterCanvas: onCenterCanvas,
                    onZoomIn: onZoomIn,
                    onZoomOut: onZoomOut,
                    onToggleHierarchy: onToggleHierarchy,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
