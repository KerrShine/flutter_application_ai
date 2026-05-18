import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/sign_off_action_record.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 簽核軌跡列表內的單筆動作記錄。
///
/// 視覺：左側依動作類型的彩色 border + 動作 chip + 簽核者姓名 + 時間。
/// 代簽 / 轉派 / 加簽會額外顯示對象 chip（透過 [resolvedChain] / [employees] 反查姓名）。
class SignOffHistoryRow extends StatelessWidget {
  final SignOffActionRecord record;
  final FormApplicationThemeColors colors;
  final List<ResolvedApprover> resolvedChain;
  final List<EmployeeModel> employees;

  const SignOffHistoryRow({
    super.key,
    required this.record,
    required this.colors,
    this.resolvedChain = const [],
    this.employees = const [],
  });

  /// 從 chain / employees 反查 employeeId 對應姓名；找不到回 employeeId。
  String _lookupName(String employeeId) {
    if (employeeId.isEmpty) return '';
    for (final approver in resolvedChain) {
      if (approver.approverEmployeeIds.contains(employeeId) &&
          approver.approverName.isNotEmpty) {
        return approver.approverName;
      }
    }
    for (final emp in employees) {
      if (emp.employeeId == employeeId && emp.employeeName.isNotEmpty) {
        return emp.employeeName;
      }
    }
    return employeeId;
  }

  /// 「代簽」chip — 表示 principalApproverId 的人本應簽核但由 approverId 代簽
  Widget _agentDelegateChip(BuildContext context, String principalId) {
    final principalName = _lookupName(principalId);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.inReviewIcon.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.inReviewIcon.withValues(alpha: 0.4)),
      ),
      child: Text(
        '代 $principalName 簽',
        style: textTheme.bodySmall?.copyWith(
          fontSize: TextSize.small,
          color: colors.inReviewIcon,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 「轉派 / 加簽 → 對象」chip — 顯示 targetRef 對應姓名
  Widget _targetChip(BuildContext context, String prefix, String targetId) {
    final targetName = _lookupName(targetId);
    final textTheme = Theme.of(context).textTheme;
    final accent = colors.inReviewIcon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$prefix $targetName',
        style: textTheme.bodySmall?.copyWith(
          fontSize: TextSize.small,
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

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
                child: Row(
                  children: [
                    Flexible(
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
                    if (record.principalApproverId.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _agentDelegateChip(context, record.principalApproverId),
                    ],
                    if (record.actionType == SignOffActionType.transfer &&
                        record.targetRef.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _targetChip(context, '轉給', record.targetRef),
                    ],
                    if (record.actionType == SignOffActionType.addApprover &&
                        record.targetRef.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _targetChip(context, '加簽', record.targetRef),
                    ],
                  ],
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
      case SignOffActionType.autoNotify:
        // 自動通知 — 系統推進 notify 節點時自動產生
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
