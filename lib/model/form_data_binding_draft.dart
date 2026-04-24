import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/designer_item_type.dart';

enum BindingFieldValueType {
  string,
  number,
  date,
  file,
}

enum BindingFieldKind {
  value,
  button,
}

enum BindingNullStrategy {
  skip,
  custom,
}

enum ActionTriggerType {
  buttonPressed,
  dropdownChanged,
  dropdownLoaded,
}

enum ActionType {
  navigate,
  saveDraft,
  submitForm,
  callApi,
  loadDropdownOptions,
  refreshTarget,
  setFieldValue,
  other,
}

class FormActionBindingDraft extends Equatable {
  final String actionId;
  final String sourceItemId;
  final String sourceLabel;
  final String sourceType;
  final ActionTriggerType triggerType;
  final ActionType actionType;
  final bool enabled;
  final String targetItemId;
  final String targetLabel;
  final String navigateRoute;
  final String description;
  final String apiId;
  final String parameterName;
  final int order;

  const FormActionBindingDraft({
    this.actionId = '',
    this.sourceItemId = '',
    this.sourceLabel = '',
    this.sourceType = '',
    this.triggerType = ActionTriggerType.buttonPressed,
    this.actionType = ActionType.navigate,
    this.enabled = true,
    this.targetItemId = '',
    this.targetLabel = '',
    this.navigateRoute = '',
    this.description = '',
    this.apiId = '',
    this.parameterName = '',
    this.order = 0,
  });

  FormActionBindingDraft copyWith({
    String? actionId,
    String? sourceItemId,
    String? sourceLabel,
    String? sourceType,
    ActionTriggerType? triggerType,
    ActionType? actionType,
    bool? enabled,
    String? targetItemId,
    String? targetLabel,
    String? navigateRoute,
    String? description,
    String? apiId,
    String? parameterName,
    int? order,
  }) {
    return FormActionBindingDraft(
      actionId: actionId ?? this.actionId,
      sourceItemId: sourceItemId ?? this.sourceItemId,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      sourceType: sourceType ?? this.sourceType,
      triggerType: triggerType ?? this.triggerType,
      actionType: actionType ?? this.actionType,
      enabled: enabled ?? this.enabled,
      targetItemId: targetItemId ?? this.targetItemId,
      targetLabel: targetLabel ?? this.targetLabel,
      navigateRoute: navigateRoute ?? this.navigateRoute,
      description: description ?? this.description,
      apiId: apiId ?? this.apiId,
      parameterName: parameterName ?? this.parameterName,
      order: order ?? this.order,
    );
  }

  String get triggerLabel {
    switch (triggerType) {
      case ActionTriggerType.buttonPressed:
        return 'buttonPressed';
      case ActionTriggerType.dropdownChanged:
        return 'dropdownChanged';
      case ActionTriggerType.dropdownLoaded:
        return 'dropdownLoaded';
    }
  }

  String get actionLabel {
    switch (actionType) {
      case ActionType.navigate:
        return 'navigate';
      case ActionType.saveDraft:
        return 'saveDraft';
      case ActionType.submitForm:
        return 'submitForm';
      case ActionType.callApi:
        return 'callApi';
      case ActionType.loadDropdownOptions:
        return 'loadDropdownOptions';
      case ActionType.refreshTarget:
        return 'refreshTarget';
      case ActionType.setFieldValue:
        return 'setFieldValue';
      case ActionType.other:
        return 'other';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'actionId': actionId,
      'sourceItemId': sourceItemId,
      'sourceLabel': sourceLabel,
      'sourceType': sourceType,
      'triggerType': triggerType.name,
      'actionType': actionType.name,
      'enabled': enabled,
      'targetItemId': targetItemId,
      'targetLabel': targetLabel,
      'navigateRoute': navigateRoute,
      'description': description,
      'apiId': apiId,
      'parameterName': parameterName,
      'order': order,
    };
  }

  factory FormActionBindingDraft.fromMap(Map<String, dynamic> map) {
    return FormActionBindingDraft(
      actionId: map['actionId'] ?? '',
      sourceItemId: map['sourceItemId'] ?? '',
      sourceLabel: map['sourceLabel'] ?? '',
      sourceType: map['sourceType'] ?? '',
      triggerType: ActionTriggerType.values.firstWhere(
        (item) => item.name == map['triggerType'],
        orElse: () => ActionTriggerType.buttonPressed,
      ),
      actionType: ActionType.values.firstWhere(
        (item) => item.name == map['actionType'],
        orElse: () => ActionType.navigate,
      ),
      enabled: map['enabled'] as bool? ?? true,
      targetItemId: map['targetItemId'] ?? '',
      targetLabel: map['targetLabel'] ?? '',
      navigateRoute: map['navigateRoute'] ?? '',
      description: map['description'] ?? '',
      apiId: map['apiId'] ?? '',
      parameterName: map['parameterName'] ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object> get props => [
        actionId,
        sourceItemId,
        sourceLabel,
        sourceType,
        triggerType,
        actionType,
        enabled,
        targetItemId,
        targetLabel,
        navigateRoute,
        description,
        apiId,
        parameterName,
        order,
      ];
}

class FormDataBindingFieldDraft extends Equatable {
  final String itemId;
  final String label;
  final String fieldName;
  final String sourceType;
  final BindingFieldKind fieldKind;
  final BindingFieldValueType valueType;
  final bool required;
  final String outputKey;
  final BindingNullStrategy nullStrategy;
  final String customDefaultValue;

  const FormDataBindingFieldDraft({
    this.itemId = '',
    this.label = '',
    this.fieldName = '',
    this.sourceType = '',
    this.fieldKind = BindingFieldKind.value,
    this.valueType = BindingFieldValueType.string,
    this.required = false,
    this.outputKey = '',
    this.nullStrategy = BindingNullStrategy.skip,
    this.customDefaultValue = '',
  });

  FormDataBindingFieldDraft copyWith({
    String? itemId,
    String? label,
    String? fieldName,
    String? sourceType,
    BindingFieldKind? fieldKind,
    BindingFieldValueType? valueType,
    bool? required,
    String? outputKey,
    BindingNullStrategy? nullStrategy,
    String? customDefaultValue,
  }) {
    return FormDataBindingFieldDraft(
      itemId: itemId ?? this.itemId,
      label: label ?? this.label,
      fieldName: fieldName ?? this.fieldName,
      sourceType: sourceType ?? this.sourceType,
      fieldKind: fieldKind ?? this.fieldKind,
      valueType: valueType ?? this.valueType,
      required: required ?? this.required,
      outputKey: outputKey ?? this.outputKey,
      nullStrategy: nullStrategy ?? this.nullStrategy,
      customDefaultValue: customDefaultValue ?? this.customDefaultValue,
    );
  }

  String get displayTypeLabel {
    if (fieldKind == BindingFieldKind.button) {
      return 'button';
    }

    if (sourceType == DesignerItemType.dropdown.name) {
      return 'dropdown';
    }

    switch (valueType) {
      case BindingFieldValueType.number:
        return 'number';
      case BindingFieldValueType.date:
        return 'date';
      case BindingFieldValueType.file:
        return 'File';
      case BindingFieldValueType.string:
        return 'string';
    }
  }

  String get nullStrategyLabel {
    if (fieldKind == BindingFieldKind.button) {
      return '略過';
    }

    switch (nullStrategy) {
      case BindingNullStrategy.custom:
        return '預設';
      case BindingNullStrategy.skip:
        return '略過';
    }
  }

  String get systemDefaultValue {
    if (fieldKind == BindingFieldKind.button) {
      return '預設行為';
    }

    switch (valueType) {
      case BindingFieldValueType.number:
        return '0';
      case BindingFieldValueType.date:
        final now = DateTime.now();
        final month = now.month.toString().padLeft(2, '0');
        final day = now.day.toString().padLeft(2, '0');
        return '${now.year}-$month-$day';
      case BindingFieldValueType.file:
        return 'File';
      case BindingFieldValueType.string:
        return '';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'label': label,
      'fieldName': fieldName,
      'sourceType': sourceType,
      'fieldKind': fieldKind.name,
      'valueType': valueType.name,
      'required': required,
      'outputKey': outputKey,
      'nullStrategy': nullStrategy.name,
      'customDefaultValue': customDefaultValue,
    };
  }

  factory FormDataBindingFieldDraft.fromMap(Map<String, dynamic> map) {
    return FormDataBindingFieldDraft(
      itemId: map['itemId'] ?? '',
      label: map['label'] ?? '',
      fieldName: map['fieldName'] ?? '',
      sourceType: map['sourceType'] ?? '',
      fieldKind: BindingFieldKind.values.firstWhere(
        (item) => item.name == map['fieldKind'],
        orElse: () => BindingFieldKind.value,
      ),
      valueType: BindingFieldValueType.values.firstWhere(
        (item) => item.name == map['valueType'],
        orElse: () => BindingFieldValueType.string,
      ),
      required: map['required'] as bool? ?? false,
      outputKey: map['outputKey'] ?? '',
      nullStrategy: BindingNullStrategy.values.firstWhere(
        (item) => item.name == map['nullStrategy'],
        orElse: () => BindingNullStrategy.skip,
      ),
      customDefaultValue: map['customDefaultValue'] ?? '',
    );
  }

  @override
  List<Object> get props => [
        itemId,
        label,
        fieldName,
        sourceType,
        fieldKind,
        valueType,
        required,
        outputKey,
        nullStrategy,
        customDefaultValue,
      ];
}

class FormDataBindingSectionDraft extends Equatable {
  final String sectionId;
  final String sectionName;
  final String description;
  final List<FormDataBindingFieldDraft> fields;

  const FormDataBindingSectionDraft({
    this.sectionId = '',
    this.sectionName = '',
    this.description = '',
    this.fields = const [],
  });

  FormDataBindingSectionDraft copyWith({
    String? sectionId,
    String? sectionName,
    String? description,
    List<FormDataBindingFieldDraft>? fields,
  }) {
    return FormDataBindingSectionDraft(
      sectionId: sectionId ?? this.sectionId,
      sectionName: sectionName ?? this.sectionName,
      description: description ?? this.description,
      fields: fields ?? this.fields,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectionId': sectionId,
      'sectionName': sectionName,
      'description': description,
      'fields': fields.map((item) => item.toMap()).toList(),
    };
  }

  factory FormDataBindingSectionDraft.fromMap(Map<String, dynamic> map) {
    final rawFields = map['fields'] as List<dynamic>? ?? const [];
    return FormDataBindingSectionDraft(
      sectionId: map['sectionId'] ?? '',
      sectionName: map['sectionName'] ?? '',
      description: map['description'] ?? '',
      fields: rawFields
          .map((item) => FormDataBindingFieldDraft.fromMap(
                item as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  @override
  List<Object> get props => [sectionId, sectionName, description, fields];
}

class FormDataBindingDraft extends Equatable {
  final String bindingId;
  final String bindingName;
  final String bindingDescription;
  final bool isEnabled;
  final int templateVersion;
  final String formId;
  final String formName;
  final String formSize;
  final String updatedAt;
  final List<FormDataBindingSectionDraft> sections;
  final List<FormActionBindingDraft> actions;

  const FormDataBindingDraft({
    this.bindingId = '',
    this.bindingName = '',
    this.bindingDescription = '',
    this.isEnabled = true,
    this.templateVersion = 1,
    this.formId = '',
    this.formName = '',
    this.formSize = '',
    this.updatedAt = '',
    this.sections = const [],
    this.actions = const [],
  });

  int get totalFields => sections.fold(
        0,
        (previousValue, section) => previousValue + section.fields.length,
      );

  int get totalActions => actions.length;

  FormDataBindingDraft copyWith({
    String? bindingId,
    String? bindingName,
    String? bindingDescription,
    bool? isEnabled,
    int? templateVersion,
    String? formId,
    String? formName,
    String? formSize,
    String? updatedAt,
    List<FormDataBindingSectionDraft>? sections,
    List<FormActionBindingDraft>? actions,
  }) {
    return FormDataBindingDraft(
      bindingId: bindingId ?? this.bindingId,
      bindingName: bindingName ?? this.bindingName,
      bindingDescription: bindingDescription ?? this.bindingDescription,
      isEnabled: isEnabled ?? this.isEnabled,
      templateVersion: templateVersion ?? this.templateVersion,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      formSize: formSize ?? this.formSize,
      updatedAt: updatedAt ?? this.updatedAt,
      sections: sections ?? this.sections,
      actions: actions ?? this.actions,
    );
  }

  FormDataBindingDraft updateField(
    String sectionId,
    String itemId,
    FormDataBindingFieldDraft Function(FormDataBindingFieldDraft field)
        transform,
  ) {
    final updatedSections = sections.map((section) {
      if (section.sectionId != sectionId) {
        return section;
      }

      final updatedFields = section.fields.map((field) {
        if (field.itemId != itemId) {
          return field;
        }
        return transform(field);
      }).toList();

      return section.copyWith(fields: updatedFields);
    }).toList();

    return copyWith(sections: updatedSections);
  }

  Map<String, dynamic> toMap() {
    return {
      'bindingId': bindingId,
      'bindingName': bindingName,
      'bindingDescription': bindingDescription,
      'isEnabled': isEnabled,
      'templateVersion': templateVersion,
      'formId': formId,
      'formName': formName,
      'formSize': formSize,
      'updatedAt': updatedAt,
      'sections': sections.map((item) => item.toMap()).toList(),
      'actions': actions.map((item) => item.toMap()).toList(),
    };
  }

  factory FormDataBindingDraft.fromMap(Map<String, dynamic> map) {
    final rawSections = map['sections'] as List<dynamic>? ?? const [];
    final rawActions = map['actions'] as List<dynamic>? ?? const [];
    return FormDataBindingDraft(
      bindingId: map['bindingId'] ?? '',
      bindingName: map['bindingName'] ?? '',
      bindingDescription: map['bindingDescription'] ?? '',
      isEnabled: map['isEnabled'] as bool? ?? true,
      templateVersion: (map['templateVersion'] as num?)?.toInt() ?? 1,
      formId: map['formId'] ?? '',
      formName: map['formName'] ?? '',
      formSize: map['formSize'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      sections: rawSections
          .map((item) => FormDataBindingSectionDraft.fromMap(
                item as Map<String, dynamic>,
              ))
          .toList(),
      actions: rawActions
          .map((item) => FormActionBindingDraft.fromMap(
                item as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  @override
  List<Object> get props => [
        bindingId,
        bindingName,
        bindingDescription,
        isEnabled,
        templateVersion,
        formId,
        formName,
        formSize,
        updatedAt,
        sections,
        actions,
      ];
}
