part of 'form_action_binding_bloc.dart';

class FormActionBindingEvent extends Equatable {
  const FormActionBindingEvent();

  @override
  List<Object> get props => [];
}

class CompleteStatusEvent extends FormActionBindingEvent {
  const CompleteStatusEvent();
}

class RequestExportPreviewEvent extends FormActionBindingEvent {
  const RequestExportPreviewEvent();
}

class SaveActionSettingsEvent extends FormActionBindingEvent {
  const SaveActionSettingsEvent();
}

class InitEvent extends FormActionBindingEvent {
  final String formId;
  final String bindingId;
  final String initialSourceItemId;

  const InitEvent(
    this.formId, {
    this.bindingId = '',
    this.initialSourceItemId = '',
  });

  @override
  List<Object> get props => [formId, bindingId, initialSourceItemId];
}

class SelectSourceItemEvent extends FormActionBindingEvent {
  final String itemId;

  const SelectSourceItemEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class SelectTriggerEvent extends FormActionBindingEvent {
  final String trigger;

  const SelectTriggerEvent(this.trigger);

  @override
  List<Object> get props => [trigger];
}

class SelectActionEvent extends FormActionBindingEvent {
  final String action;

  const SelectActionEvent(this.action);

  @override
  List<Object> get props => [action];
}

class AddActionEvent extends FormActionBindingEvent {
  final String action;

  const AddActionEvent(this.action);

  @override
  List<Object> get props => [action];
}

class RemoveActionEvent extends FormActionBindingEvent {
  final String actionId;

  const RemoveActionEvent(this.actionId);

  @override
  List<Object> get props => [actionId];
}

class MoveActionUpEvent extends FormActionBindingEvent {
  final String actionId;

  const MoveActionUpEvent(this.actionId);

  @override
  List<Object> get props => [actionId];
}

class MoveActionDownEvent extends FormActionBindingEvent {
  final String actionId;

  const MoveActionDownEvent(this.actionId);

  @override
  List<Object> get props => [actionId];
}

class UpdateActionApiIdEvent extends FormActionBindingEvent {
  final String actionId;
  final String apiId;

  const UpdateActionApiIdEvent(this.actionId, this.apiId);

  @override
  List<Object> get props => [actionId, apiId];
}

class UpdateActionNavigateRouteEvent extends FormActionBindingEvent {
  final String actionId;
  final String route;

  const UpdateActionNavigateRouteEvent(this.actionId, this.route);

  @override
  List<Object> get props => [actionId, route];
}

class UpdateActionParameterNameEvent extends FormActionBindingEvent {
  final String actionId;
  final String parameterName;

  const UpdateActionParameterNameEvent(this.actionId, this.parameterName);

  @override
  List<Object> get props => [actionId, parameterName];
}

class UpdateSearchKeywordEvent extends FormActionBindingEvent {
  final String keyword;

  const UpdateSearchKeywordEvent(this.keyword);

  @override
  List<Object> get props => [keyword];
}
