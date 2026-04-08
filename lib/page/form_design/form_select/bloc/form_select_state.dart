part of 'form_select_bloc.dart';

enum FormSelectStatus {
  init,
  loading,
  success,
  failure,
  navigateToBinding,
}

class FormSelectState extends Equatable {
  final FormSelectStatus status;
  final String message;
  final List<FormModel> forms;
  final List<FormModel> filteredForms;
  final String searchQuery;
  final String navigateFormId;

  const FormSelectState({
    this.status = FormSelectStatus.init,
    this.message = '',
    this.forms = const [],
    this.filteredForms = const [],
    this.searchQuery = '',
    this.navigateFormId = '',
  });

  FormSelectState copyWith({
    FormSelectStatus? status,
    String? message,
    List<FormModel>? forms,
    List<FormModel>? filteredForms,
    String? searchQuery,
    String? navigateFormId,
  }) {
    return FormSelectState(
      status: status ?? this.status,
      message: message ?? this.message,
      forms: forms ?? this.forms,
      filteredForms: filteredForms ?? this.filteredForms,
      searchQuery: searchQuery ?? this.searchQuery,
      navigateFormId: navigateFormId ?? this.navigateFormId,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        forms,
        filteredForms,
        searchQuery,
        navigateFormId,
      ];
}
