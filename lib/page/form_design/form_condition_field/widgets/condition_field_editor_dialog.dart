import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/condition_compute_function.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 結果容器：dialog 結束時帶回原 fieldKey（編輯模式用來定位舊定義）+ 新定義。
class ConditionFieldEditResult {
  final String originalFieldKey;
  final ConditionFieldDefinition definition;

  const ConditionFieldEditResult({
    required this.originalFieldKey,
    required this.definition,
  });
}

/// 新增 / 編輯條件欄位 dialog。
///
/// 流程：fieldKey + label + function → 依 function spec 動態決定 arg picker
/// （Direct = 單選；其他 = 多選且型別過濾），即時 validate fieldKey 唯一 + arg 數量型別。
Future<ConditionFieldEditResult?> showConditionFieldEditorDialog({
  required BuildContext context,
  required List<ConditionArgItemChoice> availableItems,
  required List<ConditionFieldDefinition> existingDefinitions,
  required ConditionFieldService service,
  ConditionFieldDefinition? initialDefinition,
}) {
  return showDialog<ConditionFieldEditResult?>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _ConditionFieldEditorDialog(
        availableItems: availableItems,
        existingDefinitions: existingDefinitions,
        service: service,
        initialDefinition: initialDefinition,
      );
    },
  );
}

class _ConditionFieldEditorDialog extends StatefulWidget {
  final List<ConditionArgItemChoice> availableItems;
  final List<ConditionFieldDefinition> existingDefinitions;
  final ConditionFieldService service;
  final ConditionFieldDefinition? initialDefinition;

  const _ConditionFieldEditorDialog({
    required this.availableItems,
    required this.existingDefinitions,
    required this.service,
    this.initialDefinition,
  });

  @override
  State<_ConditionFieldEditorDialog> createState() =>
      _ConditionFieldEditorDialogState();
}

class _ConditionFieldEditorDialogState
    extends State<_ConditionFieldEditorDialog> {
  late TextEditingController _fieldKeyController;
  late TextEditingController _labelController;
  late ConditionComputeFunction _function;
  late List<String> _argItemIds;
  bool _userTouchedFieldKey = false;
  String? _errorMessage;

  bool get _isEditMode => widget.initialDefinition != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initialDefinition;
    _fieldKeyController = TextEditingController(text: init?.fieldKey ?? '');
    _labelController = TextEditingController(text: init?.label ?? '');
    _function = init?.function ?? ConditionComputeFunction.direct;
    _argItemIds = List<String>.from(init?.argDesignerItemIds ?? const []);
    _userTouchedFieldKey = _isEditMode;

    _fieldKeyController.addListener(() {
      _userTouchedFieldKey = true;
    });
    _labelController.addListener(_onLabelChanged);
  }

  @override
  void dispose() {
    _fieldKeyController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _onLabelChanged() {
    if (_userTouchedFieldKey || _isEditMode) return;
    final suggestion = _suggestFieldKey(_labelController.text);
    if (suggestion.isEmpty) return;
    _fieldKeyController.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    _userTouchedFieldKey = false; // 保留 auto-suggest 模式
  }

  /// 由顯示名稱推 fieldKey：去除前後空白、空白轉底線、保留 ascii letters/digits/_。
  /// 中文字符無法生成 ascii key，所以對非 ascii 直接截斷。
  String _suggestFieldKey(String label) {
    final trimmed = label.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final char in trimmed.codeUnits) {
      if ((char >= 0x30 && char <= 0x39) || // 0-9
          (char >= 0x61 && char <= 0x7a) || // a-z
          char == 0x5f) {
        buffer.writeCharCode(char);
      } else if (char == 0x20) {
        buffer.writeCharCode(0x5f);
      }
    }
    return buffer.toString();
  }

  void _toggleArgItem(String itemId) {
    setState(() {
      final spec = _function.argSpec;
      if (spec.maxArgs == 1) {
        // Direct 單選
        _argItemIds = [itemId];
      } else {
        if (_argItemIds.contains(itemId)) {
          _argItemIds.remove(itemId);
        } else {
          if (_argItemIds.length >= spec.maxArgs) return;
          _argItemIds.add(itemId);
        }
      }
    });
  }

  void _changeFunction(ConditionComputeFunction next) {
    setState(() {
      _function = next;
      // 切換 function 時清空已選 args（型別可能變）
      _argItemIds = [];
    });
  }

  ConditionFieldType _resolveCurrentOutputType() {
    final spec = _function.argSpec;
    if (spec.fixedOutputType != null) return spec.fixedOutputType!;
    if (_argItemIds.isNotEmpty) {
      final first =
          widget.availableItems.cast<ConditionArgItemChoice?>().firstWhere(
                (c) => c?.itemId == _argItemIds.first,
                orElse: () => null,
              );
      if (first != null) return first.inferredFieldType;
    }
    return ConditionFieldType.string;
  }

  void _onConfirm() {
    final fieldKey = _fieldKeyController.text.trim();
    final label = _labelController.text.trim();
    final outputType = _resolveCurrentOutputType();

    final candidate = ConditionFieldDefinition(
      fieldKey: fieldKey,
      label: label,
      outputType: outputType,
      function: _function,
      argDesignerItemIds: List.unmodifiable(_argItemIds),
    );

    final existingForCheck = widget.existingDefinitions
        .where((d) => d.fieldKey != widget.initialDefinition?.fieldKey)
        .toList();

    final error = widget.service.validateDefinition(
      candidate,
      existingForCheck,
      widget.availableItems,
    );
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    Navigator.of(context).pop(ConditionFieldEditResult(
      originalFieldKey: widget.initialDefinition?.fieldKey ?? fieldKey,
      definition: candidate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outputType = _resolveCurrentOutputType();
    final filteredItems = widget.availableItems
        .where((c) => _function.argSpec.allowedArgTypes.contains(c.designerType))
        .toList();

    return AlertDialog(
      title: Text(_isEditMode ? '編輯條件欄位' : '新增條件欄位'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: '顯示名稱',
                  hintText: '例：請假天數',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fieldKeyController,
                decoration: const InputDecoration(
                  labelText: 'fieldKey（條件比對用）',
                  hintText: '例：leave_days',
                  isDense: true,
                  helperText: '英數字 + 底線；填寫顯示名稱會自動建議',
                ),
                onChanged: (_) {
                  _userTouchedFieldKey = true;
                },
              ),
              const SizedBox(height: 12),
              const Divider(),
              Text('計算函式', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              DropdownButtonFormField<ConditionComputeFunction>(
                value: _function,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true),
                items: ConditionComputeFunction.values
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text('${f.label} — ${f.description}',
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _changeFunction(v);
                },
              ),
              const SizedBox(height: 8),
              Text(
                '參數需求：${_function.argSpec.minArgs}'
                '${_function.argSpec.maxArgs == _function.argSpec.minArgs ? "" : " ~ ${_function.argSpec.maxArgs}"}'
                ' 個 · 允許型別：${_function.argSpec.allowedArgTypes.map((t) => t.name).join(", ")}'
                ' · 輸出：${outputType.label}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Text('已選參數 (${_argItemIds.length})',
                      style: theme.textTheme.titleSmall),
                  const Spacer(),
                  if (_argItemIds.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('清除'),
                      onPressed: () => setState(() => _argItemIds = []),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              if (filteredItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '此表單沒有符合「${_function.label}」要求型別的欄位。\n請先到表單設計加入對應元件，或改選其他計算函式。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                )
              else
                ..._buildArgPickerList(filteredItems),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _onConfirm,
          child: const Text('確認'),
        ),
      ],
    );
  }

  List<Widget> _buildArgPickerList(List<ConditionArgItemChoice> items) {
    final isSingle = _function.argSpec.maxArgs == 1;
    return items.map((c) {
      final selected = _argItemIds.contains(c.itemId);
      final orderIndex = _argItemIds.indexOf(c.itemId);
      return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
        value: selected,
        onChanged: (_) => _toggleArgItem(c.itemId),
        title: Row(
          children: [
            if (selected && !isSingle) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .extension<FormConditionFieldThemeColors>()!
                      .formulaIconColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${orderIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                '${c.label}（${c.designerType.name}）',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '所屬區塊：${c.sectionName} · 推測型別：${c.inferredFieldType.label}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }).toList();
  }
}
