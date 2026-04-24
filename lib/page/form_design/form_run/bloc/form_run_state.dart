part of 'form_run_bloc.dart';

enum FormRunStatus {
  init,
  loading,
  ready,
  executingAction,
  actionSuccess,
  actionFailure,
  navigating,
}

class FormRunState extends Equatable {
  final FormRunStatus status;
  final String message;
  final String formName;
  final String formId;
  final String bindingId;
  final List<SectionModel> sections;
  final FormDataBindingDraft draft;
  final Map<String, ApiDefinition> apiMap;
  final Map<String, List<String>> dropdownOptionsOverride;
  final Map<String, FormRunFieldValue> fieldValues;
  final String? pendingNavigateRoute;
  final Map<String, dynamic>? lastApiResponse;

  const FormRunState({
    this.status = FormRunStatus.init,
    this.message = '',
    this.formName = '',
    this.formId = '',
    this.bindingId = '',
    this.sections = const [],
    this.draft = const FormDataBindingDraft(),
    this.apiMap = const {},
    this.dropdownOptionsOverride = const {},
    this.fieldValues = const {},
    this.pendingNavigateRoute,
    this.lastApiResponse,
  });

  FormRunState copyWith({
    FormRunStatus? status,
    String? message,
    String? formName,
    String? formId,
    String? bindingId,
    List<SectionModel>? sections,
    FormDataBindingDraft? draft,
    Map<String, ApiDefinition>? apiMap,
    Map<String, List<String>>? dropdownOptionsOverride,
    Map<String, FormRunFieldValue>? fieldValues,
    String? pendingNavigateRoute,
    Map<String, dynamic>? lastApiResponse,
    bool clearNavigateRoute = false,
    bool clearApiResponse = false,
  }) {
    return FormRunState(
      status: status ?? this.status,
      message: message ?? this.message,
      formName: formName ?? this.formName,
      formId: formId ?? this.formId,
      bindingId: bindingId ?? this.bindingId,
      sections: sections ?? this.sections,
      draft: draft ?? this.draft,
      apiMap: apiMap ?? this.apiMap,
      dropdownOptionsOverride:
          dropdownOptionsOverride ?? this.dropdownOptionsOverride,
      fieldValues: fieldValues ?? this.fieldValues,
      pendingNavigateRoute:
          clearNavigateRoute ? null : (pendingNavigateRoute ?? this.pendingNavigateRoute),
      lastApiResponse:
          clearApiResponse ? null : (lastApiResponse ?? this.lastApiResponse),
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        formName,
        formId,
        bindingId,
        sections,
        draft,
        apiMap,
        dropdownOptionsOverride,
        fieldValues,
        pendingNavigateRoute,
        lastApiResponse,
      ];
}
