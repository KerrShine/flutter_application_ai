part of 'form_run_bloc.dart';

class FormRunEvent extends Equatable {
  const FormRunEvent();

  @override
  List<Object> get props => [];
}

class FormRunInitEvent extends FormRunEvent {
  final String formId;
  final String bindingId;

  const FormRunInitEvent(this.formId, {this.bindingId = ''});

  @override
  List<Object> get props => [formId, bindingId];
}

class FormRunFieldChangedEvent extends FormRunEvent {
  final String itemId;
  final String value;

  const FormRunFieldChangedEvent(this.itemId, this.value);

  @override
  List<Object> get props => [itemId, value];
}

class FormRunButtonPressedEvent extends FormRunEvent {
  final String itemId;

  const FormRunButtonPressedEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class FormRunDropdownLoadedEvent extends FormRunEvent {
  final String itemId;

  const FormRunDropdownLoadedEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class FormRunDropdownChangedEvent extends FormRunEvent {
  final String itemId;
  final String value;

  const FormRunDropdownChangedEvent(this.itemId, this.value);

  @override
  List<Object> get props => [itemId, value];
}

class FormRunDismissResultEvent extends FormRunEvent {
  const FormRunDismissResultEvent();
}
