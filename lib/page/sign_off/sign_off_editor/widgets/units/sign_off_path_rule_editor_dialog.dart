import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/enum/sign_off_condition_operator.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_choice.dart';
import 'package:flutter_application_ai/model/sign_off_path_condition.dart';
import 'package:flutter_application_ai/model/sign_off_path_rule.dart';

/// 開啟 Path Rule 編輯對話框；確認後回傳更新後的 rule（取消回 null）。
///
/// `formFields` 來自 `SignOffService.loadFormFields(formId)`（讀 form_condition_field draft）。
/// 若空 list → dialog 顯示「請先到表單條件欄位定義」banner，呼叫 `onGoToBinding`。
Future<SignOffPathRule?> showSignOffPathRuleEditorDialog({
  required BuildContext context,
  required SignOffPathRule initialRule,
  required List<SignOffConditionFieldChoice> formFields,
  required List<SignOffCanvasNode> approverNodes,
  required VoidCallback onGoToBinding,
}) {
  SignOffPathRule current = initialRule;
  return showDialog<SignOffPathRule?>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(initialRule.name.isEmpty ? '新增規則' : '編輯規則：${initialRule.name}'),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: _RuleEditorBody(
              initialRule: initialRule,
              formFields: formFields,
              approverNodes: approverNodes,
              onGoToBinding: onGoToBinding,
              onChanged: (updated) => current = updated,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(current),
            child: const Text('確認'),
          ),
        ],
      );
    },
  );
}

class _RuleEditorBody extends StatefulWidget {
  final SignOffPathRule initialRule;
  final List<SignOffConditionFieldChoice> formFields;
  final List<SignOffCanvasNode> approverNodes;
  final VoidCallback onGoToBinding;
  final ValueChanged<SignOffPathRule> onChanged;

  const _RuleEditorBody({
    required this.initialRule,
    required this.formFields,
    required this.approverNodes,
    required this.onGoToBinding,
    required this.onChanged,
  });

  @override
  State<_RuleEditorBody> createState() => _RuleEditorBodyState();
}

class _RuleEditorBodyState extends State<_RuleEditorBody> {
  late TextEditingController _nameController;
  late bool _isDefault;

  /// 注意：`_fieldId` 儲存的是 fieldKey（form_condition_field 定義的條件欄位 key），
  /// 不是 DesignerItem.id 或 form_data_binding 的 outputKey。
  late String _fieldId;
  late ConditionFieldType _fieldType;
  late SignOffConditionOperator _operator;
  late TextEditingController _valueController;
  late TextEditingController _valueMaxController;
  late Set<String> _activatedNodeIds;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRule;
    _nameController = TextEditingController(text: r.name);
    _isDefault = r.condition == null;
    final c = r.condition;
    _fieldId = c?.fieldId ?? '';
    _fieldType = c?.fieldType ?? ConditionFieldType.string;
    _operator = c?.operator ?? SignOffConditionOperator.equal;
    _valueController = TextEditingController(text: c?.value ?? '');
    _valueMaxController = TextEditingController(text: c?.valueMax ?? '');
    _activatedNodeIds = r.activatedNodeIds.toSet();

    // 初始 fieldId 為空時，預設第一個欄位
    if (!_isDefault && _fieldId.isEmpty && widget.formFields.isNotEmpty) {
      final first = widget.formFields.first;
      _fieldId = first.outputKey;
      _fieldType = first.fieldType;
      _ensureOperatorApplicable();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _valueMaxController.dispose();
    super.dispose();
  }

  void _ensureOperatorApplicable() {
    if (!_operator.isApplicableTo(_fieldType)) {
      final list = SignOffConditionOperatorX.applicableFor(_fieldType);
      _operator = list.isNotEmpty ? list.first : SignOffConditionOperator.equal;
    }
  }

  void _onFieldChanged(String? newOutputKey) {
    if (newOutputKey == null) return;
    final field = widget.formFields.firstWhere(
      (f) => f.outputKey == newOutputKey,
      orElse: () => widget.formFields.first,
    );
    setState(() {
      _fieldId = field.outputKey;
      _fieldType = field.fieldType;
      _ensureOperatorApplicable();
      _emit();
    });
  }

  void _emit() {
    SignOffPathCondition? cond;
    if (!_isDefault) {
      final field =
          widget.formFields.cast<SignOffConditionFieldChoice?>().firstWhere(
                (f) => f?.outputKey == _fieldId,
                orElse: () => null,
              );
      cond = SignOffPathCondition(
        fieldId: _fieldId,
        fieldName: field?.label ?? _fieldId,
        fieldType: _fieldType,
        operator: _operator,
        value: _valueController.text.trim(),
        valueMax: _valueMaxController.text.trim(),
      );
    }
    widget.onChanged(SignOffPathRule(
      ruleId: widget.initialRule.ruleId,
      name: _nameController.text.trim(),
      condition: cond,
      activatedNodeIds: _activatedNodeIds.toList(),
      sortOrder: widget.initialRule.sortOrder,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('規則名稱', style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: '例：短假 / 大額採購',
            isDense: true,
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('預設規則 (Default)'),
          subtitle: const Text('啟用後此規則永遠 match，通常排在最後作為 fallback'),
          value: _isDefault,
          onChanged: (v) {
            setState(() {
              _isDefault = v;
              _emit();
            });
          },
        ),
        if (!_isDefault) ...[
          const Divider(),
          const SizedBox(height: 4),
          Text('條件', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (widget.formFields.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_outlined,
                          size: 18, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Text(
                        '本表單尚未定義條件欄位',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Path Rule 條件需要在「表單條件欄位」定義 fieldKey + 計算公式（如請假天數 = 結束日 - 開始日）；'
                    '請先到該頁完成定義再回來設定條件。',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                        widget.onGoToBinding();
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('前往表單條件欄位編輯器'),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                _buildFieldDropdown(),
                const SizedBox(height: 8),
                _buildOperatorDropdown(),
                const SizedBox(height: 8),
                _buildValueInputs(),
              ],
            ),
        ],
        const Divider(),
        const SizedBox(height: 4),
        Text('啟用節點 (${_activatedNodeIds.length} / ${widget.approverNodes.length})',
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          '勾選此規則命中後要啟用的簽核節點。未勾選 = 跳關。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final node in _sortedApproverNodes())
              FilterChip(
                label: Text('#${node.sortOrder} ${_nodeLabel(node)}'),
                selected: _activatedNodeIds.contains(node.nodeId),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _activatedNodeIds.add(node.nodeId);
                    } else {
                      _activatedNodeIds.remove(node.nodeId);
                    }
                    _emit();
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  List<SignOffCanvasNode> _sortedApproverNodes() {
    final list = List<SignOffCanvasNode>.from(widget.approverNodes)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  String _nodeLabel(SignOffCanvasNode node) {
    if (node.departmentId.isNotEmpty) return node.departmentId;
    return node.nodeId;
  }

  Widget _buildFieldDropdown() {
    return DropdownButtonFormField<String>(
      value: _fieldId.isEmpty ? null : _fieldId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: '比對欄位（fieldKey）',
        isDense: true,
      ),
      items: widget.formFields
          .map((f) => DropdownMenuItem(
                value: f.outputKey,
                child: Text(
                  '${f.label}（${f.fieldType.label}） · key=${f.outputKey}',
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: _onFieldChanged,
    );
  }

  Widget _buildOperatorDropdown() {
    final ops = SignOffConditionOperatorX.applicableFor(_fieldType);
    return DropdownButtonFormField<SignOffConditionOperator>(
      value: ops.contains(_operator) ? _operator : ops.first,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: '運算子',
        isDense: true,
      ),
      items: ops
          .map((op) => DropdownMenuItem(
                value: op,
                child: Text('${op.label} (${op.symbol})'),
              ))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() {
          _operator = v;
          _emit();
        });
      },
    );
  }

  Widget _buildValueInputs() {
    final isNumber = _fieldType == ConditionFieldType.number;
    final keyboard = isNumber
        ? const TextInputType.numberWithOptions(decimal: true, signed: true)
        : TextInputType.text;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _valueController,
            keyboardType: keyboard,
            decoration: const InputDecoration(
              labelText: '值',
              isDense: true,
            ),
            onChanged: (_) => _emit(),
          ),
        ),
        if (_operator.needsValueMax) ...[
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('~'),
          ),
          Expanded(
            child: TextField(
              controller: _valueMaxController,
              keyboardType: keyboard,
              decoration: const InputDecoration(
                labelText: '上限值',
                isDense: true,
              ),
              onChanged: (_) => _emit(),
            ),
          ),
        ],
      ],
    );
  }
}
