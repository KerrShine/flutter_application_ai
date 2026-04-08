import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormSelectOverviewWidget extends StatelessWidget {
  final int totalForms;
  final int visibleForms;

  const FormSelectOverviewWidget({
    super.key,
    required this.totalForms,
    required this.visibleForms,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            title: '表單總數',
            value: '$totalForms',
            color: colors.statsCardBackground,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            title: '目前顯示',
            value: '$visibleForms',
            color: colors.headerChipBackground.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
