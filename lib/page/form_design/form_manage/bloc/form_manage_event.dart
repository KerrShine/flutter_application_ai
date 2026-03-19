import 'package:equatable/equatable.dart';

class FormManageEvent extends Equatable {
  const FormManageEvent();

  @override
  List<Object> get props => [];
}

class LoadFormsEvent extends FormManageEvent {
  const LoadFormsEvent();
}

class DeleteFormEvent extends FormManageEvent {
  final String formId;
  const DeleteFormEvent(this.formId);

  @override
  List<Object> get props => [formId];
}
