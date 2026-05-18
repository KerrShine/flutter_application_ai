import 'package:flutter/material.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 「完整簽核流程」section 內每一關節點列。
///
/// 視覺三態：
/// - `isCurrent` → 強調框 + 進行中 chip
/// - `isPast`    → 圓圈顯示打勾
/// - 其他       → 灰底淡色（未到）
class SignOffChainStepRow extends StatelessWidget {
  final int stepNumber;
  final ResolvedApprover approver;
  final bool isCurrent;
  final bool isPast;
  final FormApplicationThemeColors colors;

  const SignOffChainStepRow({
    super.key,
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
          color: isCurrent ? accent.withValues(alpha: 0.5) : colors.cardBorder,
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
                    color:
                        fade ? colors.listSubtitleText : colors.listTitleText,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
