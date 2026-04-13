import 'package:flutter/material.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'action_binding_planning_placeholder_widget.dart';
import 'action_binding_trigger_card_widget.dart';

class ActionBindingTriggerSelectionPanelWidget extends StatelessWidget {
  final FormActionSourceItem selected;
  final String selectedActionName;
  final String selectedTrigger;
  final ValueChanged<String> onSelectAction;
  final ValueChanged<String> onSelectTrigger;

  const ActionBindingTriggerSelectionPanelWidget({
    super.key,
    required this.selected,
    required this.selectedActionName,
    required this.selectedTrigger,
    required this.onSelectAction,
    required this.onSelectTrigger,
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
                  selectedActionName: selectedActionName,
                  selectedTrigger: selectedTrigger,
                  onSelectAction: onSelectAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
