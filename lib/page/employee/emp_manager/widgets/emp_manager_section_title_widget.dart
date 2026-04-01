import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/emp_manager_theme_colors.dart';

class EmpManagerSectionTitleWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmpManagerSectionTitleWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EmpManagerThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.subtitleText,
              ),
        ),
      ],
    );
  }
}
