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

class SaveDraftEvent extends FormDataBindingEvent {
  const SaveDraftEvent();
}

class ExportJsonPreviewEvent extends FormDataBindingEvent {
  const ExportJsonPreviewEvent();
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
