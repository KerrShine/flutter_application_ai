part of 'form_data_manager_bloc.dart';

class FormDataManagerEvent extends Equatable {
  const FormDataManagerEvent();

  @override
  List<Object> get props => [];
}

class CompleteNavigationEvent extends FormDataManagerEvent {
  const CompleteNavigationEvent();
}

class InitEvent extends FormDataManagerEvent {
  final String formId;

  const InitEvent(this.formId);

  @override
  List<Object> get props => [formId];
}

class NavigateToDataBindingEvent extends FormDataManagerEvent {
  final String formId;
  final String bindingId;

  const NavigateToDataBindingEvent(this.formId, {this.bindingId = ''});

  @override
  List<Object> get props => [formId, bindingId];
}

class SelectBindingEvent extends FormDataManagerEvent {
  final String bindingId;

  const SelectBindingEvent(this.bindingId);

  @override
  List<Object> get props => [bindingId];
}

class ExportJsonEvent extends FormDataManagerEvent {
  const ExportJsonEvent();
}

class PreviewApiExportEvent extends FormDataManagerEvent {
  const PreviewApiExportEvent();
}

class CompleteExportJsonPreviewEvent extends FormDataManagerEvent {
  const CompleteExportJsonPreviewEvent();
}
