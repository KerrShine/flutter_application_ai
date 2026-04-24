import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'action_binding_planning_placeholder_widget.dart';
import 'action_binding_trigger_card_widget.dart';

/// 動作綁定中間面板：顯示所選來源元件的可用觸發事件列表，
/// 以及目前觸發對應的動作序列設定區（ActionBindingPlanningPlaceholderWidget）。
class ActionBindingTriggerSelectionPanelWidget extends StatelessWidget {
  final FormActionSourceItem selected;
  final String selectedTrigger;
  final List<FormActionBindingDraft> triggerActions;
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

  const ActionBindingTriggerSelectionPanelWidget({
    super.key,
    required this.selected,
    required this.selectedTrigger,
    required this.triggerActions,
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
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.canvasPanelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '案件互動行為節點',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '選擇事件節點並查看對應的案件互動內容。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.faintText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ...selected.availableTriggers.map((trigger) {
                  final isSelected = trigger == selectedTrigger;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ActionBindingTriggerCardWidget(
                      trigger: trigger,
                      selected: selected,
                      isSelected: isSelected,
                      onTap: () {
                        onSelectTrigger(trigger);
                      },
                    ),
                  );
                }),
                ActionBindingPlanningPlaceholderWidget(
                  selected: selected,
                  selectedTrigger: selectedTrigger,
                  triggerActions: triggerActions,
                  apiList: apiList,
                  dropdownApiList: dropdownApiList,
                  onAddAction: onAddAction,
                  onRemoveAction: onRemoveAction,
                  onMoveUp: onMoveUp,
                  onMoveDown: onMoveDown,
                  onUpdateApiId: onUpdateApiId,
                  onUpdateNavigateRoute: onUpdateNavigateRoute,
                  onUpdateParameterName: onUpdateParameterName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
