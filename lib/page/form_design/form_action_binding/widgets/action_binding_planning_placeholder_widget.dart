import 'package:flutter/material.dart';
import 'package:flutter_application_ai/dialog/api_picker_dialog.dart';
import 'package:flutter_application_ai/dialog/route_picker_dialog.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/route/route_catalog.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';

/// 觸發事件下方的動作序列設定區。
/// 顯示目前觸發已設定的動作清單（含 order、apiId、navigateRoute 輸入欄），
/// 支援新增、刪除、上下排序，並透過 callbacks 通知父層更新 BLoC 狀態。
class ActionBindingPlanningPlaceholderWidget extends StatefulWidget {
  final FormActionSourceItem selected;
  final String selectedTrigger;
  final List<FormActionBindingDraft> triggerActions;
  final List<ApiDefinition> apiList;
  final List<ApiDefinition> dropdownApiList;
  final ValueChanged<String> onAddAction;
  final ValueChanged<String> onRemoveAction;
  final ValueChanged<String> onMoveUp;
  final ValueChanged<String> onMoveDown;
  final void Function(String actionId, String apiId) onUpdateApiId;
  final void Function(String actionId, String route) onUpdateNavigateRoute;
  final void Function(String actionId, String parameterName) onUpdateParameterName;

  const ActionBindingPlanningPlaceholderWidget({
    super.key,
    required this.selected,
    required this.selectedTrigger,
    required this.triggerActions,
    this.apiList = const [],
    this.dropdownApiList = const [],
    required this.onAddAction,
    required this.onRemoveAction,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onUpdateApiId,
    required this.onUpdateNavigateRoute,
    required this.onUpdateParameterName,
  });

  @override
  State<ActionBindingPlanningPlaceholderWidget> createState() =>
      _ActionBindingPlanningPlaceholderWidgetState();
}

class _ActionBindingPlanningPlaceholderWidgetState
    extends State<ActionBindingPlanningPlaceholderWidget> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final triggerTitle = widget.selectedTrigger.isEmpty
        ? '尚未選擇事件'
        : formActionTriggerDisplayName(widget.selectedTrigger);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.selectedTrigger.isEmpty ? '尚未選擇事件' : '觸發：$triggerTitle',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.selectedTrigger.isEmpty
                ? '請從上方選擇事件節點。'
                : '為 ${widget.selected.label} 設定觸發後的動作序列。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          if (widget.selectedTrigger.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '尚未選擇事件節點。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            if (widget.triggerActions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '尚未設定任何動作，請點下方「＋ 新增動作」。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.triggerActions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final action = widget.triggerActions[index];
                  final isFirst = index == 0;
                  final isLast = index == widget.triggerActions.length - 1;
                  return _ActionCard(
                    action: action,
                    isFirst: isFirst,
                    isLast: isLast,
                    apiList: widget.apiList,
                    dropdownApiList: widget.dropdownApiList,
                    onRemove: () => widget.onRemoveAction(action.actionId),
                    onMoveUp: isFirst
                        ? null
                        : () => widget.onMoveUp(action.actionId),
                    onMoveDown: isLast
                        ? null
                        : () => widget.onMoveDown(action.actionId),
                    onApiIdChanged: (v) =>
                        widget.onUpdateApiId(action.actionId, v),
                    onRouteChanged: (v) =>
                        widget.onUpdateNavigateRoute(action.actionId, v),
                    onParameterNameChanged: (v) =>
                        widget.onUpdateParameterName(action.actionId, v),
                  );
                },
              ),
            const SizedBox(height: 12),
            _AddActionButton(
              selectedTrigger: widget.selectedTrigger,
              selected: widget.selected,
              onAddAction: widget.onAddAction,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action Card
// ---------------------------------------------------------------------------

class _ActionCard extends StatelessWidget {
  final FormActionBindingDraft action;
  final bool isFirst;
  final bool isLast;
  final List<ApiDefinition> apiList;
  final List<ApiDefinition> dropdownApiList;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final ValueChanged<String> onApiIdChanged;
  final ValueChanged<String> onRouteChanged;
  final ValueChanged<String> onParameterNameChanged;

  const _ActionCard({
    required this.action,
    required this.isFirst,
    required this.isLast,
    required this.apiList,
    this.dropdownApiList = const [],
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onApiIdChanged,
    required this.onRouteChanged,
    required this.onParameterNameChanged,
  });

  List<ApiDefinition> get _effectiveApiList =>
      action.actionType == ActionType.loadDropdownOptions
          ? dropdownApiList
          : apiList;

  void _showApiPickerDialog(BuildContext context) {
    showApiPickerDialog(
      context: context,
      apiList: _effectiveApiList,
      currentApiId: action.apiId.isEmpty ? null : action.apiId,
    ).then((api) {
      if (api != null) onApiIdChanged(api.apiId);
    });
  }

  void _showRoutePickerDialog(BuildContext context) {
    showRoutePickerDialog(
      context: context,
      currentPath: action.navigateRoute.isEmpty ? null : action.navigateRoute,
    ).then((route) {
      if (route != null) onRouteChanged(route.path);
    });
  }

  String _routeLabel() {
    if (action.navigateRoute.isEmpty) return '請選擇目標頁面';
    if (action.navigateRoute == RouteCatalog.stayPath) return '留在本頁';
    if (action.navigateRoute == RouteCatalog.backPath) return '回到上一頁';
    final match = RouteCatalog.all.cast<RouteDefinition?>().firstWhere(
          (r) => r?.path == action.navigateRoute,
          orElse: () => null,
        );
    return match != null
        ? '${match.label}  (${action.navigateRoute})'
        : action.navigateRoute;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionName = formActionDisplayName(action.actionType.name);
    final needsApiId = action.actionType == ActionType.callApi ||
        action.actionType == ActionType.submitForm ||
        action.actionType == ActionType.loadDropdownOptions;
    final needsRoute = action.actionType == ActionType.navigate ||
        action.actionType == ActionType.submitForm;
    final noConfig = !needsApiId && !needsRoute;

    // 取得已選 API 的顯示名稱
    final selectedApi = _effectiveApiList.cast<ApiDefinition?>().firstWhere(
          (a) => a?.apiId == action.apiId,
          orElse: () => null,
        );
    final apiLabel = action.apiId.isEmpty
        ? '請選擇 API'
        : (selectedApi != null
            ? '${selectedApi.apiName}  (${action.apiId})'
            : action.apiId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${action.order + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  actionName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  onPressed: onMoveUp,
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: onMoveUp != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  onPressed: onMoveDown,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: onMoveDown != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  onPressed: onRemove,
                  icon: Icon(Icons.close, color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
          // API 挑選
          if (needsApiId) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showApiPickerDialog(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: action.apiId.isEmpty
                        ? theme.colorScheme.error.withValues(alpha: 0.5)
                        : theme.colorScheme.outline,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        apiLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: action.apiId.isEmpty
                              ? theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // 參數名稱（loadDropdownOptions 專用）
          if (action.actionType == ActionType.loadDropdownOptions) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: action.parameterName,
              decoration: InputDecoration(
                labelText: '參數名稱',
                hintText: '請輸入資料抓取的參數名稱',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: theme.textTheme.bodySmall,
              onChanged: onParameterNameChanged,
            ),
          ],
          // 路由選擇
          if (needsRoute) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showRoutePickerDialog(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: action.navigateRoute.isEmpty
                        ? theme.colorScheme.error.withValues(alpha: 0.5)
                        : theme.colorScheme.outline,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _routeLabel(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: action.navigateRoute.isEmpty
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (noConfig) ...[
            const SizedBox(height: 6),
            Text(
              '無需額外設定',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Action Button
// ---------------------------------------------------------------------------

class _AddActionButton extends StatelessWidget {
  final String selectedTrigger;
  final FormActionSourceItem selected;
  final ValueChanged<String> onAddAction;

  const _AddActionButton({
    required this.selectedTrigger,
    required this.selected,
    required this.onAddAction,
  });

  List<String> _resolveVisibleActions() {
    switch (selectedTrigger) {
      case 'buttonPressed':
        return selected.suggestedActions
            .where((item) => [
                  'navigate',
                  'saveDraft',
                  'submitForm',
                  'callApi',
                  'other',
                ].contains(item))
            .toList();
      case 'dropdownLoaded':
        return selected.suggestedActions
            .where((item) =>
                ['loadDropdownOptions', 'setFieldValue', 'other'].contains(item))
            .toList();
      case 'dropdownChanged':
        return const [];
      default:
        return selected.suggestedActions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleActions = _resolveVisibleActions();

    if (visibleActions.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      onSelected: onAddAction,
      itemBuilder: (_) => visibleActions
          .map(
            (action) => PopupMenuItem<String>(
              value: action,
              child: Text(formActionDisplayName(action)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              '新增動作',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
