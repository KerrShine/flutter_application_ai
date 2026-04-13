import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingMappingRowWidget extends StatelessWidget {
  final FieldBindingItem item;

  const BindingMappingRowWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final rowColor = switch (item.issueStatus) {
      FieldBindingIssueStatus.mapped => Colors.transparent,
      FieldBindingIssueStatus.unmapped =>
        colors.headerChipBackground.withValues(
          alpha: isDark ? 0.16 : 0.1,
        ),
      FieldBindingIssueStatus.versionMismatch =>
        theme.colorScheme.error.withValues(alpha: isDark ? 0.16 : 0.1),
    };
    final hintColor = switch (item.issueStatus) {
      FieldBindingIssueStatus.mapped => colors.faintText,
      FieldBindingIssueStatus.unmapped =>
        isDark ? const Color(0xFFF7C97A) : const Color(0xFFB56A07),
      FieldBindingIssueStatus.versionMismatch =>
        isDark ? const Color(0xFFFFB4AB) : theme.colorScheme.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          top: BorderSide(color: colors.panelBorder.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 36,
            child: Text(
              item.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: item.issueStatus == FieldBindingIssueStatus.mapped
                    ? null
                    : hintColor,
              ),
            ),
          ),
          Expanded(flex: 12, child: Text(item.fieldType)),
          Expanded(
            flex: 30,
            child: Text(
              item.outputKey.isEmpty ? '尚未設定...' : item.outputKey,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: item.outputKey.isEmpty ? hintColor : null,
                fontWeight:
                    item.outputKey.isEmpty ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(flex: 22, child: Text(item.nullStrategy)),
        ],
      ),
    );
  }
}
