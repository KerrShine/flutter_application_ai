import 'package:equatable/equatable.dart';

abstract class FormCreateEvent extends Equatable {
  const FormCreateEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends FormCreateEvent {
  const InitEvent();
}

class SubmitFormCreateEvent extends FormCreateEvent {
  final String formName;
  final String formSize;

  const SubmitFormCreateEvent({required this.formName, required this.formSize});

  @override
  List<Object> get props => [formName, formSize];
}
