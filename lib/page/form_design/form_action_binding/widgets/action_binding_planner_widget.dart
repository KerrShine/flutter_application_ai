import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/bloc/form_action_binding_bloc.dart';

import 'action_binding_empty_workbench_widget.dart';
import 'action_binding_trigger_selection_panel_widget.dart';

class ActionBindingPlannerWidget extends StatelessWidget {
  final FormActionBindingState state;
  final ValueChanged<String> onSelectAction;
  final ValueChanged<String> onSelectTrigger;

  const ActionBindingPlannerWidget({
    super.key,
    required this.state,
    required this.onSelectAction,
    required this.onSelectTrigger,
  });

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedSourceItem;

    return selected == null
        ? const ActionBindingEmptyWorkbenchWidget()
        : ActionBindingTriggerSelectionPanelWidget(
            selected: selected,
            selectedActionName: state.selectedActionName,
            selectedTrigger: state.selectedTrigger,
            onSelectAction: onSelectAction,
            onSelectTrigger: onSelectTrigger,
          );
  }
}
