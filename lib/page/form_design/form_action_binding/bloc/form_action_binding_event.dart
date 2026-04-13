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

class UpdateSearchKeywordEvent extends FormActionBindingEvent {
  final String keyword;

  const UpdateSearchKeywordEvent(this.keyword);

  @override
  List<Object> get props => [keyword];
}
