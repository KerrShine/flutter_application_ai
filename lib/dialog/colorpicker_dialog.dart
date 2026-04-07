import 'package:flutter/material.dart';
import 'package:flutter_application_ai/unit/color_hex_utils.dart';

Future<String?> showColorPickerDialog({
  required BuildContext context,
  String? initialHex,
  bool useRootNavigator = false,
  bool barrierDismissible = false,
  String title = '選擇顏色',
  String cancelText = '取消',
  String confirmText = '確認',
}) {
  return showDialog<String>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return _ColorPickerDialog(
        initialHex: initialHex,
        title: title,
        cancelText: cancelText,
        confirmText: confirmText,
      );
    },
  );
}

class _ColorPickerDialog extends StatefulWidget {
  final String? initialHex;
  final String title;
  final String cancelText;
  final String confirmText;

  const _ColorPickerDialog({
    required this.initialHex,
    required this.title,
    required this.cancelText,
    required this.confirmText,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  static const List<Color> _presetColors = [
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF64748B),
  ];

  late HSVColor _selectedColor;
  late final TextEditingController _hexController;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    final initialColor =
        _parseHexColor(widget.initialHex) ?? const Color(0xFF3B82F6);
    _selectedColor = HSVColor.fromColor(initialColor);
    _hexController = TextEditingController(text: _toHex(initialColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _selectedColor.toColor();

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '目前色碼',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _toHex(color),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '快速選色',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presetColors
                  .map(
                    (presetColor) => _ColorPresetChip(
                      color: presetColor,
                      isSelected: _toHex(presetColor) == _toHex(color),
                      onTap: () => _updateColor(presetColor),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            _SliderField(
              label: 'Hue',
              value: _selectedColor.hue,
              min: 0,
              max: 360,
              activeColor: color,
              trailingText: _selectedColor.hue.round().toString(),
              onChanged: (value) {
                setState(() {
                  _selectedColor = _selectedColor.withHue(value);
                  _syncHexField();
                });
              },
            ),
            const SizedBox(height: 10),
            _SliderField(
              label: 'Saturation',
              value: _selectedColor.saturation,
              min: 0,
              max: 1,
              activeColor: color,
              trailingText: '${(_selectedColor.saturation * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  _selectedColor = _selectedColor.withSaturation(value);
                  _syncHexField();
                });
              },
            ),
            const SizedBox(height: 10),
            _SliderField(
              label: 'Brightness',
              value: _selectedColor.value,
              min: 0,
              max: 1,
              activeColor: color,
              trailingText: '${(_selectedColor.value * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  _selectedColor = _selectedColor.withValue(value);
                  _syncHexField();
                });
              },
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _hexController,
              decoration: InputDecoration(
                labelText: 'Hex 色碼',
                hintText: '#3B82F6',
                errorText: _errorText.isEmpty ? null : _errorText,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _applyHexInput,
                  icon: const Icon(Icons.check_circle_outline),
                  tooltip: '套用色碼',
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _applyHexInput(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText),
        ),
        FilledButton(
          onPressed: _handleConfirm,
          child: Text(widget.confirmText),
        ),
      ],
    );
  }

  void _updateColor(Color color) {
    setState(() {
      _selectedColor = HSVColor.fromColor(color);
      _syncHexField();
      _errorText = '';
    });
  }

  void _syncHexField() {
    _hexController.value = TextEditingValue(
      text: _toHex(_selectedColor.toColor()),
      selection: TextSelection.collapsed(
        offset: _toHex(_selectedColor.toColor()).length,
      ),
    );
  }

  void _applyHexInput() {
    final parsed = _parseHexColor(_hexController.text);
    if (parsed == null) {
      setState(() {
        _errorText = '請輸入正確格式，例如 #3B82F6';
      });
      return;
    }

    setState(() {
      _selectedColor = HSVColor.fromColor(parsed);
      _hexController.text = _toHex(parsed);
      _errorText = '';
    });
  }

  void _handleConfirm() {
    final normalizedInput = _hexController.text.trim();
    if (normalizedInput.isNotEmpty) {
      final parsed = _parseHexColor(normalizedInput);
      if (parsed == null) {
        setState(() {
          _errorText = '請輸入正確格式，例如 #3B82F6';
        });
        return;
      }

      final hex = ColorHexUtils.toHex(parsed);
      setState(() {
        _selectedColor = HSVColor.fromColor(parsed);
        _hexController.text = hex;
        _errorText = '';
      });
      Navigator.of(context).pop(hex);
      return;
    }

    Navigator.of(context).pop(ColorHexUtils.toHex(_selectedColor.toColor()));
  }

  Color? _parseHexColor(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    var normalized = raw.replaceAll('#', '').toUpperCase();
    if (normalized.length == 3) {
      normalized = normalized.split('').map((char) => '$char$char').join();
    }
    if (normalized.length != 6) {
      return null;
    }

    final hexValue = int.tryParse(normalized, radix: 16);
    if (hexValue == null) {
      return null;
    }

    return Color(0xFF000000 | hexValue);
  }

  String _toHex(Color color) {
    return ColorHexUtils.toHex(color);
  }
}

class _ColorPresetChip extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorPresetChip({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final String trailingText;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.trailingText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              trailingText,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
