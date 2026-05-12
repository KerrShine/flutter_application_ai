import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/leave_sign_off_model.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 簽核狀態資訊卡 — 顯示當前 sign-off 的整體狀態、目前簽核者、最新意見與簽核軌跡。
///
/// 風格參照 form_launch_permission_editor 的 EditorSummarySidebarWidget：
/// header 區（icon + 標題） + 三個 stat card（狀態 / 簽核者 / 意見） + 簽核軌跡列表。
class SignOffStatusWidget extends StatelessWidget {
  final LeaveSignOffModel signOff;
  final List<ResolvedApprover> resolvedChain;

  const SignOffStatusWidget({
    super.key,
    required this.signOff,
    this.resolvedChain = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final statusColor = _statusColor(signOff.status, colors);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, colors),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatCard(
                  label: '整體狀態',
                  value: signOff.status.label,
                  valueColor: statusColor,
                  colors: colors,
                ),
                const SizedBox(height: 12),
                _StatCard(
                  label: '目前簽核者',
                  value: _formatCurrentApprover(),
                  colors: colors,
                ),
                const SizedBox(height: 12),
                _StatCard(
                  label: '最新意見',
                  value: signOff.latestComment.isEmpty
                      ? '（尚無意見）'
                      : signOff.latestComment,
                  colors: colors,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.cardBorder),
          _buildChainSection(context, colors),
          Divider(height: 1, color: colors.cardBorder),
          _buildHistorySection(context, colors),
        ],
      ),
    );
  }

  Widget _buildChainSection(
    BuildContext context,
    FormApplicationThemeColors colors,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '完整簽核流程',
                style: textTheme.titleLarge?.copyWith(
                  fontSize: TextSize.title,
                  fontWeight: FontWeight.w700,
                  color: colors.listTitleText,
                ),
              ),
              const SizedBox(width: 10),
              if (resolvedChain.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.chipBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${resolvedChain.length} 關',
                    style: TextStyle(
                      fontSize: TextSize.small,
                      fontWeight: FontWeight.w600,
                      color: colors.listSubtitleText,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (resolvedChain.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: colors.chipBackground.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                signOff.templateId.isEmpty
                    ? '（此申請未綁定簽核流程模板）'
                    : '（無法解析簽核流程）',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: TextSize.body,
                  color: colors.emptyText,
                ),
              ),
            )
          else
            ...resolvedChain.asMap().entries.map((entry) {
              final index = entry.key;
              final approver = entry.value;
              final isCurrent = _isCurrentStep(index);
              final isPast = index < _currentStepIndex();
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == resolvedChain.length - 1 ? 0 : 10,
                ),
                child: _ChainStepRow(
                  stepNumber: index + 1,
                  approver: approver,
                  isCurrent: isCurrent,
                  isPast: isPast,
                  colors: colors,
                ),
              );
            }),
        ],
      ),
    );
  }

  /// 當前進行到第幾步（0-based） — 用 actionHistory.length 推算。
  /// 申請起點（origin）不計入步數。
  int _currentStepIndex() {
    // actionHistory 每筆代表一次簽核動作；考慮 origin 佔 index 0
    final originOffset = resolvedChain.isNotEmpty &&
            resolvedChain.first.description == '申請起點'
        ? 1
        : 0;
    return signOff.actionHistory.length + originOffset;
  }

  bool _isCurrentStep(int index) {
    if (signOff.status == LeaveSignOffStatus.approved ||
        signOff.status == LeaveSignOffStatus.rejected ||
        signOff.status == LeaveSignOffStatus.withdrawn) {
      return false;
    }
    return index == _currentStepIndex();
  }

  Widget _buildHeader(
    BuildContext context,
    FormApplicationThemeColors colors,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final color = colors.inReviewIcon;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fact_check_outlined, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '目前簽核狀態',
              style: textTheme.headlineMedium?.copyWith(
                fontSize: TextSize.h2,
                fontWeight: FontWeight.w700,
                color: colors.listTitleText,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.chipBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${signOff.actionHistory.length} 筆軌跡',
              style: TextStyle(
                fontSize: TextSize.small,
                fontWeight: FontWeight.w600,
                color: colors.listSubtitleText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    FormApplicationThemeColors colors,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '簽核軌跡',
            style: textTheme.titleLarge?.copyWith(
              fontSize: TextSize.title,
              fontWeight: FontWeight.w700,
              color: colors.listTitleText,
            ),
          ),
          const SizedBox(height: 12),
          if (signOff.actionHistory.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: colors.chipBackground.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '尚無簽核紀錄',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: TextSize.body,
                  color: colors.emptyText,
                ),
              ),
            )
          else
            ...signOff.actionHistory.asMap().entries.map((entry) {
              final isLast = entry.key == signOff.actionHistory.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: _HistoryRow(record: entry.value, colors: colors),
              );
            }),
        ],
      ),
    );
  }

  String _formatCurrentApprover() {
    switch (signOff.status) {
      case LeaveSignOffStatus.approved:
        return '（已完成簽核）';
      case LeaveSignOffStatus.rejected:
        return '（流程已終止）';
      case LeaveSignOffStatus.withdrawn:
        return '（申請已撤回）';
      case LeaveSignOffStatus.pending:
      case LeaveSignOffStatus.inReview:
        return _resolveCurrentApproverLabel();
    }
  }

  /// 計算當前簽核者顯示字串。失敗情境給明確診斷訊息，方便排查。
  String _resolveCurrentApproverLabel() {
    // signOff 自身存的 currentApprover 優先（未來簽核引擎接管後寫入）
    if (signOff.currentApproverName.isNotEmpty ||
        signOff.currentApproverId.isNotEmpty) {
      return signOff.currentApproverName.isEmpty
          ? signOff.currentApproverId
          : '${signOff.currentApproverName}  (${signOff.currentApproverId})';
    }

    // resolvedChain 為空：分原因說明
    if (resolvedChain.isEmpty) {
      if (signOff.templateId.isEmpty) {
        return '（此申請未綁定簽核流程模板）';
      }
      return '（簽核流程模板「${signOff.templateId}」載入失敗或不存在）';
    }

    // 過濾掉申請起點，純取簽核節點清單
    final approvers = resolvedChain
        .where((r) => r.description != '申請起點')
        .toList();
    if (approvers.isEmpty) {
      return '（簽核流程模板未設定任何簽核節點）';
    }

    // actionHistory.length = 已完成的簽核步數
    final completedSteps = signOff.actionHistory.length;
    if (completedSteps >= approvers.length) {
      return '（所有節點已完成，等待結案）';
    }

    final current = approvers[completedSteps];
    if (!current.resolved) {
      return '${current.description}  ⚠ ${current.unresolvedReason}';
    }
    final name = current.approverName.isEmpty
        ? '（尚未指派人員）'
        : current.approverName;
    return current.description.isEmpty
        ? name
        : '$name｜${current.description}';
  }

  Color _statusColor(
    LeaveSignOffStatus status,
    FormApplicationThemeColors colors,
  ) {
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

class _ChainStepRow extends StatelessWidget {
  final int stepNumber;
  final ResolvedApprover approver;
  final bool isCurrent;
  final bool isPast;
  final FormApplicationThemeColors colors;

  const _ChainStepRow({
    required this.stepNumber,
    required this.approver,
    required this.isCurrent,
    required this.isPast,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = _stepColor(colors);
    final fade = !isCurrent && !isPast;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent
            ? accent.withValues(alpha: 0.12)
            : colors.chipBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? accent.withValues(alpha: 0.5)
              : colors.cardBorder,
          width: isCurrent ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isCurrent ? 0.2 : 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: isPast
                ? Icon(Icons.check, size: 18, color: accent)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: TextSize.body,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  approver.description.isEmpty
                      ? '節點 ${approver.nodeId}'
                      : approver.description,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: TextSize.title,
                    fontWeight: FontWeight.w600,
                    color: fade
                        ? colors.listSubtitleText
                        : colors.listTitleText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (approver.approverName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    approver.approverName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: TextSize.body,
                      color: colors.listSubtitleText,
                    ),
                  ),
                ],
                if (!approver.resolved &&
                    approver.unresolvedReason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '⚠ ${approver.unresolvedReason}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: TextSize.body,
                      color: colors.errorColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.5)),
              ),
              child: Text(
                '進行中',
                style: TextStyle(
                  fontSize: TextSize.small,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _stepColor(FormApplicationThemeColors colors) {
    if (isCurrent) return colors.inReviewIcon;
    if (isPast) return colors.submittedIcon;
    return colors.withdrawnIcon;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FormApplicationThemeColors colors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.chipBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: TextSize.body,
              color: colors.listSubtitleText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontSize: TextSize.title,
              fontWeight: FontWeight.w700,
              color: valueColor ?? colors.listTitleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final SignOffActionRecord record;
  final FormApplicationThemeColors colors;

  const _HistoryRow({required this.record, required this.colors});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actionColor = _actionColor(record.actionType, colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.chipBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: actionColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: actionColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  record.actionType.label,
                  style: TextStyle(
                    fontSize: TextSize.small,
                    fontWeight: FontWeight.w700,
                    color: actionColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  record.approverName.isEmpty
                      ? record.approverId
                      : '${record.approverName} (${record.approverId})',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: TextSize.title,
                    fontWeight: FontWeight.w600,
                    color: colors.listTitleText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTimestamp(record.actionAt),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: TextSize.body,
                  color: colors.listSubtitleText,
                ),
              ),
            ],
          ),
          if (record.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.comment,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: TextSize.body,
                color: colors.listSubtitleText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _actionColor(
    SignOffActionType type,
    FormApplicationThemeColors colors,
  ) {
    switch (type) {
      case SignOffActionType.approve:
        return colors.submittedIcon;
      case SignOffActionType.reject:
        return colors.errorColor;
      case SignOffActionType.returnBack:
        return colors.pendingIcon;
      case SignOffActionType.requestSupplement:
        return colors.inReviewIcon;
      case SignOffActionType.transfer:
      case SignOffActionType.addApprover:
        return colors.withdrawnIcon;
    }
  }

  String _formatTimestamp(String iso) {
    if (iso.isEmpty) return '—';
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
