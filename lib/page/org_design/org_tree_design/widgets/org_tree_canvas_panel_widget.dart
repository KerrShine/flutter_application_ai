import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/org_tree_canvas_node.dart';

part 'units/canvas_node_card.dart';
part 'units/canvas_zoom_controls.dart';
part 'units/grid_painter.dart';
part 'units/connection_painter.dart';

class OrgTreeCanvasPanelWidget extends StatelessWidget {
  static const double nodeWidth = 176;
  static const double nodeHeight = 76;
  static const double canvasMinWidth = 2600;
  static const double canvasMinHeight = 2000;
  static const double canvasInset = 120;
  static const double canvasContentPadding = 320;

  final TransformationController transformationController;
  final double currentScale;
  final List<OrgDepartmentNode> departments;
  final List<OrgTreeCanvasNode> canvasNodes;
  final String selectedDepartmentId;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenterCanvas;
  final void Function(double viewportWidth, double viewportHeight)
      onViewportChanged;
  final void Function(String departmentId, double offsetDx, double offsetDy)
      onDropDepartment;
  final void Function(String departmentId) onSelectNode;
  final void Function(String departmentId, double deltaDx, double deltaDy)
      onMoveNode;

  const OrgTreeCanvasPanelWidget({
    super.key,
    required this.transformationController,
    required this.currentScale,
    required this.departments,
    required this.canvasNodes,
    required this.selectedDepartmentId,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenterCanvas,
    required this.onViewportChanged,
    required this.onDropDepartment,
    required this.onSelectNode,
    required this.onMoveNode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onViewportChanged(constraints.maxWidth, constraints.maxHeight);
            });

            var contentMaxRight = 0.0;
            var contentMaxBottom = 0.0;

            for (final canvasNode in canvasNodes) {
              final nodeRight = canvasNode.offsetDx + nodeWidth;
              final nodeBottom = canvasNode.offsetDy + nodeHeight;
              if (nodeRight > contentMaxRight) {
                contentMaxRight = nodeRight;
              }
              if (nodeBottom > contentMaxBottom) {
                contentMaxBottom = nodeBottom;
              }
            }

            final contentWidth =
                contentMaxRight + (canvasInset * 2) + canvasContentPadding;
            final contentHeight =
                contentMaxBottom + (canvasInset * 2) + canvasContentPadding;
            final viewportWidth = constraints.maxWidth * 2.4;
            final viewportHeight = constraints.maxHeight * 2.4;
            final canvasWidth = [
              canvasMinWidth,
              viewportWidth,
              contentWidth,
            ].reduce((current, next) => current > next ? current : next);
            final canvasHeight = [
              canvasMinHeight,
              viewportHeight,
              contentHeight,
            ].reduce((current, next) => current > next ? current : next);
            final actualCanvasWidth = canvasWidth - (canvasInset * 2);
            final actualCanvasHeight = canvasHeight - (canvasInset * 2);

            return Stack(
              children: [
                Positioned.fill(
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
                        child: DragTarget<String>(
                          onAcceptWithDetails: (details) {
                            final viewportBox =
                                viewportContext.findRenderObject() as RenderBox;
                            final viewportOffset =
                                viewportBox.globalToLocal(details.offset);
                            final sceneOffset = transformationController
                                .toScene(viewportOffset);

                            onDropDepartment(
                              details.data,
                              sceneOffset.dx - canvasInset - (nodeWidth / 2),
                              sceneOffset.dy - canvasInset - (nodeHeight / 2),
                            );
                          },
                          builder: (context, candidateData, rejectedData) {
                            return SizedBox(
                              width: canvasWidth,
                              height: canvasHeight,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ColoredBox(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  Positioned(
                                    left: canvasInset,
                                    top: canvasInset,
                                    width: actualCanvasWidth,
                                    height: actualCanvasHeight,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: canvasInset,
                                    top: canvasInset,
                                    width: actualCanvasWidth,
                                    height: actualCanvasHeight,
                                    child: CustomPaint(
                                      painter: _GridPainter(),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _ConnectionPainter(
                                        canvasNodes: canvasNodes,
                                        departments: departments,
                                        nodeWidth: nodeWidth,
                                        nodeHeight: nodeHeight,
                                        canvasInset: canvasInset,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: canvasInset + 16,
                                    top: canvasInset + 12,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          '畫布區',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...canvasNodes.map((canvasNode) {
                                    OrgDepartmentNode? department;
                                    for (final item in departments) {
                                      if (item.departmentId ==
                                          canvasNode.departmentId) {
                                        department = item;
                                        break;
                                      }
                                    }

                                    if (department == null) {
                                      return const SizedBox.shrink();
                                    }

                                    return Positioned(
                                      left: canvasInset + canvasNode.offsetDx,
                                      top: canvasInset + canvasNode.offsetDy,
                                      child: GestureDetector(
                                        onTap: () {
                                          onSelectNode(canvasNode.departmentId);
                                        },
                                        onPanUpdate: (details) {
                                          onMoveNode(
                                            canvasNode.departmentId,
                                            details.delta.dx,
                                            details.delta.dy,
                                          );
                                        },
                                        child: _CanvasNodeCard(
                                          department: department,
                                          isSelected: department.departmentId ==
                                              selectedDepartmentId,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: _CanvasZoomControls(
                    currentScale: currentScale,
                    onCenterCanvas: onCenterCanvas,
                    onZoomIn: onZoomIn,
                    onZoomOut: onZoomOut,
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
