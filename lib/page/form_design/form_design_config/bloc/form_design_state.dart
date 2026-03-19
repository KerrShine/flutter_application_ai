part of 'form_design_bloc.dart';

enum FormDesignStatus {
  init,
  loading,
  success,
  failure,
  saved,
  draftSaved,
  showJsonPreview,
  navigateToSection,
  navigateToBrowse,
  confirmDeleteSection,
}

class FormDesignState extends Equatable {
  final FormDesignStatus status;
  final String message;
  final String formId;
  final String formName;

  /// 左側：所有已儲存的 Section
  final List<SectionModel> availableSections;

  /// 中間畫布：已加入表單的 Section（依序）
  final List<SectionModel> selectedSections;
  final List<SectionModel> browseSections;
  final String editingSectionId;
  final String jsonPreview;
  final String pendingDeleteSectionId;

  /// 待刪除的 Section 是否已加入目前表單畫布
  final bool isDeleteSectionInUse;

  const FormDesignState({
    this.status = FormDesignStatus.init,
    this.message = '',
    this.formId = '',
    this.formName = '',
    this.availableSections = const [],
    this.selectedSections = const [],
    this.browseSections = const [],
    this.editingSectionId = '',
    this.jsonPreview = '',
    this.pendingDeleteSectionId = '',
    this.isDeleteSectionInUse = false,
  });

  FormDesignState copyWith({
    FormDesignStatus? status,
    String? message,
    String? formId,
    String? formName,
    List<SectionModel>? availableSections,
    List<SectionModel>? selectedSections,
    List<SectionModel>? browseSections,
    String? editingSectionId,
    String? jsonPreview,
    String? pendingDeleteSectionId,
    bool? isDeleteSectionInUse,
  }) {
    return FormDesignState(
      status: status ?? this.status,
      message: message ?? this.message,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      availableSections: availableSections ?? this.availableSections,
      selectedSections: selectedSections ?? this.selectedSections,
      browseSections: browseSections ?? this.browseSections,
      editingSectionId: editingSectionId ?? this.editingSectionId,
      jsonPreview: jsonPreview ?? this.jsonPreview,
      pendingDeleteSectionId:
          pendingDeleteSectionId ?? this.pendingDeleteSectionId,
      isDeleteSectionInUse: isDeleteSectionInUse ?? this.isDeleteSectionInUse,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        formId,
        formName,
        availableSections,
        selectedSections,
        browseSections,
        editingSectionId,
        jsonPreview,
        pendingDeleteSectionId,
        isDeleteSectionInUse,
      ];
}
