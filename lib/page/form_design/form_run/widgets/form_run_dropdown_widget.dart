import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/theme/dynamic_form_field_theme.dart';

/// 表單執行頁的下拉選單 Widget。
/// 支援單選（item.isGrouped == false）與多選（item.isGrouped == true）兩種模式；
/// 多選時以 Dialog + Checkbox 操作，選取結果以逗號串接字串透過 onChanged 回傳。
class FormRunDropdownWidget extends StatefulWidget {
  final DesignerItem item;
  final String initialValue;
  final List<String>? optionsOverride;
  final void Function(String value) onChanged;

  const FormRunDropdownWidget({
    super.key,
    required this.item,
    required this.onChanged,
    this.initialValue = '',
    this.optionsOverride,
  });

  @override
  State<FormRunDropdownWidget> createState() => _FormRunDropdownWidgetState();
}

class _FormRunDropdownWidgetState extends State<FormRunDropdownWidget> {
  // 單選
  String? _selected;

  // 多選
  late Set<String> _selectedMulti;

  bool get _isMulti => widget.item.isGrouped;

  List<String> get _options =>
      widget.optionsOverride ?? widget.item.options;

  @override
  void initState() {
    super.initState();
    _initValues(widget.initialValue);
  }

  void _initValues(String raw) {
    final options = _options;
    if (_isMulti) {
      final parts = raw.isEmpty
          ? <String>[]
          : raw.split(',').map((s) => s.trim()).where(options.contains).toList();
      _selectedMulti = parts.toSet();
    } else {
      _selected = options.contains(raw) ? raw : null;
    }
  }

  @override
  void didUpdateWidget(FormRunDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final options = _options;
    if (_isMulti) {
      _selectedMulti.removeWhere((v) => !options.contains(v));
    } else {
      if (_selected != null && !options.contains(_selected)) {
        setState(() => _selected = null);
      }
    }
  }

  void _emitMulti() {
    final sorted = _options.where(_selectedMulti.contains).toList();
    widget.onChanged(sorted.join(','));
  }

  void _showMultiSelectDialog(BuildContext context) {
    final options = _options;
    final temp = Set<String>.from(_selectedMulti);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(
                widget.item.text.isEmpty ? '選擇選項' : widget.item.text,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              content: SizedBox(
                width: 320,
                child: ListView(
                  shrinkWrap: true,
                  children: options.map((opt) {
                    return CheckboxListTile(
                      value: temp.contains(opt),
                      title: Text(opt),
                      dense: true,
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            temp.add(opt);
                          } else {
                            temp.remove(opt);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() => _selectedMulti = temp);
                    _emitMulti();
                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('確定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicFormFieldTheme.buildFieldShell(
      context: context,
      item: widget.item,
      child: _isMulti ? _buildMultiSelect(context) : _buildSingleSelect(),
    );
  }

  // ── 單選 ──────────────────────────────────────────
  Widget _buildSingleSelect() {
    final item = widget.item;
    final placeholder = item.placeholder.trim();
    final hint = placeholder.isNotEmpty ? placeholder : '請選擇';

    return DropdownButtonFormField<String>(
      value: _selected,
      isExpanded: true,
      decoration: DynamicFormFieldTheme.decoration(
        context: context,
        item: item,
        hintText: item.required ? '* $hint' : hint,
      ),
      style: DynamicFormFieldTheme.inputTextStyle(context, item),
      items: _options
          .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
          .toList(),
      onChanged: item.readonly
          ? null
          : (val) {
              if (val == null) return;
              setState(() => _selected = val);
              widget.onChanged(val);
            },
    );
  }

  // ── 多選 ──────────────────────────────────────────
  Widget _buildMultiSelect(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final placeholder = item.placeholder.trim();
    final hint = placeholder.isNotEmpty ? placeholder : '請選擇（可複選）';
    final labelText = item.required ? '* ${item.text}' : item.text;
    final hasSelection = _selectedMulti.isNotEmpty;

    return InkWell(
      onTap: item.readonly ? null : () => _showMultiSelectDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: DynamicFormFieldTheme.decoration(
          context: context,
          item: item,
          hintText: labelText.isEmpty ? (item.required ? '* $hint' : hint) : null,
        ).copyWith(
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: hasSelection
            ? Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _options
                    .where(_selectedMulti.contains)
                    .map(
                      (opt) => Chip(
                        label: Text(
                          opt,
                          style: DynamicFormFieldTheme.inputTextStyle(
                              context, item),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        deleteIcon: item.readonly
                            ? null
                            : const Icon(Icons.close, size: 14),
                        onDeleted: item.readonly
                            ? null
                            : () {
                                setState(
                                    () => _selectedMulti.remove(opt));
                                _emitMulti();
                              },
                      ),
                    )
                    .toList(),
              )
            : Text(
                item.required ? '* $hint' : hint,
                style: DynamicFormFieldTheme.inputTextStyle(context, item)
                    .copyWith(
                  color: theme.hintColor,
                ),
              ),
      ),
    );
  }
}
