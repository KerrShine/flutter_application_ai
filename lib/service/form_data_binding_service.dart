import 'dart:convert';

import 'package:flutter_application_ai/enum/designer_item_type.dart';
import 'package:flutter_application_ai/enum/text_input_type.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/form_data_binding_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/repositories/interface/section_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormDataBindingService {
  final FormDataBindingRepository _formDataBindingRepository;
  final FormRepository _formRepository;
  final SectionRepository _sectionRepository;

  FormDataBindingService(
    this._formRepository,
    this._sectionRepository,
    this._formDataBindingRepository,
  );

  Future<Result<FormDataBindingDraft>> initialize(
    String formId, {
    String bindingId = '',
  }) async {
    try {
      if (formId.isEmpty) {
        return Result.failure('找不到要執行資料綁定的表單');
      }

      final formResult = await _formRepository.loadFormById(formId);
      if (!formResult.isSuccess) {
        return Result.failure(formResult.error ?? '讀取表單失敗');
      }

      final form = formResult.data;
      if (form == null) {
        return Result.failure('找不到要執行資料綁定的表單');
      }

      final sectionsResult = await _loadOrderedSections(form);
      if (!sectionsResult.isSuccess) {
        return Result.failure(sectionsResult.error ?? '讀取區塊資料失敗');
      }

      final draftsResult =
          await _formDataBindingRepository.loadDraftsByFormId(formId);
      if (!draftsResult.isSuccess) {
        return Result.failure(draftsResult.error ?? '讀取綁定暫存失敗');
      }

      final savedDraft = bindingId.isEmpty
          ? null
          : (draftsResult.data ?? const <FormDataBindingDraft>[])
              .cast<FormDataBindingDraft?>()
              .firstWhere(
                (draft) => draft?.bindingId == bindingId,
                orElse: () => null,
              );

      final draft = _buildDraft(
        form: form,
        sections: sectionsResult.data ?? const [],
        savedDraft: savedDraft,
        bindingId: bindingId,
        existingBindingCount: draftsResult.data?.length ?? 0,
      );

      return Result.success(draft);
    } catch (ex) {
      return Result.failure('讀取資料綁定執行設定失敗：${ex.toString()}');
    }
  }

  Future<Result<bool>> saveDraft(FormDataBindingDraft draft) async {
    try {
      final errors = validateDraft(draft);
      if (errors.isNotEmpty) {
        return Result.failure('仍有欄位設定未完成，無法暫存');
      }

      final now = DateTime.now();
      final savedDraft = draft.copyWith(
        updatedAt: now.toIso8601String(),
      );
      return await _formDataBindingRepository.saveDraft(savedDraft);
    } catch (ex) {
      return Result.failure('暫存資料綁定設定失敗：${ex.toString()}');
    }
  }

  String buildExportPreviewJson(FormDataBindingDraft draft) {
    final payload = {
      'bindingId': draft.bindingId,
      'bindingName': draft.bindingName,
      'bindingDescription': draft.bindingDescription,
      'isEnabled': draft.isEnabled,
      'templateVersion': draft.templateVersion,
      'formId': draft.formId,
      'formName': draft.formName,
      'formSize': draft.formSize,
      'updatedAt': draft.updatedAt,
      'actions': draft.actions
          .map(
            (action) => {
              'actionId': action.actionId,
              'sourceItemId': action.sourceItemId,
              'sourceLabel': action.sourceLabel,
              'sourceType': action.sourceType,
              'triggerType': action.triggerType.name,
              'actionType': action.actionType.name,
              'enabled': action.enabled,
              'targetItemId': action.targetItemId,
              'targetLabel': action.targetLabel,
              'navigateRoute': action.navigateRoute,
              'description': action.description,
            },
          )
          .toList(),
      'sections': draft.sections
          .map(
            (section) => {
              'sectionId': section.sectionId,
              'sectionName': section.sectionName,
              'description': section.description,
              'fields': section.fields
                  .map(
                    (field) => {
                      'itemId': field.itemId,
                      'label': field.label,
                      'fieldName': field.fieldName,
                      'fieldKind': field.fieldKind.name,
                      'type': field.valueType.name,
                      'required': field.required,
                      'outputKey': field.outputKey,
                      'nullStrategy': field.nullStrategy.name,
                      'defaultValue':
                          field.nullStrategy == BindingNullStrategy.skip
                              ? field.systemDefaultValue
                              : field.customDefaultValue,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Map<String, String> validateDraft(FormDataBindingDraft draft) {
    final errors = <String, String>{};

    for (final section in draft.sections) {
      for (final field in section.fields) {
        final key = buildFieldKey(section.sectionId, field.itemId);

        if (field.fieldKind == BindingFieldKind.button) {
          continue;
        }

        if (field.outputKey.trim().isEmpty) {
          errors[key] = '套用結果不可為空';
          continue;
        }

        if (field.nullStrategy == BindingNullStrategy.custom) {
          final value = field.customDefaultValue.trim();
          if (value.isEmpty) {
            errors[key] = '請輸入預設值';
            continue;
          }

          final typeError = validateCustomDefault(field.valueType, value);
          if (typeError != null) {
            errors[key] = typeError;
          }
        }
      }
    }

    return errors;
  }

  String buildFieldKey(String sectionId, String itemId) {
    return '$sectionId::$itemId';
  }

  String? validateCustomDefault(BindingFieldValueType valueType, String value) {
    switch (valueType) {
      case BindingFieldValueType.number:
        return num.tryParse(value) == null ? '預設值必須為數字' : null;
      case BindingFieldValueType.date:
        return DateTime.tryParse(value) == null ? '預設值必須為日期格式' : null;
      case BindingFieldValueType.file:
        return null;
      case BindingFieldValueType.string:
        return null;
    }
  }

  Future<Result<List<SectionModel>>> _loadOrderedSections(
      FormModel form) async {
    final sectionsResult = await _sectionRepository.loadSections();
    if (!sectionsResult.isSuccess) {
      return Result.failure(sectionsResult.error ?? '讀取區塊失敗');
    }

    final sections = sectionsResult.data ?? const <SectionModel>[];
    final orderedSections = form.sectionIds
        .map(
          (sectionId) => sections.cast<SectionModel?>().firstWhere(
                (section) => section?.id == sectionId,
                orElse: () => null,
              ),
        )
        .whereType<SectionModel>()
        .toList();

    return Result.success(orderedSections);
  }

  FormDataBindingDraft _buildDraft({
    required FormModel form,
    required List<SectionModel> sections,
    required FormDataBindingDraft? savedDraft,
    required String bindingId,
    required int existingBindingCount,
  }) {
    final savedFields = <String, FormDataBindingFieldDraft>{};
    if (savedDraft != null) {
      for (final section in savedDraft.sections) {
        for (final field in section.fields) {
          savedFields[buildFieldKey(section.sectionId, field.itemId)] = field;
        }
      }
    }

    final bindingSections = sections.map((section) {
      final fields = section.items.where(_isBindableItem).map((item) {
        final storageKey = buildFieldKey(section.id, item.id);
        final savedField = savedFields[storageKey];
        final valueType = _resolveValueType(item);

        return FormDataBindingFieldDraft(
          itemId: item.id,
          label: _resolveLabel(item),
          fieldName: item.fieldName,
          sourceType: item.type.name,
          fieldKind: item.type == DesignerItemType.button
              ? BindingFieldKind.button
              : BindingFieldKind.value,
          valueType: valueType,
          required: item.required,
          outputKey: item.type == DesignerItemType.button
              ? '事件綁定'
              : savedField?.outputKey ?? _defaultOutputKey(item),
          nullStrategy: item.type == DesignerItemType.button
              ? BindingNullStrategy.skip
              : savedField?.nullStrategy ?? BindingNullStrategy.skip,
          customDefaultValue: item.type == DesignerItemType.button
              ? '事件綁定'
              : savedField?.customDefaultValue ?? '',
        );
      }).toList();

      return FormDataBindingSectionDraft(
        sectionId: section.id,
        sectionName: section.name,
        description: section.description,
        fields: fields,
      );
    }).toList();

    return FormDataBindingDraft(
      bindingId: savedDraft?.bindingId ?? bindingId,
      bindingName: savedDraft?.bindingName ??
          '${form.name} 綁定 ${existingBindingCount + 1}',
      bindingDescription:
          savedDraft?.bindingDescription ?? '依 ${form.name} 產生的資料綁定設定',
      isEnabled: savedDraft?.isEnabled ?? true,
      templateVersion: savedDraft?.templateVersion ?? 1,
      formId: form.id,
      formName: form.name,
      formSize: form.size,
      updatedAt: savedDraft?.updatedAt ?? '',
      sections: bindingSections,
      actions: savedDraft?.actions ?? const [],
    );
  }

  bool _isBindableItem(DesignerItem item) {
    switch (item.type) {
      case DesignerItemType.label:
        return false;
      case DesignerItemType.button:
      case DesignerItemType.checkbox:
      case DesignerItemType.datePicker:
      case DesignerItemType.dropdown:
      case DesignerItemType.fileUpload:
      case DesignerItemType.radio:
      case DesignerItemType.textArea:
      case DesignerItemType.textField:
        return true;
    }
  }

  BindingFieldValueType _resolveValueType(DesignerItem item) {
    if (item.type == DesignerItemType.datePicker) {
      return BindingFieldValueType.date;
    }

    if (item.type == DesignerItemType.fileUpload) {
      return BindingFieldValueType.file;
    }

    if (item.inputType == TextInputTypeMode.number) {
      return BindingFieldValueType.number;
    }

    return BindingFieldValueType.string;
  }

  String _resolveLabel(DesignerItem item) {
    if (item.text.trim().isNotEmpty) {
      return item.text.trim();
    }
    if (item.fieldName.trim().isNotEmpty) {
      return item.fieldName.trim();
    }
    return item.id;
  }

  String _defaultOutputKey(DesignerItem item) {
    final raw = item.fieldName.trim().isNotEmpty
        ? item.fieldName.trim()
        : item.text.trim().isNotEmpty
            ? item.text.trim()
            : item.id;

    return raw.replaceAll(' ', '_');
  }
}
