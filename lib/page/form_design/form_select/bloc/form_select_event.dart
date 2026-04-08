part of 'form_select_bloc.dart';

class FormSelectEvent extends Equatable {
  const FormSelectEvent();

  @override
  List<Object> get props => [];
}

class CompleteNavigationEvent extends FormSelectEvent {
  const CompleteNavigationEvent();
}

class InitEvent extends FormSelectEvent {
  const InitEvent();
}

class NavigateToBindingEvent extends FormSelectEvent {
  final String formId;

  const NavigateToBindingEvent(this.formId);

  @override
  List<Object> get props => [formId];
}

class UpdateSearchQueryEvent extends FormSelectEvent {
  final String searchQuery;

  const UpdateSearchQueryEvent(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}
