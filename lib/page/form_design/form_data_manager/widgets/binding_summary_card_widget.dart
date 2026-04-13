import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingSummaryRowData {
  final String label;
  final String value;

  const BindingSummaryRowData(this.label, this.value);
}

class BindingSummaryCardWidget extends StatelessWidget {
  final String title;
  final List<BindingSummaryRowData> rows;

  const BindingSummaryCardWidget({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.canvasPanelBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.headerAccentForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.headerChipBackground.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colors.headerChipText.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.subtleText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        row.value,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
