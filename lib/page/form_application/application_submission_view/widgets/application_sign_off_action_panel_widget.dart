import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 簽核者動作面板 — 主要 3 顆按鈕（同意 / 拒絕 / 退回）+ 進階「⋮」選單。
///
/// 進階動作收進 PopupMenuButton：補件 / 轉派 / 加簽（加簽僅 [allowAddSigner] 為 true 時顯示）。
/// 拒絕 / 退回 / 補件需必填理由；轉派 / 加簽需選人；同意可選填意見。
class ApplicationSignOffActionPanelWidget extends StatelessWidget {
  final void Function(String comment) onApprove;
  final void Function(String comment) onReject;
  final void Function(String comment) onReturnBack;
  final void Function(String comment) onRequestSupplement;
  final void Function(String targetEmployeeId, String comment) onTransfer;
  final void Function(String addedEmployeeId, String comment) onAddApprover;

  /// 給轉派 / 加簽 dialog 內員工選擇用 — 通常從 state.signOff 對應的 employees 集合傳入。
  final List<EmployeeModel> employees;

  /// 當前關卡是否允許加簽 — 對應 SignOffCanvasNode.allowAddSigner。
  final bool allowAddSigner;

  const ApplicationSignOffActionPanelWidget({
    super.key,
    required this.onApprove,
    required this.onReject,
    required this.onReturnBack,
    required this.onRequestSupplement,
    required this.onTransfer,
    required this.onAddApprover,
    required this.employees,
    this.allowAddSigner = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
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
              Icon(
                Icons.gavel_outlined,
                size: 24,
                color: colors.inReviewIcon,
              ),
              const SizedBox(width: 10),
              Text(
                '簽核動作',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: TextSize.h2,
                  fontWeight: FontWeight.w700,
                  color: colors.listTitleText,
                ),
              ),
              const Spacer(),
              _buildAdvancedMenu(context, colors),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: '同意',
                  icon: Icons.check_circle_outline,
                  color: colors.submittedIcon,
                  onPressed: () => _openCommentDialog(
                    context,
                    title: '確認同意此申請？',
                    commentRequired: false,
                    primaryLabel: '同意',
                    primaryColor: colors.submittedIcon,
                    onSubmit: onApprove,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: '拒絕',
                  icon: Icons.cancel_outlined,
                  color: colors.errorColor,
                  onPressed: () => _openCommentDialog(
                    context,
                    title: '拒絕此申請（必填理由）',
                    commentRequired: true,
                    primaryLabel: '拒絕',
                    primaryColor: colors.errorColor,
                    onSubmit: onReject,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: '退回',
                  icon: Icons.undo,
                  color: colors.pendingIcon,
                  onPressed: () => _openCommentDialog(
                    context,
                    title: '退回申請人（必填理由）',
                    commentRequired: true,
                    primaryLabel: '退回',
                    primaryColor: colors.pendingIcon,
                    onSubmit: onReturnBack,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedMenu(
    BuildContext context,
    FormApplicationThemeColors colors,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: colors.listSubtitleText),
      tooltip: '進階動作',
      onSelected: (value) {
        switch (value) {
          case 'supplement':
            _openCommentDialog(
              context,
              title: '要求補件（必填說明）',
              hint: '請說明需補何資料',
              commentRequired: true,
              primaryLabel: '送出補件要求',
              primaryColor: colors.pendingIcon,
              onSubmit: onRequestSupplement,
            );
            break;
          case 'transfer':
            _openEmployeePickerDialog(
              context,
              title: '轉派此關（選擇接手者）',
              primaryLabel: '轉派',
              primaryColor: colors.inReviewIcon,
              commentHint: '（選填）轉派說明',
              onSubmit: onTransfer,
            );
            break;
          case 'addApprover':
            _openEmployeePickerDialog(
              context,
              title: '加簽（在下一關插入新簽核者）',
              primaryLabel: '加簽',
              primaryColor: colors.submittedIcon,
              commentHint: '（選填）加簽理由',
              onSubmit: onAddApprover,
            );
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'supplement',
          child: _menuRow(Icons.assignment_late_outlined, '補件',
              color: colors.pendingIcon),
        ),
        PopupMenuItem(
          value: 'transfer',
          child: _menuRow(Icons.swap_horizontal_circle_outlined, '轉派',
              color: colors.inReviewIcon),
        ),
        if (allowAddSigner)
          PopupMenuItem(
            value: 'addApprover',
            child: _menuRow(Icons.person_add_alt_outlined, '加簽',
                color: colors.submittedIcon),
          ),
      ],
    );
  }

  Widget _menuRow(IconData icon, String label, {required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  void _openCommentDialog(
    BuildContext context, {
    required String title,
    String hint = '',
    required bool commentRequired,
    required String primaryLabel,
    required Color primaryColor,
    required void Function(String comment) onSubmit,
  }) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final comment = controller.text.trim();
            final canSubmit = !commentRequired || comment.isNotEmpty;
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 480,
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: hint.isNotEmpty
                        ? hint
                        : (commentRequired ? '請輸入理由' : '（選填）填寫意見'),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: canSubmit
                      ? () {
                          Navigator.pop(dialogContext);
                          onSubmit(comment);
                        }
                      : null,
                  style: FilledButton.styleFrom(backgroundColor: primaryColor),
                  child: Text(primaryLabel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 員工選擇 + 意見 dialog — 給 transfer / addApprover 使用。
  /// 提供搜尋框過濾在職員工；確認後 callback (employeeId, comment)。
  void _openEmployeePickerDialog(
    BuildContext context, {
    required String title,
    required String primaryLabel,
    required Color primaryColor,
    required String commentHint,
    required void Function(String employeeId, String comment) onSubmit,
  }) {
    final searchCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    String? selectedId;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final keyword = searchCtrl.text.trim().toLowerCase();
            final filtered = employees
                .where((e) => e.isActive)
                .where((e) =>
                    keyword.isEmpty ||
                    e.employeeName.toLowerCase().contains(keyword) ||
                    e.employeeCode.toLowerCase().contains(keyword))
                .toList();
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 520,
                height: 480,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        labelText: '搜尋姓名 / 員工代碼',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('沒有符合條件的員工'))
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final emp = filtered[i];
                                return RadioListTile<String>(
                                  value: emp.employeeId,
                                  groupValue: selectedId,
                                  onChanged: (v) =>
                                      setState(() => selectedId = v),
                                  title: Text(
                                    '${emp.employeeName} (${emp.employeeCode})',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(emp.roleName.isEmpty
                                      ? '—'
                                      : emp.roleName),
                                  dense: true,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: commentHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: selectedId == null
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                          onSubmit(selectedId!, commentCtrl.text.trim());
                        },
                  style: FilledButton.styleFrom(backgroundColor: primaryColor),
                  child: Text(primaryLabel),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: TextSize.title,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.45), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
