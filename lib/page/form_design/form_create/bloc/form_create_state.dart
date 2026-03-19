import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/form_model.dart';

enum FormCreateStatus {
  init,
  loading,
  success,
  failure,
}

class FormCreateState extends Equatable {
  final FormCreateStatus status;
  final String message;
  final FormModel? createdForm;

  const FormCreateState({
    this.status = FormCreateStatus.init,
    this.message = '',
    this.createdForm,
  });

  FormCreateState copyWith({
    FormCreateStatus? status,
    String? message,
    FormModel? createdForm,
  }) {
    return FormCreateState(
      status: status ?? this.status,
      message: message ?? this.message,
      createdForm: createdForm ?? this.createdForm,
    );
  }

  @override
  List<Object?> get props => [status, message, createdForm];
}
