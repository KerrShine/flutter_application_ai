import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffManagerHeaderWidget extends StatelessWidget {
  final VoidCallback onExportJson;
  final VoidCallback onCreateTemplate;

  const SignOffManagerHeaderWidget({
    super.key,
    required this.onExportJson,
    required this.onCreateTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.headerAccentBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.headerAccentForeground.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_tree_outlined,
              color: colors.headerAccentForeground,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '簽核流程清單',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize:
                        (theme.textTheme.titleMedium?.fontSize ?? 16) + 2,
                    fontWeight: FontWeight.w700,
                    color: colors.headerAccentForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '管理表單對應的簽核流程模板，可拖曳節點建立流向。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize:
                        (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                    color: colors.subtleText,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onExportJson,
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: Text(
              '匯出 JSON',
              style: TextStyle(
                fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onCreateTemplate,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              '新增流程',
              style: TextStyle(
                fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
              ),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
