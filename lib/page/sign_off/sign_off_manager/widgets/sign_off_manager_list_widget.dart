import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffManagerListWidget extends StatelessWidget {
  final List<SignOffTemplateModel> templates;
  final void Function(String templateId) onEdit;
  final void Function(String templateId) onDelete;

  const SignOffManagerListWidget({
    super.key,
    required this.templates,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    if (templates.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: colors.emptyStateBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.emptyStateBorder),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.emptyStateIconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_tree_outlined,
                  size: 36,
                  color: colors.emptyStateIconColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '尚未設定任何簽核流程',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize:
                      (theme.textTheme.titleMedium?.fontSize ?? 16) + 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '請點擊「新增流程」建立第一個簽核流程模板',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                  color: colors.subtleText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final template = templates[index];
        return _SignOffTemplateCard(
          template: template,
          colors: colors,
          onEdit: () => onEdit(template.templateId),
          onDelete: () => onDelete(template.templateId),
        );
      },
    );
  }
}

class _SignOffTemplateCard extends StatelessWidget {
  final SignOffTemplateModel template;
  final FormDesignThemeColors colors;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SignOffTemplateCard({
    required this.template,
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.sectionCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.sectionCardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.sectionCardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.sectionIconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForStatus(template.status),
                color: colors.sectionIconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name.isEmpty ? '（未命名流程）' : template.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) + 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusChip(status: template.status, colors: colors),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '對應表單：${template.formName.isEmpty ? template.formId : template.formName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                      color: colors.subtleText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.linear_scale,
                        label: '節點 ${template.canvasNodes.length}',
                        colors: colors,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.history,
                        label: 'v${template.version}',
                        colors: colors,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: '編輯',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              color: colors.actionButtonAccent,
            ),
            IconButton(
              tooltip: '刪除',
              icon: const Icon(Icons.delete_outline),
              color: colors.actionWarning,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForStatus(String status) {
    switch (status) {
      case 'active':
        return Icons.check_circle;
      case 'disabled':
        return Icons.pause_circle_outline;
      case 'draft':
      default:
        return Icons.edit_note;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final FormDesignThemeColors colors;
  const _StatusChip({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    String label;
    switch (status) {
      case 'active':
        color = colors.actionSuccess;
        label = '啟用中';
        break;
      case 'disabled':
        color = colors.actionWarning;
        label = '已停用';
        break;
      case 'draft':
      default:
        color = colors.actionDropdownAccent;
        label = '草稿';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final FormDesignThemeColors colors;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.headerChipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.headerChipText),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.headerChipText,
              fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
