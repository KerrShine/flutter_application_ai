import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/main/widgets/main_shortcut_card_widget.dart';
import 'package:flutter_application_ai/service/main_service.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 快速路徑快捷鍵區塊。
class MainQuickShortcutSectionWidget extends StatelessWidget {
  final List<String> shortcuts;
  final bool isEditing;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onToggleEdit;
  final ValueChanged<String> onNavigate;

  const MainQuickShortcutSectionWidget({
    super.key,
    required this.shortcuts,
    required this.isEditing,
    required this.onAdd,
    required this.onRemove,
    required this.onToggleEdit,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final canAdd = shortcuts.length < MainService.maxShortcuts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ─────────────────────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.bolt_rounded, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Text(
              '快速路徑',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: TextSize.title,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${shortcuts.length} / ${MainService.maxShortcuts}',
              style: TextStyle(
                fontSize: TextSize.small,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: shortcuts.isEmpty && !isEditing
                  ? const SizedBox.shrink()
                  : TextButton.icon(
                      key: ValueKey(isEditing),
                      onPressed: onToggleEdit,
                      icon: Icon(
                        isEditing ? Icons.check_rounded : Icons.edit_rounded,
                        size: 15,
                      ),
                      label: Text(isEditing ? '完成' : '管理'),
                      style: TextButton.styleFrom(
                        foregroundColor: isEditing
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.6),
                        textStyle:
                            const TextStyle(fontSize: TextSize.small),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Grid ───────────────────────────────────────────────
        if (shortcuts.isEmpty && !isEditing)
          _EmptyShortcutHint(onAdd: onAdd)
        else
          _ShortcutGrid(
            shortcuts: shortcuts,
            isEditing: isEditing,
            canAdd: canAdd,
            onAdd: onAdd,
            onRemove: onRemove,
            onNavigate: onNavigate,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Grid — 2 欄，高度 = 寬度 × 0.42，隨螢幕自動縮放
// ---------------------------------------------------------------------------

class _ShortcutGrid extends StatelessWidget {
  final List<String> shortcuts;
  final bool isEditing;
  final bool canAdd;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onNavigate;

  const _ShortcutGrid({
    required this.shortcuts,
    required this.isEditing,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    const cols = 2;
    const spacing = 16.0;
    const aspectRatio = 2.4; // width : height

    final showAddSlot = canAdd && (isEditing || shortcuts.isEmpty);
    final slots = <Widget>[
      for (int i = 0; i < shortcuts.length; i++)
        MainShortcutCardWidget(
          routePath: shortcuts[i],
          isEditing: isEditing,
          onNavigate: () => onNavigate(shortcuts[i]),
          onDelete: () => onRemove(shortcuts[i]),
        ),
      if (showAddSlot) MainShortcutAddCardWidget(onTap: onAdd),
    ];

    // 補齊最後一列的空白，保持對齊
    final remainder = slots.length % cols;
    if (remainder != 0) {
      for (int i = 0; i < cols - remainder; i++) {
        slots.add(const SizedBox.shrink());
      }
    }

    // 每 cols 張一列
    final rows = <Widget>[];
    for (int i = 0; i < slots.length; i += cols) {
      final rowSlots = slots.sublist(i, (i + cols).clamp(0, slots.length));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int j = 0; j < rowSlots.length; j++) ...[
                if (j > 0) const SizedBox(width: spacing),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: rowSlots[j],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
      if (i + cols < slots.length) {
        rows.add(const SizedBox(height: spacing));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state hint
// ---------------------------------------------------------------------------

class _EmptyShortcutHint extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyShortcutHint({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 40,
              color: cs.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 10),
            Text(
              '尚未設定快速路徑',
              style: TextStyle(
                fontSize: TextSize.body,
                color: cs.onSurface.withValues(alpha: 0.35),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '點此新增，最多可設定 ${MainService.maxShortcuts} 個',
              style: TextStyle(
                fontSize: TextSize.small,
                color: cs.onSurface.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
