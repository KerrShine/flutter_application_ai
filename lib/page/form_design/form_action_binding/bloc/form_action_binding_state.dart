part of 'form_action_binding_bloc.dart';

enum FormActionBindingStatus {
  init,
  loading,
  ready,
  saving,
  saveSuccess,
  exportPreview,
  failure,
}

enum FormActionBindingHintTone {
  warning,
  info,
  success,
}

class FormActionBindingHintItem extends Equatable {
  final String text;
  final FormActionBindingHintTone tone;

  const FormActionBindingHintItem(this.text, this.tone);

  @override
  List<Object> get props => [text, tone];
}

class FormActionBindingState extends Equatable {
  final FormActionBindingStatus status;
  final String message;
  final FormDataBindingDraft draft;
  final String formId;
  final String bindingId;
  final String formName;
  final String bindingName;
  final List<FormActionSourceItem> sourceItems;
  final String searchKeyword;
  final String selectedSourceItemId;
  final String selectedTrigger;
  final String previewJson;
  final List<FormActionBindingDraft> actions;

  const FormActionBindingState({
    this.status = FormActionBindingStatus.init,
    this.message = '',
    this.draft = const FormDataBindingDraft(),
    this.formId = '',
    this.bindingId = '',
    this.formName = '',
    this.bindingName = '',
    this.sourceItems = const [],
    this.searchKeyword = '',
    this.selectedSourceItemId = '',
    this.selectedTrigger = '',
    this.previewJson = '',
    this.actions = const [],
  });

  List<FormActionSourceItem> get filteredSourceItems {
    final keyword = searchKeyword.trim().toLowerCase();
    if (keyword.isEmpty) {
      return sourceItems;
    }

    return sourceItems.where((item) {
      return item.label.toLowerCase().contains(keyword) ||
          item.itemId.toLowerCase().contains(keyword) ||
          _sourceTypeLabel(item.sourceType).toLowerCase().contains(keyword);
    }).toList();
  }

  FormActionSourceItem? get selectedSourceItem {
    for (final item in sourceItems) {
      if (item.itemId == selectedSourceItemId) {
        return item;
      }
    }
    return null;
  }

  List<FormActionBindingDraft> get selectedTriggerActions {
    final triggerType = _resolveTriggerType(selectedTrigger);
    if (selectedSourceItemId.isEmpty || triggerType == null) {
      return const [];
    }

    return actions.where((item) {
      return item.sourceItemId == selectedSourceItemId &&
          item.triggerType == triggerType;
    }).toList();
  }

  List<String> get selectedActionNames {
    return selectedTriggerActions.map((item) => item.actionType.name).toList();
  }

  String get selectedActionName {
    if (selectedTriggerActions.isEmpty) {
      return '';
    }

    return selectedTriggerActions.first.actionType.name;
  }

  FormActionBindingState copyWith({
    FormActionBindingStatus? status,
    String? message,
    FormDataBindingDraft? draft,
    String? formId,
    String? bindingId,
    String? formName,
    String? bindingName,
    List<FormActionSourceItem>? sourceItems,
    String? searchKeyword,
    String? selectedSourceItemId,
    String? selectedTrigger,
    String? previewJson,
    List<FormActionBindingDraft>? actions,
  }) {
    return FormActionBindingState(
      status: status ?? this.status,
      message: message ?? this.message,
      draft: draft ?? this.draft,
      formId: formId ?? this.formId,
      bindingId: bindingId ?? this.bindingId,
      formName: formName ?? this.formName,
      bindingName: bindingName ?? this.bindingName,
      sourceItems: sourceItems ?? this.sourceItems,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      selectedSourceItemId: selectedSourceItemId ?? this.selectedSourceItemId,
      selectedTrigger: selectedTrigger ?? this.selectedTrigger,
      previewJson: previewJson ?? this.previewJson,
      actions: actions ?? this.actions,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        draft,
        formId,
        bindingId,
        formName,
        bindingName,
        sourceItems,
        searchKeyword,
        selectedSourceItemId,
        selectedTrigger,
        previewJson,
        actions,
      ];

  String _sourceTypeLabel(String sourceType) {
    switch (sourceType) {
      case 'button':
        return '按鈕';
      case 'dropdown':
        return '下拉選單';
      default:
        return sourceType;
    }
  }

  ActionTriggerType? _resolveTriggerType(String trigger) {
    for (final item in ActionTriggerType.values) {
      if (item.name == trigger) {
        return item;
      }
    }

    return null;
  }
}
