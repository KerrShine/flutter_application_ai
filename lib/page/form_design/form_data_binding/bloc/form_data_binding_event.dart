part of 'form_data_binding_bloc.dart';

class FormDataBindingEvent extends Equatable {
  const FormDataBindingEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends FormDataBindingEvent {
  final String formId;
  final String bindingId;

  const InitEvent(this.formId, {this.bindingId = ''});

  @override
  List<Object> get props => [formId, bindingId];
}

class CompleteStatusEvent extends FormDataBindingEvent {
  const CompleteStatusEvent();
}

class ConfirmSaveDraftEvent extends FormDataBindingEvent {
  final String bindingName;

  const ConfirmSaveDraftEvent(this.bindingName);

  @override
  List<Object> get props => [bindingName];
}

class RequestSaveDraftEvent extends FormDataBindingEvent {
  const RequestSaveDraftEvent();
}

class ExportJsonPreviewEvent extends FormDataBindingEvent {
  const ExportJsonPreviewEvent();
}

class CompleteNavigationEvent extends FormDataBindingEvent {
  const CompleteNavigationEvent();
}

class RequestNavigateToActionBindingEvent extends FormDataBindingEvent {
  final String sourceItemId;

  const RequestNavigateToActionBindingEvent(this.sourceItemId);

  @override
  List<Object> get props => [sourceItemId];
}

class UpdateCustomDefaultValueEvent extends FormDataBindingEvent {
  final String sectionId;
  final String itemId;
  final String value;

  const UpdateCustomDefaultValueEvent({
    required this.sectionId,
    required this.itemId,
    required this.value,
  });

  @override
  List<Object> get props => [sectionId, itemId, value];
}

class UpdateNullStrategyEvent extends FormDataBindingEvent {
  final String sectionId;
  final String itemId;
  final BindingNullStrategy nullStrategy;

  const UpdateNullStrategyEvent({
    required this.sectionId,
    required this.itemId,
    required this.nullStrategy,
  });

  @override
  List<Object> get props => [sectionId, itemId, nullStrategy];
}

class UpdateProvidedDataKeyEvent extends FormDataBindingEvent {
  final String sectionId;
  final String itemId;
  final String providedDataKey;

  const UpdateProvidedDataKeyEvent({
    required this.sectionId,
    required this.itemId,
    required this.providedDataKey,
  });

  @override
  List<Object> get props => [sectionId, itemId, providedDataKey];
}

class UpdateOutputKeyEvent extends FormDataBindingEvent {
  final String sectionId;
  final String itemId;
  final String outputKey;

  const UpdateOutputKeyEvent({
    required this.sectionId,
    required this.itemId,
    required this.outputKey,
  });

  @override
  List<Object> get props => [sectionId, itemId, outputKey];
}

class UpdateBindingEnabledEvent extends FormDataBindingEvent {
  final bool isEnabled;

  const UpdateBindingEnabledEvent(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}
