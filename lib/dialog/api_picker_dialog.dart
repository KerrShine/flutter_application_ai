import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 顯示 API 挑選 Dialog，使用者搜尋並點選後，按「確認」才帶回所選 [ApiDefinition]。
/// 若使用者取消則回傳 null。
Future<ApiDefinition?> showApiPickerDialog({
  required BuildContext context,
  required List<ApiDefinition> apiList,
  String? currentApiId,
  bool useRootNavigator = false,
}) {
  return showDialog<ApiDefinition>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: false,
    builder: (_) => _ApiPickerDialog(
      apiList: apiList,
      currentApiId: currentApiId,
    ),
  );
}

/// 內部 API 挑選 Dialog Widget。
class _ApiPickerDialog extends StatefulWidget {
  final List<ApiDefinition> apiList;
  final String? currentApiId;

  const _ApiPickerDialog({
    required this.apiList,
    this.currentApiId,
  });

  @override
  State<_ApiPickerDialog> createState() => _ApiPickerDialogState();
}

class _ApiPickerDialogState extends State<_ApiPickerDialog> {
  late final TextEditingController _searchCtrl;
  String _keyword = '';
  ApiDefinition? _pending;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    if (widget.currentApiId != null && widget.currentApiId!.isNotEmpty) {
      _pending = widget.apiList.cast<ApiDefinition?>().firstWhere(
            (a) => a?.apiId == widget.currentApiId,
            orElse: () => null,
          );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ApiDefinition> get _filtered {
    final kw = _keyword.trim().toLowerCase();
    if (kw.isEmpty) return widget.apiList;
    return widget.apiList.where((a) {
      return a.apiName.toLowerCase().contains(kw) ||
          a.apiId.toLowerCase().contains(kw) ||
          a.path.toLowerCase().contains(kw);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
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
                    child: Icon(Icons.api_rounded,
                        size: 24, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '選擇 API',
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
                  hintText: '搜尋 API 名稱、ID 或路徑…',
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
                '共 ${filtered.length} 筆',
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
              child: filtered.isEmpty
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
                            '找不到符合的 API',
                            style: TextStyle(
                              fontSize: TextSize.body,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 20, endIndent: 20),
                      itemBuilder: (_, i) {
                        final api = filtered[i];
                        final isSelected = _pending?.apiId == api.apiId;
                        return _ApiListTile(
                          api: api,
                          isSelected: isSelected,
                          onTap: () => setState(() => _pending = api),
                        );
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
                  : _SelectedPreviewBar(api: _pending!),
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

/// 單筆 API 列表項目。
class _ApiListTile extends StatelessWidget {
  final ApiDefinition api;
  final bool isSelected;
  final VoidCallback onTap;

  const _ApiListTile({
    required this.api,
    required this.isSelected,
    required this.onTap,
  });

  Color _methodColor(String method, ColorScheme cs) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green.shade600;
      case 'POST':
        return cs.primary;
      case 'PUT':
        return Colors.orange.shade700;
      case 'PATCH':
        return Colors.teal.shade600;
      case 'DELETE':
        return cs.error;
      default:
        return cs.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final methodColor = _methodColor(api.method, cs);

    return InkWell(
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
            // Method badge
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: methodColor.withValues(alpha: 0.35)),
              ),
              alignment: Alignment.center,
              child: Text(
                api.method.toUpperCase(),
                style: TextStyle(
                  fontSize: TextSize.small,
                  color: methodColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + path
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    api.apiName,
                    style: TextStyle(
                      fontSize: TextSize.body,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    api.path,
                    style: TextStyle(
                      fontSize: TextSize.small,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            // Check icon
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isSelected ? 1 : 0,
              child:
                  Icon(Icons.check_circle_rounded, size: 22, color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部已選 API 預覽列。
class _SelectedPreviewBar extends StatelessWidget {
  final ApiDefinition api;

  const _SelectedPreviewBar({required this.api});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
              '${api.apiName}  ·  ${api.apiId}',
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
