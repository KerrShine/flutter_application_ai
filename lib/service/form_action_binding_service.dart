import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/designer_item_type.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/repositories/interface/api_catalog_repository.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormActionBindingService {
  final FormDataBindingService _formDataBindingService;
  final ApiCatalogRepository _apiCatalogRepository;

  FormActionBindingService(
    this._formDataBindingService,
    this._apiCatalogRepository,
  );

  Future<Result<FormActionBindingInitialData>> initialize(
    String formId, {
    String bindingId = '',
  }) async {
    try {
      if (formId.isEmpty) {
        return Result.failure('找不到要設定動作綁定的表單');
      }

      final result = await _formDataBindingService.initialize(
        formId,
        bindingId: bindingId,
      );
      if (!result.isSuccess) {
        return Result.failure(result.error ?? '讀取動作綁定資料失敗');
      }

      final draft = result.data;
      if (draft == null) {
        return Result.failure('找不到要設定動作綁定的綁定資料');
      }

      final actionSources = _buildActionSources(draft);
      final previewJson = buildActionPlanPreviewJson(draft, actionSources);

      final apiResult = await _apiCatalogRepository.loadApiList();
      final apiList = apiResult.isSuccess ? (apiResult.data ?? []) : <ApiDefinition>[];

      final dropdownApiResult = await _apiCatalogRepository.loadDropdownApiList();
      final dropdownApiList = dropdownApiResult.isSuccess
          ? (dropdownApiResult.data ?? [])
          : <ApiDefinition>[];

      return Result.success(
        FormActionBindingInitialData(
          draft: draft,
          actionSources: actionSources,
          previewJson: previewJson,
          apiList: apiList,
          dropdownApiList: dropdownApiList,
        ),
      );
    } catch (ex) {
      return Result.failure('讀取動作綁定資料失敗：${ex.toString()}');
    }
  }

  String buildActionPlanPreviewJson(
    FormDataBindingDraft draft,
    List<FormActionSourceItem> actionSources,
  ) {
    return buildActionPlanPreviewJsonFromState(
      bindingId: draft.bindingId,
      bindingName: draft.bindingName,
      formId: draft.formId,
      formName: draft.formName,
      actions: draft.actions,
      actionSources: actionSources,
    );
  }

  Future<Result<FormDataBindingDraft>> saveActionSettings({
    required FormDataBindingDraft draft,
    required List<FormActionBindingDraft> actions,
  }) async {
    try {
      final updatedDraft = draft.copyWith(
        actions: actions,
        updatedAt: DateTime.now().toIso8601String(),
      );
      final result = await _formDataBindingService.saveDraft(updatedDraft);
      if (!result.isSuccess) {
        return Result.failure(result.error ?? '儲存動作設定失敗');
      }

      return Result.success(updatedDraft);
    } catch (ex) {
      return Result.failure('儲存動作設定失敗：${ex.toString()}');
    }
  }

  String buildActionPlanPreviewJsonFromState({
    required String bindingId,
    required String bindingName,
    required String formId,
    required String formName,
    required List<FormActionBindingDraft> actions,
    required List<FormActionSourceItem> actionSources,
  }) {
    // 依 sourceItemId + triggerType 分組，群組內依 order 排序
    final actionGroups = <String, List<FormActionBindingDraft>>{};
    for (final a in actions) {
      final key = '${a.sourceItemId}__${a.triggerType.name}';
      actionGroups.putIfAbsent(key, () => []).add(a);
    }
    final actionBindings = actionGroups.values.map((group) {
      group.sort((a, b) => a.order.compareTo(b.order));
      final first = group.first;
      return {
        'sourceItemId': first.sourceItemId,
        'sourceLabel': first.sourceLabel,
        'sourceType': first.sourceType,
        'triggerType': first.triggerType.name,
        'steps': group
            .map((action) => {
                  'sequence': action.order + 1,
                  'actionId': action.actionId,
                  'actionType': action.actionType.name,
                  'apiId': action.apiId,
                  'targetItemId': action.targetItemId,
                  'targetLabel': action.targetLabel,
                  'navigateRoute': action.navigateRoute,
                  'enabled': action.enabled,
                  'description': action.description,
                })
            .toList(),
      };
    }).toList();

    final payload = {
      'bindingId': bindingId,
      'bindingName': bindingName,
      'formId': formId,
      'formName': formName,
      'exportMode': 'settings_only',
      'actionBindings': actionBindings,
      'actionSources': actionSources
          .map(
            (item) => {
              'sectionId': item.sectionId,
              'sectionName': item.sectionName,
              'itemId': item.itemId,
              'label': item.label,
              'sourceType': item.sourceType,
              'availableTriggers': item.availableTriggers,
              'suggestedActions': item.suggestedActions,
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  List<FormActionSourceItem> _buildActionSources(FormDataBindingDraft draft) {
    final sources = <FormActionSourceItem>[];

    for (final section in draft.sections) {
      for (final field in section.fields) {
        final sourceType = field.sourceType.trim();
        final isButton = field.fieldKind == BindingFieldKind.button;
        final isDropdown = sourceType == DesignerItemType.dropdown.name;

        if (!isButton && !isDropdown) {
          continue;
        }

        sources.add(
          FormActionSourceItem(
            sectionId: section.sectionId,
            sectionName: section.sectionName,
            itemId: field.itemId,
            label: field.label,
            sourceType: isButton ? 'button' : 'dropdown',
            availableTriggers: isButton
                ? const ['buttonPressed']
                : const ['dropdownLoaded', 'dropdownChanged'],
            suggestedActions: isButton
                ? const [
                    'navigate',
                    'saveDraft',
                    'submitForm',
                    'callApi',
                    'other'
                  ]
                : const [
                    'loadDropdownOptions',
                    'refreshTarget',
                    'setFieldValue',
                    'other',
                  ],
          ),
        );
      }
    }

    return sources;
  }
}

class FormActionBindingInitialData {
  final FormDataBindingDraft draft;
  final List<FormActionSourceItem> actionSources;
  final String previewJson;
  final List<ApiDefinition> apiList;
  final List<ApiDefinition> dropdownApiList;

  const FormActionBindingInitialData({
    required this.draft,
    required this.actionSources,
    required this.previewJson,
    this.apiList = const [],
    this.dropdownApiList = const [],
  });
}

class FormActionSourceItem extends Equatable {
  final String sectionId;
  final String sectionName;
  final String itemId;
  final String label;
  final String sourceType;
  final List<String> availableTriggers;
  final List<String> suggestedActions;

  const FormActionSourceItem({
    required this.sectionId,
    required this.sectionName,
    required this.itemId,
    required this.label,
    required this.sourceType,
    required this.availableTriggers,
    required this.suggestedActions,
  });

  @override
  List<Object> get props => [
        sectionId,
        sectionName,
        itemId,
        label,
        sourceType,
        availableTriggers,
        suggestedActions,
      ];
}

String formActionDisplayName(String action) {
  switch (action) {
    case 'navigate':
      return '頁面跳轉';
    case 'saveDraft':
      return '暫存草稿';
    case 'submitForm':
      return '送出表單';
    case 'callApi':
      return '呼叫API';
    case 'loadDropdownOptions':
      return '載入選項';
    case 'refreshTarget':
      return '更新目標欄位';
    case 'setFieldValue':
      return '帶入欄位值';
    case 'other':
      return '其他';
    default:
      return action;
  }
}

String formActionTriggerDisplayName(String trigger) {
  switch (trigger) {
    case 'buttonPressed':
      return '點擊事件';
    case 'dropdownChanged':
      return '選項變更事件';
    case 'dropdownLoaded':
      return '載入完成事件';
    default:
      return trigger;
  }
}
