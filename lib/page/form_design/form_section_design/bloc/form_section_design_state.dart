part of 'form_section_design_bloc.dart';

enum FormSectionDesignStatus {
  init,
  loading,
  success,
  failure,
  exportSuccess,
  promptDraftName,
  savedDraft,
}

class FormSectionDesignState extends Equatable {
  final FormSectionDesignStatus status;
  final String message;
  final List<DesignerItem> items;
  final String exportedJson;
  final String selectedItemId;
  final int rowCount;
  final String draftName;
  final String draftDescription;
  final String editingSectionId;
  final String editingFormId;
  final List<ConditionFieldDefinition> availableConditionFields;

  const FormSectionDesignState({
    this.status = FormSectionDesignStatus.init,
    this.message = '',
    this.items = const [],
    this.exportedJson = '',
    this.selectedItemId = '',
    this.rowCount = 1,
    this.draftName = '',
    this.draftDescription = '',
    this.editingSectionId = '',
    this.editingFormId = '',
    this.availableConditionFields = const [],
  });

  FormSectionDesignState copyWith({
    FormSectionDesignStatus? status,
    String? message,
    List<DesignerItem>? items,
    String? exportedJson,
    String? selectedItemId,
    int? rowCount,
    String? draftName,
    String? draftDescription,
    String? editingSectionId,
    String? editingFormId,
    List<ConditionFieldDefinition>? availableConditionFields,
  }) {
    return FormSectionDesignState(
      status: status ?? this.status,
      message: message ?? this.message,
      items: items ?? this.items,
      exportedJson: exportedJson ?? this.exportedJson,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      rowCount: rowCount ?? this.rowCount,
      draftName: draftName ?? this.draftName,
      draftDescription: draftDescription ?? this.draftDescription,
      editingSectionId: editingSectionId ?? this.editingSectionId,
      editingFormId: editingFormId ?? this.editingFormId,
      availableConditionFields:
          availableConditionFields ?? this.availableConditionFields,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        items,
        exportedJson,
        selectedItemId,
        rowCount,
        draftName,
        draftDescription,
        editingSectionId,
        editingFormId,
        availableConditionFields,
      ];
}
