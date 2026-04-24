part of 'form_data_binding_bloc.dart';

enum FormDataBindingStatus {
  init,
  loading,
  ready,
  confirmBindingName,
  navigateToActionBinding,
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
  final String pendingBindingName;
  final String navigateFormId;
  final String navigateBindingId;
  final String navigateSourceItemId;

  const FormDataBindingState({
    this.status = FormDataBindingStatus.init,
    this.message = '',
    this.formId = '',
    this.bindingId = '',
    this.formName = '',
    this.draft = const FormDataBindingDraft(),
    this.fieldErrors = const {},
    this.exportedJson = '',
    this.pendingBindingName = '',
    this.navigateFormId = '',
    this.navigateBindingId = '',
    this.navigateSourceItemId = '',
  });

  int get totalSections => draft.sections.length;

  int get totalFields => draft.totalFields;

  int get errorCount => fieldErrors.length;

  String actionSummaryForItem(String itemId) {
    final actions = draft.actions.where((item) {
      return item.sourceItemId == itemId && item.enabled;
    }).toList()
      ..sort((left, right) {
        return _actionTriggerSortOrder(left.triggerType)
            .compareTo(_actionTriggerSortOrder(right.triggerType));
      });

    if (actions.isEmpty) {
      return '尚未選擇動作';
    }

    return actions.map((item) {
      return '• ${formActionTriggerDisplayName(item.triggerType.name)} / ${formActionDisplayName(item.actionType.name)}';
    }).join('\n');
  }

  String errorForField(String sectionId, String itemId) {
    return fieldErrors[_buildFieldKey(sectionId, itemId)] ?? '';
  }

  int _actionTriggerSortOrder(ActionTriggerType triggerType) {
    switch (triggerType) {
      case ActionTriggerType.buttonPressed:
        return 0;
      case ActionTriggerType.dropdownChanged:
        return 0;
      case ActionTriggerType.dropdownLoaded:
        return 1;
    }
  }

  String _buildFieldKey(String sectionId, String itemId) {
    return '$sectionId::$itemId';
  }

  FormDataBindingState copyWith({
    FormDataBindingStatus? status,
    String? message,
    String? formId,
    String? bindingId,
    String? formName,
    FormDataBindingDraft? draft,
    Map<String, String>? fieldErrors,
    String? exportedJson,
    String? pendingBindingName,
    String? navigateFormId,
    String? navigateBindingId,
    String? navigateSourceItemId,
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
      pendingBindingName: pendingBindingName ?? this.pendingBindingName,
      navigateFormId: navigateFormId ?? this.navigateFormId,
      navigateBindingId: navigateBindingId ?? this.navigateBindingId,
      navigateSourceItemId: navigateSourceItemId ?? this.navigateSourceItemId,
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
        pendingBindingName,
        navigateFormId,
        navigateBindingId,
        navigateSourceItemId,
      ];
}
