import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 簽核狀態頁的「整體狀態 / 目前簽核者 / 最新意見」三張通用 stat card。
///
/// `colors` 由呼叫端傳入避免每張卡重複跑 Theme.of(context).extension。
class SignOffStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FormApplicationThemeColors colors;

  const SignOffStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.chipBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: TextSize.body,
              color: colors.listSubtitleText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontSize: TextSize.title,
              fontWeight: FontWeight.w700,
              color: valueColor ?? colors.listTitleText,
            ),
          ),
        ],
      ),
    );
  }
}
