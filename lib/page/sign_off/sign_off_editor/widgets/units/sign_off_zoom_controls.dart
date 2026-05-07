import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffZoomControls extends StatelessWidget {
  final double currentScale;
  final bool showHierarchyConnections;
  final VoidCallback onCenterCanvas;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleHierarchy;

  const SignOffZoomControls({
    super.key,
    required this.currentScale,
    required this.showHierarchyConnections,
    required this.onCenterCanvas,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleHierarchy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Material(
      elevation: 6,
      color: colors.canvasCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.canvasCardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip:
                  showHierarchyConnections ? '隱藏組織連線' : '顯示組織連線',
              onPressed: onToggleHierarchy,
              icon: Icon(
                showHierarchyConnections
                    ? Icons.account_tree
                    : Icons.account_tree_outlined,
              ),
              color: showHierarchyConnections
                  ? colors.actionButtonAccent
                  : colors.faintText,
            ),
            SizedBox(
              height: 24,
              child: VerticalDivider(
                width: 8,
                thickness: 1,
                color: colors.panelBorder,
              ),
            ),
            IconButton(
              tooltip: '置中至內容',
              onPressed: onCenterCanvas,
              icon: const Icon(Icons.center_focus_strong),
              color: colors.actionButtonAccent,
            ),
            IconButton(
              tooltip: '縮小畫布',
              onPressed: onZoomOut,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 56,
              child: Text(
                '${(currentScale * 100).round()}%',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize:
                      (theme.textTheme.labelLarge?.fontSize ?? 14) + 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: '放大畫布',
              onPressed: onZoomIn,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
