import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/sign_off_approver_mode.dart';
import 'package:flutter_application_ai/enum/sign_off_node_type.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/bloc/sign_off_editor_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffNodeCard extends StatelessWidget {
  final SignOffCanvasNode node;
  final OrgDepartmentNode? department;
  final bool isSelected;

  /// 模擬模式狀態；非模擬模式傳 null。
  final SimulationStatus? simulationStatus;

  /// 模擬模式下的偏移天數（inProgress = 已停留、expired = 已過期）；非模擬模式傳 0。
  final int simulationOffsetDays;

  /// Path rule 預覽模式下，此節點是否被當前命中規則排除（暗化顯示）。
  final bool isInactivatedByRulePreview;

  const SignOffNodeCard({
    super.key,
    required this.node,
    required this.department,
    required this.isSelected,
    this.simulationStatus,
    this.simulationOffsetDays = 0,
    this.isInactivatedByRulePreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final scheme = theme.colorScheme;

    final title = _buildTitle();

    final subtitle = _buildSubtitle();

    final accent = node.isApplicantOrigin
        ? scheme.tertiary
        : (isSelected ? colors.actionButtonAccent : colors.canvasCardBorder);
    final cardBg = isSelected
        ? colors.actionButtonAccent.withValues(alpha: 0.08)
        : colors.canvasCardBackground;
    final badgeColor = node.isApplicantOrigin
        ? scheme.tertiary
        : colors.actionButtonAccent;
    final badgeText = node.isApplicantOrigin ? '起' : '${node.sortOrder}';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isInactivatedByRulePreview ? 0.35 : 1.0,
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 200,
      height: 88,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent,
          width: isSelected ? 2.4 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? colors.actionButtonAccent.withValues(alpha: 0.18)
                : colors.canvasCardShadow,
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(_iconForNode(), size: 20, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize:
                              (theme.textTheme.titleSmall?.fontSize ?? 14) + 2,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                    color: colors.subtleText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 順序徽章（左上角）
          Positioned(
            left: -10,
            top: -10,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: colors.canvasCardBackground, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.32),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                badgeText,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: node.isApplicantOrigin ? 14 : 15,
                ),
              ),
            ),
          ),
          // SLA / 模擬狀態 chip（右下角）
          if (_shouldShowSlaChip())
            Positioned(
              right: 6,
              bottom: 4,
              child: _buildSlaChip(context, colors, scheme),
            ),
        ],
      ),
      ),
    );
  }

  bool _shouldShowSlaChip() {
    if (node.isApplicantOrigin) return false;
    final isSlaEligible = node.nodeType == SignOffNodeType.approve ||
        node.nodeType == SignOffNodeType.countersign;
    if (!isSlaEligible) return false;
    if (simulationStatus != null) return true;
    return node.slaDays > 0;
  }

  Widget _buildSlaChip(
    BuildContext context,
    FormDesignThemeColors colors,
    ColorScheme scheme,
  ) {
    final theme = Theme.of(context);
    final (label, bg, fg) = _slaChipContent(colors, scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: (theme.textTheme.labelSmall?.fontSize ?? 11) + 1,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  (String, Color, Color) _slaChipContent(
    FormDesignThemeColors colors,
    ColorScheme scheme,
  ) {
    final status = simulationStatus;
    if (status == null) {
      // 非模擬模式：灰色「限 X 天」
      return (
        '限 ${node.slaDays} 天',
        colors.statsCardBackground,
        colors.subtleText,
      );
    }
    switch (status) {
      case SimulationStatus.completed:
        return ('已通過', colors.actionSuccess.withValues(alpha: 0.18), colors.actionSuccess);
      case SimulationStatus.inProgress:
        return (
          '進行中 $simulationOffsetDays/${node.slaDays} 天',
          colors.actionWarning.withValues(alpha: 0.18),
          colors.actionWarning,
        );
      case SimulationStatus.expired:
        return (
          '已過期 $simulationOffsetDays 天',
          scheme.error.withValues(alpha: 0.18),
          scheme.error,
        );
      case SimulationStatus.pending:
        return ('未開始', colors.statsCardBackground, colors.subtleText);
      case SimulationStatus.unlimited:
        return ('不限期', colors.statsCardBackground, colors.subtleText);
    }
  }

  String _buildTitle() {
    if (node.isApplicantOrigin) return '申請起點';
    if (node.approverMode == SignOffApproverMode.applicantSelf) {
      return '申請人本人';
    }
    if (node.approverMode == SignOffApproverMode.applicantAncestorManager) {
      return node.applicantAncestorOffset <= 1
          ? '申請人直屬主管'
          : '申請人上 ${node.applicantAncestorOffset} 層主管';
    }
    if (node.approverMode == SignOffApproverMode.applicantManagerAtDepth) {
      return _depthLabel(node.applicantTargetDepthLevel);
    }
    return department?.name ?? '（未指定部門）';
  }

  /// 將 depthLevel 轉為通用層級名稱（與 SignOffService._depthLabel 對齊）。
  /// 不依賴特定組織命名 — 僅顯示 L${N} 主管。
  String _depthLabel(int depth) => 'L$depth 主管';

  String _buildSubtitle() {
    if (node.isApplicantOrigin) {
      return '申請發起者（虛擬）';
    }
    final typeLabel = node.nodeType.label;
    final modeLabel = node.approverMode.label;
    return '$typeLabel · $modeLabel';
  }

  IconData _iconForNode() {
    if (node.isApplicantOrigin) return Icons.person_pin_circle_outlined;
    if (node.approverMode == SignOffApproverMode.applicantSelf) {
      return Icons.person_outline;
    }
    if (node.approverMode == SignOffApproverMode.applicantAncestorManager) {
      return Icons.supervisor_account_outlined;
    }
    if (node.approverMode == SignOffApproverMode.applicantManagerAtDepth) {
      return Icons.business_center_outlined;
    }
    switch (node.nodeType) {
      case SignOffNodeType.approve:
        return Icons.check_circle_outline;
      case SignOffNodeType.countersign:
        return Icons.groups_2_outlined;
      case SignOffNodeType.notify:
        return Icons.notifications_none;
    }
  }
}
