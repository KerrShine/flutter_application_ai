import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/bloc/form_action_binding_bloc.dart';

import 'action_binding_empty_workbench_widget.dart';
import 'action_binding_trigger_selection_panel_widget.dart';

/// 動作綁定工作區的中層 Widget。
/// 依目前選取的來源元件決定顯示空白提示（ActionBindingEmptyWorkbenchWidget）
/// 或觸發事件面板（ActionBindingTriggerSelectionPanelWidget），並負責透傳所有 callbacks。
class ActionBindingPlannerWidget extends StatelessWidget {
  final FormActionBindingState state;
  final List<ApiDefinition> apiList;
  final List<ApiDefinition> dropdownApiList;
  final ValueChanged<String> onSelectTrigger;
  final ValueChanged<String> onAddAction;
  final ValueChanged<String> onRemoveAction;
  final ValueChanged<String> onMoveUp;
  final ValueChanged<String> onMoveDown;
  final void Function(String actionId, String apiId) onUpdateApiId;
  final void Function(String actionId, String route) onUpdateNavigateRoute;
  final void Function(String actionId, String parameterName) onUpdateParameterName;

  const ActionBindingPlannerWidget({
    super.key,
    required this.state,
    this.apiList = const [],
    this.dropdownApiList = const [],
    required this.onSelectTrigger,
    required this.onAddAction,
    required this.onRemoveAction,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onUpdateApiId,
    required this.onUpdateNavigateRoute,
    required this.onUpdateParameterName,
  });

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedSourceItem;

    if (selected == null) {
      return const ActionBindingEmptyWorkbenchWidget();
    }

    final triggerActions = state.selectedTriggerActions
        .cast<FormActionBindingDraft>()
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return ActionBindingTriggerSelectionPanelWidget(
      selected: selected,
      selectedTrigger: state.selectedTrigger,
      triggerActions: triggerActions,
      apiList: apiList,
      dropdownApiList: dropdownApiList,
      onSelectTrigger: onSelectTrigger,
      onAddAction: onAddAction,
      onRemoveAction: onRemoveAction,
      onMoveUp: onMoveUp,
      onMoveDown: onMoveDown,
      onUpdateApiId: onUpdateApiId,
      onUpdateNavigateRoute: onUpdateNavigateRoute,
      onUpdateParameterName: onUpdateParameterName,
    );
  }
}
