import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/form_model.dart';

enum FormManageStatus { init, loading, success, failure }

class FormManageState extends Equatable {
  final FormManageStatus status;
  final String message;
  final List<FormModel> forms;

  const FormManageState({
    this.status = FormManageStatus.init,
    this.message = '',
    this.forms = const [],
  });

  FormManageState copyWith({
    FormManageStatus? status,
    String? message,
    List<FormModel>? forms,
  }) {
    return FormManageState(
      status: status ?? this.status,
      message: message ?? this.message,
      forms: forms ?? this.forms,
    );
  }

  @override
  List<Object> get props => [status, message, forms];
}
