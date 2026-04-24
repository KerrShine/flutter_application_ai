import 'package:flutter/material.dart';
import 'package:flutter_application_ai/route/route_catalog.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 單張快捷路由卡片。
///
/// - 一般模式：點擊後呼叫 [onNavigate]
/// - 編輯模式（[isEditing] = true）：右上角出現 × 刪除按鈕
class MainShortcutCardWidget extends StatelessWidget {
  final String routePath;
  final bool isEditing;
  final VoidCallback onNavigate;
  final VoidCallback onDelete;

  const MainShortcutCardWidget({
    super.key,
    required this.routePath,
    required this.isEditing,
    required this.onNavigate,
    required this.onDelete,
  });

  RouteDefinition? get _definition =>
      RouteCatalog.all.cast<RouteDefinition?>().firstWhere(
            (r) => r?.path == routePath,
            orElse: () => null,
          );

  Color _groupColor(String group, ColorScheme cs) {
    switch (group) {
      case '導頁行為':
        return cs.primary;
      case '系統':
        return Colors.blueGrey.shade500;
      case '表單':
        return Colors.indigo.shade400;
      case '組織':
        return Colors.teal.shade500;
      case '員工':
        return Colors.orange.shade600;
      default:
        return cs.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final def = _definition;
    final label = def?.label ?? routePath;
    final group = def?.group ?? '其他';
    final color = _groupColor(group, cs);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── 卡片主體（填滿父層給予的空間）──────────────────
        Positioned.fill(
          child: Material(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: isEditing ? null : onNavigate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEditing
                        ? cs.outline.withValues(alpha: 0.3)
                        : color.withValues(alpha: 0.35),
                    width: isEditing ? 1 : 1.5,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Group badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        group,
                        style: TextStyle(
                          fontSize: TextSize.small,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Label
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: TextSize.h2,
                        fontWeight: FontWeight.w700,
                        color: isEditing
                            ? cs.onSurface.withValues(alpha: 0.45)
                            : cs.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── 刪除按鈕（編輯模式）────────────────────────────
        if (isEditing)
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.error.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 13, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

/// 「新增快捷」佔位卡片（count < 6 時顯示）。
class MainShortcutAddCardWidget extends StatelessWidget {
  final VoidCallback onTap;

  const MainShortcutAddCardWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 40,
                color: cs.onSurface.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 8),
              Text(
                '新增快捷',
                style: TextStyle(
                  fontSize: TextSize.body,
                  color: cs.onSurface.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
