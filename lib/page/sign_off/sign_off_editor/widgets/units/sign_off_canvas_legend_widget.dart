import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// Canvas 角落浮動圖例 — 解釋連線顏色對應的節點類型。
///
/// 對應 [SignOffConnectionPainter] 的 flowColorByNodeType 設定：
/// - 綠 = 審核（approve）
/// - 紫 = 會簽（countersign）
/// - 琥珀 = 知會（notify，不阻擋流程）
class SignOffCanvasLegendWidget extends StatelessWidget {
  const SignOffCanvasLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.canvasCardBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.canvasCardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.canvasCardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '連線色',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.subtleText,
            ),
          ),
          const SizedBox(height: 6),
          _LegendRow(color: colors.signOffFlowApprove, label: '審核'),
          const SizedBox(height: 3),
          _LegendRow(color: colors.signOffFlowCountersign, label: '會簽'),
          const SizedBox(height: 3),
          _LegendRow(color: colors.signOffFlowNotify, label: '知會'),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
