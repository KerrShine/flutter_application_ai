import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/enum/submission_view_mode.dart';
import 'package:flutter_application_ai/model/sign_off_instance.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// signOff 列表通用元件 — 同時用於「我的申請」與「待我簽核」。
///
/// 差異由 [mode] 控制：
/// - viewer：card 點擊進 viewer mode 詳情頁；pending+isEditableByApplicant 顯示編輯 icon
/// - reviewer：card 點擊進 reviewer mode 詳情頁（顯示動作面板）；無編輯 icon
class ApplicationSubmissionSectionWidget extends StatelessWidget {
  final List<SignOffInstance> signOffs;
  final String title;
  final SubmissionViewMode mode;

  const ApplicationSubmissionSectionWidget({
    super.key,
    required this.signOffs,
    this.title = '我的申請紀錄',
    this.mode = SubmissionViewMode.viewer,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '$title（${signOffs.length}）',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.listTitleText,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: signOffs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = signOffs[index];
            return _SignOffCard(item: item, colors: colors, mode: mode);
          },
        ),
      ],
    );
  }
}

class _SignOffCard extends StatelessWidget {
  final SignOffInstance item;
  final FormApplicationThemeColors colors;
  final SubmissionViewMode mode;

  const _SignOffCard({
    required this.item,
    required this.colors,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = _statusIconColor(item.status);
    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.go(
            '/home/submission/${item.signOffId}',
            extra: {'mode': mode.code},
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _statusIcon(item.status),
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.formName.isEmpty ? '(未命名表單)' : item.formName,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: TextSize.title,
                        fontWeight: FontWeight.w600,
                        color: colors.listTitleText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.submittedAt.isEmpty
                          ? '尚未送出'
                          : _formatTimestamp(item.submittedAt),
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: TextSize.body,
                        color: colors.listSubtitleText,
                      ),
                    ),
                    if (_shouldShowCurrentApprover()) ...[
                      const SizedBox(height: 4),
                      _buildCurrentApproverRow(context, textTheme),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(status: item.status, colors: colors),
              if (mode == SubmissionViewMode.viewer &&
                  item.isEditableByApplicant) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: '編輯本筆',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colors.listSubtitleText,
                  ),
                  onPressed: () => context.go(
                    RouteName.formRunPage,
                    extra: {
                      'formId': item.formId,
                      'bindingId': '',
                      'signOffId': item.signOffId,
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusIconColor(LeaveSignOffStatus status) {
    switch (status) {
      case LeaveSignOffStatus.approved:
        return colors.submittedIcon;
      case LeaveSignOffStatus.rejected:
        return colors.errorColor;
      case LeaveSignOffStatus.inReview:
        return colors.inReviewIcon;
      case LeaveSignOffStatus.withdrawn:
        return colors.withdrawnIcon;
      case LeaveSignOffStatus.pending:
        return colors.pendingIcon;
    }
  }

  IconData _statusIcon(LeaveSignOffStatus status) {
    switch (status) {
      case LeaveSignOffStatus.approved:
        return Icons.check_circle;
      case LeaveSignOffStatus.rejected:
        return Icons.cancel;
      case LeaveSignOffStatus.withdrawn:
        return Icons.undo;
      case LeaveSignOffStatus.inReview:
        return Icons.autorenew;
      case LeaveSignOffStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  /// 是否要顯示「目前簽核者」列 — 僅進行中（pending/inReview）且 stepIndex 有效。
  bool _shouldShowCurrentApprover() {
    if (item.status != LeaveSignOffStatus.pending &&
        item.status != LeaveSignOffStatus.inReview) {
      return false;
    }
    if (item.currentStepIndex < 0) return false;
    return item.currentApproverName.isNotEmpty ||
        item.resolvedChainSnapshot.isNotEmpty;
  }

  /// 從 resolvedChainSnapshot 取當前關卡的代理人資訊（若有）。
  /// 回傳 (allowAgentFallback, agentName)；找不到時 (false, '')。
  (bool, String) _currentAgentInfo() {
    final snapshot = item.resolvedChainSnapshot;
    if (snapshot.isEmpty) return (false, '');
    // snapshot 包含申請起點，須過濾後再用 currentStepIndex 對應
    final approvers =
        snapshot.where((m) => m['description'] != '申請起點').toList();
    final idx = item.currentStepIndex;
    if (idx < 0 || idx >= approvers.length) return (false, '');
    final current = approvers[idx];
    final allow = current['allowAgentFallback'] as bool? ?? false;
    final agentName = current['agentName']?.toString() ?? '';
    return (allow, agentName);
  }

  Widget _buildCurrentApproverRow(BuildContext context, TextTheme textTheme) {
    final (allowAgent, agentName) = _currentAgentInfo();
    final hasAgent = allowAgent && agentName.isNotEmpty;
    final approverName = item.currentApproverName.isEmpty
        ? '（未指定）'
        : item.currentApproverName;
    return Row(
      children: [
        Icon(
          Icons.person_outline,
          size: 14,
          color: colors.listSubtitleText,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '目前簽核者：$approverName',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: TextSize.body,
              color: colors.listSubtitleText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasAgent) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.inReviewIcon.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: colors.inReviewIcon.withValues(alpha: 0.4)),
            ),
            child: Text(
              '代理：$agentName',
              style: TextStyle(
                fontSize: TextSize.small,
                color: colors.inReviewIcon,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// ISO 字串顯示用：去掉毫秒與 Z，保留到秒。
  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
          '${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return iso;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final LeaveSignOffStatus status;
  final FormApplicationThemeColors colors;

  const _StatusChip({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: TextSize.small,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(LeaveSignOffStatus status) {
    switch (status) {
      case LeaveSignOffStatus.approved:
        return colors.submittedIcon;
      case LeaveSignOffStatus.rejected:
        return colors.errorColor;
      case LeaveSignOffStatus.inReview:
        return colors.inReviewIcon;
      case LeaveSignOffStatus.withdrawn:
        return colors.withdrawnIcon;
      case LeaveSignOffStatus.pending:
        return colors.pendingIcon;
    }
  }
}
