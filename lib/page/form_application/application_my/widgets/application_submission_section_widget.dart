import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/model/leave_sign_off_model.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

class ApplicationSubmissionSectionWidget extends StatelessWidget {
  final List<LeaveSignOffModel> signOffs;

  const ApplicationSubmissionSectionWidget({
    super.key,
    required this.signOffs,
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
            '我的申請紀錄（${signOffs.length}）',
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
            return _SignOffCard(item: item, colors: colors);
          },
        ),
      ],
    );
  }
}

class _SignOffCard extends StatelessWidget {
  final LeaveSignOffModel item;
  final FormApplicationThemeColors colors;

  const _SignOffCard({required this.item, required this.colors});

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
          context.go('/home/submission/${item.signOffId}');
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(status: item.status, colors: colors),
              if (item.status == LeaveSignOffStatus.pending) ...[
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
