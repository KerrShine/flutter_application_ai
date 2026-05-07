import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/sign_off_path_rule.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 顯示單一 Path Rule 的卡片，用於 origin 節點屬性面板。
class SignOffPathRuleCard extends StatelessWidget {
  final SignOffPathRule rule;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onTap;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  const SignOffPathRuleCard({
    super.key,
    required this.rule,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onTap,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    final summary = rule.isDefault
        ? '預設規則 (無條件 — 永遠 match)'
        : (rule.condition?.summary ?? '');
    final activatedCount = rule.activatedNodeIds.length;
    final accent = rule.isDefault
        ? colors.actionInfo
        : colors.actionButtonAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.sectionCardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.sectionCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${rule.sortOrder}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize:
                            (theme.textTheme.labelSmall?.fontSize ?? 11) + 1,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule.name.isEmpty ? '(未命名)' : rule.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize:
                            (theme.textTheme.bodyMedium?.fontSize ?? 14) + 1,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: '上移',
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                        width: 24, height: 24),
                    onPressed: canMoveUp ? onMoveUp : null,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  IconButton(
                    tooltip: '下移',
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                        width: 24, height: 24),
                    onPressed: canMoveDown ? onMoveDown : null,
                    icon: const Icon(Icons.arrow_downward),
                  ),
                  IconButton(
                    tooltip: '刪除規則',
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                        width: 24, height: 24),
                    onPressed: onDelete,
                    icon: Icon(Icons.close, color: colors.actionWarning),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                summary.isEmpty ? '(尚未設定條件)' : summary,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 1,
                  color: colors.subtleText,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.linear_scale,
                      size: 14, color: colors.headerChipText),
                  const SizedBox(width: 4),
                  Text(
                    '啟用 $activatedCount 節點',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 1,
                      color: colors.headerChipText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
