part of '../org_tree_canvas_panel_widget.dart';

class _CanvasZoomControls extends StatelessWidget {
  final double currentScale;
  final VoidCallback onCenterCanvas;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _CanvasZoomControls({
    required this.currentScale,
    required this.onCenterCanvas,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white.withValues(alpha: 0.96),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '置中組織圖',
              onPressed: onCenterCanvas,
              icon: const Icon(Icons.center_focus_strong),
            ),
            IconButton(
              tooltip: '縮小畫布',
              onPressed: onZoomOut,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 52,
              child: Text(
                '${(currentScale * 100).round()}%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
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
