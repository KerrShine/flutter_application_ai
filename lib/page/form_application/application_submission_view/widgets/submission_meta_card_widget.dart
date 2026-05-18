import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/sign_off_instance.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// submission_view_page 頂部的 meta 卡 — 顯示申請人 / 送出時間 / 狀態 / 申請編號。
class SubmissionMetaCardWidget extends StatelessWidget {
  final SignOffInstance signOff;

  const SubmissionMetaCardWidget({super.key, required this.signOff});

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(signOff.status, colors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  signOff.formName.isEmpty ? '(未命名表單)' : signOff.formName,
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: TextSize.h1,
                    fontWeight: FontWeight.w700,
                    color: colors.listTitleText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  signOff.status.label,
                  style: TextStyle(
                    fontSize: TextSize.title,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: colors.cardBorder, height: 1),
          const SizedBox(height: 20),
          _MetaRow(
            label: '申請人',
            value: signOff.applicantName.isEmpty
                ? signOff.applicantId
                : '${signOff.applicantName}  (${signOff.applicantId})',
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: 14),
          _MetaRow(
            label: '送出時間',
            value: _formatTimestamp(signOff.submittedAt),
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: 14),
          _MetaRow(
            label: '申請編號',
            value: signOff.signOffId,
            colors: colors,
            textTheme: textTheme,
            monospace: true,
          ),
          // 依 sectionsSnapshot 內 label 關鍵字找對應欄位值（請假表單專屬資訊）。
          // 其他表單若無此 label 則整列不渲染。
          ..._buildLeaveSpecificRows(signOff, colors, textTheme),
        ],
      ),
    );
  }

  /// 找 sectionsSnapshot 中 label 含 [keywords] 之一的欄位 → 用其 itemId 取值。
  /// 找不到回空字串。
  String _findValueByLabel(
    SignOffInstance signOff,
    List<String> keywords,
  ) {
    for (final sectionMap in signOff.sectionsSnapshot) {
      final items = (sectionMap['items'] as List?) ?? const [];
      for (final itemMap in items) {
        if (itemMap is! Map) continue;
        final text = (itemMap['text'] as String?) ?? '';
        final fieldName = (itemMap['fieldName'] as String?) ?? '';
        final id = (itemMap['id'] as String?) ?? '';
        final hit = keywords
            .any((kw) => text.contains(kw) || fieldName.contains(kw));
        if (hit && id.isNotEmpty) {
          final raw = signOff.fieldValues[id];
          return raw == null ? '' : raw.toString();
        }
      }
    }
    return '';
  }

  /// 找 sectionsSnapshot 中有 computedFieldKey 且 text 含 [keywords] 之一的
  /// label 欄位 → 用 computedFieldKey 從 computedFields 取計算值。
  String _findComputedByLabel(
    SignOffInstance signOff,
    List<String> keywords,
  ) {
    for (final sectionMap in signOff.sectionsSnapshot) {
      final items = (sectionMap['items'] as List?) ?? const [];
      for (final itemMap in items) {
        if (itemMap is! Map) continue;
        final key = (itemMap['computedFieldKey'] as String?) ?? '';
        if (key.isEmpty) continue;
        final text = (itemMap['text'] as String?) ?? '';
        final fieldName = (itemMap['fieldName'] as String?) ?? '';
        final hit = keywords
            .any((kw) => text.contains(kw) || fieldName.contains(kw));
        if (hit) {
          return signOff.computedFields[key] ?? '';
        }
      }
    }
    return '';
  }

  List<Widget> _buildLeaveSpecificRows(
    SignOffInstance signOff,
    FormApplicationThemeColors colors,
    TextTheme textTheme,
  ) {
    final startDate = _findValueByLabel(signOff, ['開始日期']);
    final endDate = _findValueByLabel(signOff, ['結束日期']);
    final leaveDays = _findComputedByLabel(signOff, ['天']);
    final agent = _findValueByLabel(signOff, ['代理人']);
    final rows = <Widget>[];
    if (startDate.isNotEmpty) {
      rows
        ..add(const SizedBox(height: 14))
        ..add(_MetaRow(
          label: '開始日期',
          value: startDate,
          colors: colors,
          textTheme: textTheme,
        ));
    }
    if (endDate.isNotEmpty) {
      rows
        ..add(const SizedBox(height: 14))
        ..add(_MetaRow(
          label: '結束日期',
          value: endDate,
          colors: colors,
          textTheme: textTheme,
        ));
    }
    if (leaveDays.isNotEmpty) {
      rows
        ..add(const SizedBox(height: 14))
        ..add(_MetaRow(
          label: '請假天數',
          value: '$leaveDays 天',
          colors: colors,
          textTheme: textTheme,
        ));
    }
    if (agent.isNotEmpty) {
      rows
        ..add(const SizedBox(height: 14))
        ..add(_MetaRow(
          label: '代理人',
          value: agent,
          colors: colors,
          textTheme: textTheme,
        ));
    }
    return rows;
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

  String _formatTimestamp(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
          '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
    } catch (_) {
      return iso;
    }
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final FormApplicationThemeColors colors;
  final TextTheme textTheme;
  final bool monospace;

  const _MetaRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: textTheme.titleLarge?.copyWith(
              fontSize: TextSize.title,
              fontWeight: FontWeight.w500,
              color: colors.listSubtitleText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: textTheme.titleLarge?.copyWith(
              fontSize: TextSize.title,
              fontWeight: FontWeight.w600,
              color: colors.listTitleText,
              fontFamily: monospace ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }
}
