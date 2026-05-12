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
  final String applicantId;
  final String applicantName;
  final String departmentId;

  /// 編輯模式 — 非空時表示在編輯既有 signOff；送出時走 update 分支覆寫該筆。
  final String signOffId;
  final List<SectionModel> sections;
  final FormDataBindingDraft draft;
  final Map<String, ApiDefinition> apiMap;
  final Map<String, List<String>> dropdownOptionsOverride;
  final Map<String, FormRunFieldValue> fieldValues;
  final List<ConditionFieldDefinition> conditionDefinitions;
  final Map<String, String> computedValues;
  final String? pendingNavigateRoute;
  final Map<String, dynamic>? lastApiResponse;

  const FormRunState({
    this.status = FormRunStatus.init,
    this.message = '',
    this.formName = '',
    this.formId = '',
    this.bindingId = '',
    this.applicantId = '',
    this.applicantName = '',
    this.departmentId = '',
    this.signOffId = '',
    this.sections = const [],
    this.draft = const FormDataBindingDraft(),
    this.apiMap = const {},
    this.dropdownOptionsOverride = const {},
    this.fieldValues = const {},
    this.conditionDefinitions = const [],
    this.computedValues = const {},
    this.pendingNavigateRoute,
    this.lastApiResponse,
  });

  FormRunState copyWith({
    FormRunStatus? status,
    String? message,
    String? formName,
    String? formId,
    String? bindingId,
    String? applicantId,
    String? applicantName,
    String? departmentId,
    String? signOffId,
    List<SectionModel>? sections,
    FormDataBindingDraft? draft,
    Map<String, ApiDefinition>? apiMap,
    Map<String, List<String>>? dropdownOptionsOverride,
    Map<String, FormRunFieldValue>? fieldValues,
    List<ConditionFieldDefinition>? conditionDefinitions,
    Map<String, String>? computedValues,
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
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      departmentId: departmentId ?? this.departmentId,
      signOffId: signOffId ?? this.signOffId,
      sections: sections ?? this.sections,
      draft: draft ?? this.draft,
      apiMap: apiMap ?? this.apiMap,
      dropdownOptionsOverride:
          dropdownOptionsOverride ?? this.dropdownOptionsOverride,
      fieldValues: fieldValues ?? this.fieldValues,
      conditionDefinitions:
          conditionDefinitions ?? this.conditionDefinitions,
      computedValues: computedValues ?? this.computedValues,
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
        applicantId,
        applicantName,
        departmentId,
        signOffId,
        sections,
        draft,
        apiMap,
        dropdownOptionsOverride,
        fieldValues,
        conditionDefinitions,
        computedValues,
        pendingNavigateRoute,
        lastApiResponse,
      ];
}
