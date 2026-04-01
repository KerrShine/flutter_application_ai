import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/org_tree_design_theme_colors.dart';

class PropertyItemWidget extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const PropertyItemWidget({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<OrgTreeDesignThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: (labelStyle ?? Theme.of(context).textTheme.labelLarge)
                ?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? colors.headerChipForeground
                  : colors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:
                (valueStyle ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
