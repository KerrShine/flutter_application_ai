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

  /// 把 API 清單拆成「正式 API」與「測試工具」兩組。
  /// method == LOCAL_STORAGE 視為測試工具，會在 list 底部以獨立分組呈現。
  static bool _isTestTool(ApiDefinition api) =>
      api.method.toUpperCase() == 'LOCAL_STORAGE';

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
                  : Builder(
                      builder: (_) {
                        final normalApis =
                            filtered.where((a) => !_isTestTool(a)).toList();
                        final testApis =
                            filtered.where(_isTestTool).toList();
                        // 計算 itemCount：
                        // - normalApis 每筆 1 item
                        // - 若有 testApis 則加 1 個 section header + testApis.length
                        final hasTestSection = testApis.isNotEmpty;
                        final itemCount = normalApis.length +
                            (hasTestSection ? 1 + testApis.length : 0);
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: itemCount,
                          itemBuilder: (_, i) {
                            // 正式 API 區
                            if (i < normalApis.length) {
                              final api = normalApis[i];
                              return Column(
                                children: [
                                  _ApiListTile(
                                    api: api,
                                    isSelected: _pending?.apiId == api.apiId,
                                    onTap: () =>
                                        setState(() => _pending = api),
                                  ),
                                  if (i < normalApis.length - 1)
                                    const Divider(
                                        height: 1, indent: 20, endIndent: 20),
                                ],
                              );
                            }
                            // Section header (測試工具)
                            if (i == normalApis.length && hasTestSection) {
                              return const _TestToolsSectionHeader();
                            }
                            // 測試工具區
                            final testIndex = i - normalApis.length - 1;
                            final api = testApis[testIndex];
                            return Column(
                              children: [
                                _ApiListTile(
                                  api: api,
                                  isSelected: _pending?.apiId == api.apiId,
                                  onTap: () => setState(() => _pending = api),
                                ),
                                if (testIndex < testApis.length - 1)
                                  const Divider(
                                      height: 1, indent: 20, endIndent: 20),
                              ],
                            );
                          },
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
      case 'LOCAL_STORAGE':
        return Colors.deepPurple.shade400;
      default:
        return cs.secondary;
    }
  }

  bool get _isTestTool => api.method.toUpperCase() == 'LOCAL_STORAGE';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final methodColor = _methodColor(api.method, cs);

    // 測試工具底色（淡紫）— 與正式 API 視覺上明確區隔
    final baseColor = _isTestTool
        ? Colors.deepPurple.withValues(alpha: 0.04)
        : Colors.transparent;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: isSelected
            ? cs.primary.withValues(alpha: 0.08)
            : baseColor,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Method badge — 測試工具用較寬版面以容納 LOCAL_STORAGE 字樣
            Container(
              width: _isTestTool ? 110 : 60,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: _isTestTool ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: methodColor.withValues(alpha: _isTestTool ? 0.6 : 0.35),
                  width: _isTestTool ? 1.4 : 1.0,
                ),
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
                  Row(
                    children: [
                      if (_isTestTool) ...[
                        const Text('🧪', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          api.apiName,
                          style: TextStyle(
                            fontSize: TextSize.body,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ),
                    ],
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

/// 「測試工具」分組標題列 — 視覺上把開發/測試類 API 與正式 API 隔開。
class _TestToolsSectionHeader extends StatelessWidget {
  const _TestToolsSectionHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = Colors.deepPurple.shade400;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border(
          top: BorderSide(color: color.withValues(alpha: 0.35), width: 1.5),
          bottom: BorderSide(color: color.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.science_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '測試工具',
            style: TextStyle(
              fontSize: TextSize.small,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '— 開發/驗證用，會寫入本地存儲',
              style: TextStyle(
                fontSize: TextSize.small,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
