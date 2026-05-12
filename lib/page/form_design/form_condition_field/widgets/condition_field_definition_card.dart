import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/condition_compute_function.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 已定義條件欄位卡片 — 顯示 fieldKey badge / label / 公式 (function + arg chips) + 編輯/移除。
class ConditionFieldDefinitionCard extends StatelessWidget {
  final ConditionFieldDefinition definition;
  final List<ConditionArgItemChoice> availableItems;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ConditionFieldDefinitionCard({
    super.key,
    required this.definition,
    required this.availableItems,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormConditionFieldThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: colors.definitionCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.definitionCardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.definitionCardShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: fieldKey badge + type pill (column on narrow, row otherwise)
          _buildKeyBlock(theme, colors),
          const SizedBox(width: 28),
          // Middle: label + formula
          Expanded(child: _buildBody(theme, colors)),
          // Right: edit / remove
          _buildActions(colors),
        ],
      ),
    );
  }

  Widget _buildKeyBlock(
    ThemeData theme,
    FormConditionFieldThemeColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.fieldKeyBadgeBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            definition.fieldKey,
            style: TextStyle(
              fontFamily: 'monospace',
              color: colors.fieldKeyBadgeText,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _TypePill(
          label: definition.outputType.label,
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildBody(
    ThemeData theme,
    FormConditionFieldThemeColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          definition.label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.labelText,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
        _buildFormula(theme, colors),
      ],
    );
  }

  Widget _buildFormula(
    ThemeData theme,
    FormConditionFieldThemeColors colors,
  ) {
    final argChips = <Widget>[];
    for (var i = 0; i < definition.argDesignerItemIds.length; i++) {
      final id = definition.argDesignerItemIds[i];
      final item = availableItems.cast<ConditionArgItemChoice?>().firstWhere(
            (c) => c?.itemId == id,
            orElse: () => null,
          );
      argChips.add(_ArgChip(
        label: item?.label ?? '⚠ 找不到',
        missing: item == null,
        colors: colors,
      ));
      if (i < definition.argDesignerItemIds.length - 1) {
        argChips.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '·',
            style: TextStyle(color: colors.subtleText, fontSize: 16),
          ),
        ));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(
          definition.function.label,
          style: TextStyle(
            color: colors.formulaText,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Icon(Icons.arrow_back, size: 16, color: colors.formulaIconColor),
        ...argChips,
      ],
    );
  }

  Widget _buildActions(FormConditionFieldThemeColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconActionButton(
          tooltip: '編輯',
          icon: Icons.edit_outlined,
          color: colors.editIconColor,
          borderColor: colors.iconButtonBorder,
          onTap: onEdit,
        ),
        const SizedBox(width: 6),
        _IconActionButton(
          tooltip: '移除',
          icon: Icons.delete_outline,
          color: colors.removeIconColor,
          borderColor: colors.iconButtonBorder,
          onTap: onRemove,
        ),
      ],
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final FormConditionFieldThemeColors colors;
  const _TypePill({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.typePillBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.typePillText,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ArgChip extends StatelessWidget {
  final String label;
  final bool missing;
  final FormConditionFieldThemeColors colors;
  const _ArgChip({
    required this.label,
    required this.missing,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final bg = missing
        ? Colors.red.withValues(alpha: 0.12)
        : colors.argChipBackground;
    final border = missing
        ? Colors.red.withValues(alpha: 0.5)
        : colors.argChipBorder;
    final text = missing ? Colors.red : colors.argChipText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}
