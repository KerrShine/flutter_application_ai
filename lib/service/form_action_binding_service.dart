import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/designer_item_type.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/repositories/interface/api_catalog_repository.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

/// 表單動作綁定的「設定階段」服務。
///
/// 負責：把 form 內的 button / dropdown 欄位視為「事件源」，
/// 讓使用者在動作綁定設定頁把它們綁到 API 呼叫、頁面跳轉、暫存、
/// 載入下拉選項等動作上，並提供預覽 JSON 與儲存能力。
///
/// 對應的「執行階段」在 `FormRunService` — 真正按鈕點下後依此設定執行。
class FormActionBindingService {
  final FormDataBindingService _formDataBindingService;
  final ApiCatalogRepository _apiCatalogRepository;

  FormActionBindingService(
    this._formDataBindingService,
    this._apiCatalogRepository,
  );

  /// 載入指定表單動作綁定設定頁所需的完整初始資料。
  ///
  /// 內容包含：綁定 draft、可作為事件源的欄位清單（按鈕 / 下拉）、
  /// 預覽 JSON、可用 API 清單、下拉專用 API 清單。供
  /// `FormActionBindingPage` / 對應 Bloc init 時呼叫一次。
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

  /// 由 draft 物件組「動作藍圖 JSON」字串（設定面板右側預覽用）。
  ///
  /// 是 [buildActionPlanPreviewJsonFromState] 的便利 wrapper —
  /// 呼叫端持有完整 draft 時使用此版本。
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

  /// 把編輯後的 actions 寫回 draft 並持久化（LocalStorage）。
  ///
  /// 內部會更新 `draft.updatedAt`，再交給
  /// [FormDataBindingService.saveDraft] 完成實際儲存。
  /// 回傳更新後的 draft，供呼叫端 emit 進 state。
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

  /// 從散參數組「動作藍圖 JSON」字串（給 Bloc state 即時組裝預覽用）。
  ///
  /// 與 [buildActionPlanPreviewJson] 等效，但不要求呼叫端持有完整 draft；
  /// 適合編輯中、actions 尚未寫回 draft 時即時更新預覽。
  ///
  /// 內部會以 `sourceItemId + triggerType` 分組，群組內依 `order` 排序，
  /// 輸出階層化的 JSON（actionBindings + actionSources）。
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

  /// 從 draft 過濾出可作為「事件源」的欄位（button / dropdown）。
  ///
  /// 為每個事件源產生 `availableTriggers`（可訂閱的事件類型）與
  /// `suggestedActions`（建議搭配的動作類型）— 讓設定 UI 直接列選項。
  /// 其他類型的欄位（textField / radio / ...）不會被視為事件源。
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

/// [FormActionBindingService.initialize] 的一次性回傳資料包。
///
/// 設定頁初始化時把所有需要的東西打包：draft、事件源清單、預覽 JSON、
/// 兩份 API 清單（一般 callApi 用 / loadDropdownOptions 專用）。
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

/// 單一「事件源」描述：哪個 section 內哪個 button / dropdown 欄位、
/// 可訂閱哪些事件、適合搭配哪些動作類型。
///
/// 由 [FormActionBindingService._buildActionSources] 產生，
/// 供設定頁列出「可綁的欄位」與動作下拉預設選項。
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

/// 動作類型代碼 → 中文顯示名稱。
///
/// 未列舉者直接回傳原代碼，方便未來新增 action 類型時 graceful fallback。
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

/// 觸發事件代碼 → 中文顯示名稱。
///
/// 同 [formActionDisplayName] 模式，未列舉者回傳原代碼。
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
