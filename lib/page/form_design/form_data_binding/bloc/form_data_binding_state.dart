part of 'form_data_binding_bloc.dart';

enum FormDataBindingStatus {
  init,
  loading,
  ready,
  saving,
  exportJsonPreview,
  saveSuccess,
  failure,
}

class FormDataBindingState extends Equatable {
  final FormDataBindingStatus status;
  final String message;
  final String formId;
  final String bindingId;
  final String formName;
  final FormDataBindingDraft draft;
  final Map<String, String> fieldErrors;
  final String exportedJson;

  const FormDataBindingState({
    this.status = FormDataBindingStatus.init,
    this.message = '',
    this.formId = '',
    this.bindingId = '',
    this.formName = '',
    this.draft = const FormDataBindingDraft(),
    this.fieldErrors = const {},
    this.exportedJson = '',
  });

  int get totalSections => draft.sections.length;

  int get totalFields => draft.totalFields;

  int get errorCount => fieldErrors.length;

  FormDataBindingState copyWith({
    FormDataBindingStatus? status,
    String? message,
    String? formId,
    String? bindingId,
    String? formName,
    FormDataBindingDraft? draft,
    Map<String, String>? fieldErrors,
    String? exportedJson,
  }) {
    return FormDataBindingState(
      status: status ?? this.status,
      message: message ?? this.message,
      formId: formId ?? this.formId,
      bindingId: bindingId ?? this.bindingId,
      formName: formName ?? this.formName,
      draft: draft ?? this.draft,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      exportedJson: exportedJson ?? this.exportedJson,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        formId,
        bindingId,
        formName,
        draft,
        fieldErrors,
        exportedJson,
      ];
}
