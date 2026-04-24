import 'package:flutter/material.dart';
import 'package:flutter_application_ai/route/route_catalog.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 顯示目標頁面挑選 Dialog，使用者搜尋並點選後，按「確認」才帶回所選 [RouteDefinition]。
/// 若使用者取消則回傳 null。
Future<RouteDefinition?> showRoutePickerDialog({
  required BuildContext context,
  String? currentPath,
  bool useRootNavigator = false,
  Set<String>? allowedPaths,
}) {
  return showDialog<RouteDefinition>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: false,
    builder: (_) => _RoutePickerDialog(
      currentPath: currentPath,
      allowedPaths: allowedPaths,
    ),
  );
}

/// 內部目標頁面挑選 Dialog Widget。
class _RoutePickerDialog extends StatefulWidget {
  final String? currentPath;
  final Set<String>? allowedPaths;

  const _RoutePickerDialog({this.currentPath, this.allowedPaths});

  @override
  State<_RoutePickerDialog> createState() => _RoutePickerDialogState();
}

class _RoutePickerDialogState extends State<_RoutePickerDialog> {
  late final TextEditingController _searchCtrl;
  String _keyword = '';
  RouteDefinition? _pending;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    if (widget.currentPath != null && widget.currentPath!.isNotEmpty) {
      _pending = RouteCatalog.all.cast<RouteDefinition?>().firstWhere(
            (r) => r?.path == widget.currentPath,
            orElse: () => null,
          );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<RouteDefinition> get _source {
    final allowed = widget.allowedPaths;
    if (allowed == null) return RouteCatalog.all;
    return RouteCatalog.all.where((r) => allowed.contains(r.path)).toList();
  }

  List<RouteDefinition> get _filtered {
    final kw = _keyword.trim().toLowerCase();
    if (kw.isEmpty) return _source;
    return _source.where((r) {
      return r.label.toLowerCase().contains(kw) ||
          r.path.toLowerCase().contains(kw) ||
          r.group.toLowerCase().contains(kw);
    }).toList();
  }

  /// 將過濾後的清單依 group 分組，回傳有序的 (groupName, routes) 對。
  List<({String group, List<RouteDefinition> routes})> get _groupedFiltered {
    final filtered = _filtered;
    final seen = <String>[];
    for (final r in filtered) {
      if (!seen.contains(r.group)) seen.add(r.group);
    }
    return seen.map((g) {
      return (group: g, routes: filtered.where((r) => r.group == g).toList());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _groupedFiltered;
    final totalCount = _filtered.length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 740),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.alt_route_rounded,
                        size: 24, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '選擇目標頁面',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: TextSize.h2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 22),
                    tooltip: '取消',
                    padding: const EdgeInsets.all(6),
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Search ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontSize: TextSize.body),
                decoration: InputDecoration(
                  hintText: '搜尋頁面名稱、路徑或分組…',
                  hintStyle: TextStyle(
                    fontSize: TextSize.body,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _keyword.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _keyword = '');
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _keyword = v),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                '共 $totalCount 筆',
                style: TextStyle(
                  fontSize: TextSize.small,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            // ── List ────────────────────────────────────────────────
            Expanded(
              child: totalCount == 0
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 44,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.25)),
                          const SizedBox(height: 12),
                          Text(
                            '找不到符合的頁面',
                            style: TextStyle(
                              fontSize: TextSize.body,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 6),
                      itemCount: groups.fold<int>(
                          0, (sum, g) => sum + 1 + g.routes.length),
                      itemBuilder: (_, flatIndex) {
                        int cursor = 0;
                        for (final g in groups) {
                          if (flatIndex == cursor) {
                            return _GroupHeader(
                              group: g.group,
                              count: g.routes.length,
                            );
                          }
                          cursor++;
                          final localIdx = flatIndex - cursor;
                          if (localIdx < g.routes.length) {
                            final route = g.routes[localIdx];
                            final isFirst = localIdx == 0;
                            final isLast = localIdx == g.routes.length - 1;
                            return _RouteListTile(
                              route: route,
                              isSelected: _pending?.path == route.path,
                              showTopDivider: !isFirst,
                              showBottomDivider: isLast,
                              onTap: () => setState(() => _pending = route),
                            );
                          }
                          cursor += g.routes.length;
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
            const Divider(height: 1),
            // ── Selected preview ────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: _pending != null
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(height: 60),
              secondChild: _pending == null
                  ? const SizedBox(height: 60)
                  : _SelectedPreviewBar(route: _pending!),
            ),
            // ── Actions ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: TextSize.body),
                    ),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _pending == null
                        ? null
                        : () => Navigator.of(context).pop(_pending),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('確認'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: TextSize.body),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group Header
// ---------------------------------------------------------------------------

/// 路由分組標題列，顯示分組名稱與該組路由數量。
class _GroupHeader extends StatelessWidget {
  final String group;
  final int count;

  const _GroupHeader({required this.group, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _groupColor(group, theme.colorScheme);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      color: color.withValues(alpha: 0.08),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            group,
            style: TextStyle(
              fontSize: TextSize.small,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count 筆',
            style: TextStyle(
              fontSize: TextSize.caption,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

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
}

// ---------------------------------------------------------------------------
// Route List Tile
// ---------------------------------------------------------------------------

/// 單筆路由列表項目，顯示分組 badge、頁面名稱、路徑與必要參數警告。
class _RouteListTile extends StatelessWidget {
  final RouteDefinition route;
  final bool isSelected;
  final bool showTopDivider;
  final bool showBottomDivider;
  final VoidCallback onTap;

  const _RouteListTile({
    required this.route,
    required this.isSelected,
    required this.showTopDivider,
    required this.showBottomDivider,
    required this.onTap,
  });

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
    final groupColor = _groupColor(route.group, cs);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTopDivider)
          const Divider(height: 1, indent: 20, endIndent: 20),
        InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: isSelected
                ? cs.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Group badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: groupColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: groupColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    route.group,
                    style: TextStyle(
                      fontSize: TextSize.small,
                      color: groupColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Label + path
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              route.label,
                              style: TextStyle(
                                fontSize: TextSize.body,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected ? cs.primary : cs.onSurface,
                              ),
                            ),
                          ),
                          if (route.requiresExtra) ...[
                            const SizedBox(width: 8),
                            Tooltip(
                              message: '此路由需要傳入額外參數',
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (route.path != RouteCatalog.stayPath &&
                          route.path != RouteCatalog.backPath) ...[
                        const SizedBox(height: 3),
                        Text(
                          route.path,
                          style: TextStyle(
                            fontSize: TextSize.small,
                            color: cs.onSurface.withValues(alpha: 0.5),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Check icon
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isSelected ? 1 : 0,
                  child: Icon(Icons.check_circle_rounded,
                      size: 22, color: cs.primary),
                ),
              ],
            ),
          ),
        ),
        if (showBottomDivider) const Divider(height: 1),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Selected Preview Bar
// ---------------------------------------------------------------------------

/// 底部已選路由預覽列。
class _SelectedPreviewBar extends StatelessWidget {
  final RouteDefinition route;

  const _SelectedPreviewBar({required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSpecial = route.path == RouteCatalog.stayPath ||
        route.path == RouteCatalog.backPath;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      color: cs.primaryContainer.withValues(alpha: 0.4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Text(
            '已選：',
            style: TextStyle(
              fontSize: TextSize.small,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              isSpecial
                  ? route.label
                  : '${route.label}  ·  ${route.path}',
              style: TextStyle(
                fontSize: TextSize.body,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
