import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 表單條件欄位頁的統計卡片。
///
/// 左側 fx 圖示 + 標題 + 描述；右側雙計數（已定義 / 可用表單欄位）。
/// 純展示元件，不含互動。
class ConditionFieldStatsCardWidget extends StatelessWidget {
  final int definitionCount;
  final int availableItemCount;

  const ConditionFieldStatsCardWidget({
    super.key,
    required this.definitionCount,
    required this.availableItemCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormConditionFieldThemeColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colors.statsCardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.statsCardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.statsCardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.statsIconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.functions,
                color: colors.statsIconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已定義條件欄位',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.statsTitleText,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '條件欄位獨立於表單提交設定，由 sign_off path rule 直接消費',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.statsDescriptionText,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatsCounter(value: definitionCount, label: '已定義'),
          const SizedBox(width: 24),
          _StatsCounter(value: availableItemCount, label: '可用表單欄位'),
        ],
      ),
    );
  }
}

class _StatsCounter extends StatelessWidget {
  final int value;
  final String label;

  const _StatsCounter({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormConditionFieldThemeColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$value',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colors.statsCounterValue,
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.statsCounterLabel,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
