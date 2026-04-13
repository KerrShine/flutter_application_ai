import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingInfoBadgeWidget extends StatelessWidget {
  final String label;
  final String value;

  const BindingInfoBadgeWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.headerChipBackground.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.headerChipText.withValues(alpha: 0.18),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.subtleText,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.headerAccentForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
