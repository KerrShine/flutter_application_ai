import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/enum/sign_off_approver_mode.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_choice.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 開啟「完整鏈解析預覽」dialog。
///
/// 設定者驗證 6 種 approverMode + Path Rules 在某個假設申請人 + 假設 form data
/// 下，真的解出對的人。提交申請的真實邏輯由 Phase B 補上，此 dialog 純前端模擬。
Future<void> showSignOffPreviewChainDialog({
  required BuildContext context,
  required SignOffTemplateModel template,
  required List<EmployeeModel> employees,
  required List<SignOffConditionFieldChoice> formFields,
  required SignOffService service,
  required VoidCallback onRequestOpenEmpAgentPage,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('預覽簽核鏈'),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: _PreviewChainBody(
              template: template,
              employees: employees,
              formFields: formFields,
              service: service,
              onRequestOpenEmpAgentPage: () {
                Navigator.of(dialogContext).pop();
                onRequestOpenEmpAgentPage();
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('關閉'),
          ),
        ],
      );
    },
  );
}

class _PreviewChainBody extends StatefulWidget {
  final SignOffTemplateModel template;
  final List<EmployeeModel> employees;
  final List<SignOffConditionFieldChoice> formFields;
  final SignOffService service;
  final VoidCallback onRequestOpenEmpAgentPage;

  const _PreviewChainBody({
    required this.template,
    required this.employees,
    required this.formFields,
    required this.service,
    required this.onRequestOpenEmpAgentPage,
  });

  @override
  State<_PreviewChainBody> createState() => _PreviewChainBodyState();
}

class _PreviewChainBodyState extends State<_PreviewChainBody> {
  String _applicantId = '';
  final Map<String, String> _formData = {};
  List<ResolvedApprover>? _result;
  String? _errorMessage;
  bool _loading = false;

  EmployeeModel? get _selectedApplicant {
    if (_applicantId.isEmpty) return null;
    for (final e in widget.employees) {
      if (e.employeeId == _applicantId) return e;
    }
    return null;
  }

  Future<void> _runResolve() async {
    if (_applicantId.isEmpty) {
      setState(() {
        _errorMessage = '請先選擇申請人';
        _result = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final result = await widget.service.resolveApproverChain(
      template: widget.template,
      applicantEmployeeId: _applicantId,
      applicantFormData: Map.unmodifiable(_formData),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _result = result.data;
        _errorMessage = null;
      } else {
        _errorMessage = result.error ?? '解析失敗';
        _result = null;
      }
    });
  }

  SignOffCanvasNode? _findNodeById(String nodeId) {
    for (final n in widget.template.canvasNodes) {
      if (n.nodeId == nodeId) return n;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionTitle(context, '申請人'),
        const SizedBox(height: 6),
        _buildApplicantPicker(theme, colors),
        const SizedBox(height: 16),
        _sectionTitle(context, '表單資料（依當前選中表單欄位）'),
        const SizedBox(height: 6),
        _buildFormDataInputs(theme, colors),
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _loading ? null : _runResolve,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow, size: 18),
              label: Text(_loading ? '解析中...' : '執行解析'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (_result != null) ...[
          const Divider(),
          const SizedBox(height: 8),
          _sectionTitle(context, '解析結果（${_result!.length} 關）'),
          const SizedBox(height: 8),
          _buildResultList(theme, colors),
        ],
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildApplicantPicker(ThemeData theme, FormDesignThemeColors colors) {
    final activeEmployees = widget.employees.where((e) => e.isActive).toList()
      ..sort((a, b) => a.employeeName.compareTo(b.employeeName));

    if (activeEmployees.isEmpty) {
      return _buildHintBox(theme, colors,
          '尚無可選申請人 — 請先到員工管理建立員工資料。', theme.colorScheme.error);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _applicantId.isEmpty ? null : _applicantId,
          isExpanded: true,
          decoration: const InputDecoration(
            isDense: true,
            hintText: '選擇要模擬的申請人',
          ),
          items: activeEmployees
              .map((e) => DropdownMenuItem(
                    value: e.employeeId,
                    child: Text(
                      '${e.employeeName} '
                      '${e.roleName.isEmpty ? "" : "／${e.roleName}"}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _applicantId = v);
          },
        ),
        if (_selectedApplicant != null) ...[
          const SizedBox(height: 6),
          Text(
            '↳ 部門 ID：${_selectedApplicant!.departmentId.isEmpty ? "（未綁部門）" : _selectedApplicant!.departmentId}'
            ' · 角色：${_selectedApplicant!.roleName.isEmpty ? "—" : _selectedApplicant!.roleName}',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.subtleText),
          ),
        ],
      ],
    );
  }

  Widget _buildFormDataInputs(ThemeData theme, FormDesignThemeColors colors) {
    if (widget.formFields.isEmpty) {
      return _buildHintBox(
          theme,
          colors,
          '此表單尚未在「表單條件欄位」定義任何欄位 — '
          '無 form data 可填，Path Rules 將跑 default fallback。',
          colors.actionInfo);
    }
    return Column(
      children: [
        for (final f in widget.formFields) ...[
          TextFormField(
            key: ValueKey('preview_chain_${f.outputKey}'),
            initialValue: _formData[f.outputKey] ?? '',
            keyboardType: f.fieldType == ConditionFieldType.number
                ? const TextInputType.numberWithOptions(
                    decimal: true, signed: true)
                : TextInputType.text,
            decoration: InputDecoration(
              labelText: f.label,
              isDense: true,
              helperText: '${f.fieldType.label} · key=${f.outputKey}',
            ),
            onChanged: (value) {
              setState(() => _formData[f.outputKey] = value);
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildResultList(ThemeData theme, FormDesignThemeColors colors) {
    final list = _result!;
    if (list.isEmpty) {
      return _buildHintBox(theme, colors,
          '解析結果為空 — 模板可能無啟用節點，或所有節點被 path rules 過濾掉。',
          colors.actionWarning);
    }
    return Column(
      children: [
        for (var i = 0; i < list.length; i++) ...[
          _buildResultCard(theme, colors, i, list[i]),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildResultCard(
    ThemeData theme,
    FormDesignThemeColors colors,
    int index,
    ResolvedApprover r,
  ) {
    final ok = r.resolved;
    final accent = ok ? colors.actionSuccess : theme.colorScheme.error;
    final node = _findNodeById(r.nodeId);

    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                ok ? Icons.check_circle : Icons.error_outline,
                color: accent,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (ok)
            Text(
              '→ ${r.approverName.isEmpty ? "（無人）" : r.approverName}'
              '${r.approverRoleName.isEmpty ? "" : " ／ ${r.approverRoleName}"}',
              style: theme.textTheme.bodyMedium,
            )
          else
            Text(
              r.unresolvedReason.isEmpty ? '（未提供原因）' : r.unresolvedReason,
              style: theme.textTheme.bodySmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (node != null && node.slaDays > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.statsCardBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colors.subtleText.withValues(alpha: 0.3)),
              ),
              child: Text(
                '限 ${node.slaDays} 天',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.subtleText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (ok && r.allowAgentFallback) ...[
            const SizedBox(height: 6),
            _buildAgentRow(theme, colors, r,
                missingMessage: '未設代理人 — 此關卡需要備援'),
          ] else if (!ok &&
              node?.approverMode == SignOffApproverMode.applicantAgent) ...[
            const SizedBox(height: 6),
            _buildAgentRow(theme, colors, r,
                missingMessage: '申請人未設代理人'),
          ],
        ],
      ),
    );
  }

  Widget _buildAgentRow(
    ThemeData theme,
    FormDesignThemeColors colors,
    ResolvedApprover r, {
    required String missingMessage,
  }) {
    final hasAgent = r.agentEmployeeId.isNotEmpty;
    final color = hasAgent ? colors.actionSuccess : colors.actionWarning;
    return Row(
      children: [
        Icon(
          hasAgent
              ? Icons.swap_horiz
              : Icons.report_problem_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            hasAgent ? '代理人：${r.agentName}' : missingMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (!hasAgent)
          TextButton.icon(
            onPressed: widget.onRequestOpenEmpAgentPage,
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('前往設定'),
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  Widget _buildHintBox(
    ThemeData theme,
    FormDesignThemeColors colors,
    String text,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.subtleText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
