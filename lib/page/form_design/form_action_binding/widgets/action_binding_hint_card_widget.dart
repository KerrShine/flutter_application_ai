import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/bloc/form_action_binding_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class ActionBindingHintCardWidget extends StatelessWidget {
  final String text;
  final FormActionBindingHintTone tone;

  const ActionBindingHintCardWidget({
    super.key,
    required this.text,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final color = switch (tone) {
      FormActionBindingHintTone.warning => colors.actionWarning,
      FormActionBindingHintTone.info => colors.actionInfo,
      FormActionBindingHintTone.success => colors.actionSuccess,
    };
    final icon = switch (tone) {
      FormActionBindingHintTone.warning => Icons.warning_amber_rounded,
      FormActionBindingHintTone.info => Icons.info_outline,
      FormActionBindingHintTone.success => Icons.check_circle_outline,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
