part of 'form_data_manager_bloc.dart';

enum FormDataManagerStatus {
  init,
  loading,
  success,
  failure,
  confirmDeleteBinding,
  deleteSuccess,
  exportJsonPreview,
  exportApiPreview,
  navigateToDataBinding,
}

enum BindingHealthStatus {
  healthy,
  warning,
  outdated,
}

enum FieldBindingIssueStatus {
  mapped,
  unmapped,
  versionMismatch,
}

class BindingSummary extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final int templateVersion;
  final BindingHealthStatus healthStatus;
  final int unmappedCount;
  final int warningCount;

  const BindingSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.templateVersion,
    required this.healthStatus,
    required this.unmappedCount,
    required this.warningCount,
  });

  @override
  List<Object> get props => [
        id,
        name,
        description,
        isEnabled,
        templateVersion,
        healthStatus,
        unmappedCount,
        warningCount,
      ];
}

class FieldBindingItem extends Equatable {
  final String sectionName;
  final String label;
  final String itemId;
  final String fieldType;
  final bool required;
  final String outputKey;
  final String nullStrategy;
  final bool enabled;
  final String sourceHint;
  final FieldBindingIssueStatus issueStatus;

  const FieldBindingItem({
    required this.sectionName,
    required this.label,
    required this.itemId,
    required this.fieldType,
    required this.required,
    required this.outputKey,
    required this.nullStrategy,
    required this.enabled,
    required this.sourceHint,
    required this.issueStatus,
  });

  @override
  List<Object> get props => [
        sectionName,
        label,
        itemId,
        fieldType,
        required,
        outputKey,
        nullStrategy,
        enabled,
        sourceHint,
        issueStatus,
      ];
}

class FormDataManagerState extends Equatable {
  final FormDataManagerStatus status;
  final String message;
  final String formId;
  final String formName;
  final String templateId;
  final int latestTemplateVersion;
  final String selectedBindingId;
  final String exportedJson;
  final String navigateFormId;
  final String navigateBindingId;
  final String pendingDeleteBindingId;
  final String pendingDeleteBindingName;
  final List<BindingSummary> bindings;
  final List<FormDataBindingDraft> bindingDrafts;
  final List<FieldBindingItem> fieldBindings;

  const FormDataManagerState({
    this.status = FormDataManagerStatus.init,
    this.message = '',
    this.formId = '',
    this.formName = '',
    this.templateId = '',
    this.latestTemplateVersion = 0,
    this.selectedBindingId = '',
    this.exportedJson = '',
    this.navigateFormId = '',
    this.navigateBindingId = '',
    this.pendingDeleteBindingId = '',
    this.pendingDeleteBindingName = '',
    this.bindings = const [],
    this.bindingDrafts = const [],
    this.fieldBindings = const [],
  });

  BindingSummary? get selectedBinding {
    for (final binding in bindings) {
      if (binding.id == selectedBindingId) {
        return binding;
      }
    }
    return null;
  }

  FormDataManagerState copyWith({
    FormDataManagerStatus? status,
    String? message,
    String? formId,
    String? formName,
    String? templateId,
    int? latestTemplateVersion,
    String? selectedBindingId,
    String? exportedJson,
    String? navigateFormId,
    String? navigateBindingId,
    String? pendingDeleteBindingId,
    String? pendingDeleteBindingName,
    List<BindingSummary>? bindings,
    List<FormDataBindingDraft>? bindingDrafts,
    List<FieldBindingItem>? fieldBindings,
  }) {
    return FormDataManagerState(
      status: status ?? this.status,
      message: message ?? this.message,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      templateId: templateId ?? this.templateId,
      latestTemplateVersion:
          latestTemplateVersion ?? this.latestTemplateVersion,
      selectedBindingId: selectedBindingId ?? this.selectedBindingId,
      exportedJson: exportedJson ?? this.exportedJson,
      navigateFormId: navigateFormId ?? this.navigateFormId,
      navigateBindingId: navigateBindingId ?? this.navigateBindingId,
      pendingDeleteBindingId:
          pendingDeleteBindingId ?? this.pendingDeleteBindingId,
      pendingDeleteBindingName:
          pendingDeleteBindingName ?? this.pendingDeleteBindingName,
      bindings: bindings ?? this.bindings,
      bindingDrafts: bindingDrafts ?? this.bindingDrafts,
      fieldBindings: fieldBindings ?? this.fieldBindings,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        formId,
        formName,
        templateId,
        latestTemplateVersion,
        selectedBindingId,
        exportedJson,
        navigateFormId,
        navigateBindingId,
        pendingDeleteBindingId,
        pendingDeleteBindingName,
        bindings,
        bindingDrafts,
        fieldBindings,
      ];
}
