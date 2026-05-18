import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/data/remote/dio_client.dart';
import 'package:flutter_application_ai/enum/injected_data_source.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/model/form_run_field_value.dart';
import 'package:flutter_application_ai/model/sign_off_instance.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/api_catalog_repository.dart';
import 'package:flutter_application_ai/service/form_application_service.dart'
    show applyLeadingNotifySkip;
import 'package:flutter_application_ai/repositories/interface/form_browse_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_data_binding_repository.dart';
import 'package:flutter_application_ai/repositories/interface/sign_off_repository.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormRunInitialData extends Equatable {
  final List<SectionModel> sections;
  final FormDataBindingDraft draft;
  final Map<String, ApiDefinition> apiMap;
  final Map<String, FormRunFieldValue> fieldValues;
  final List<ConditionFieldDefinition> conditionDefinitions;

  const FormRunInitialData({
    required this.sections,
    required this.draft,
    required this.apiMap,
    required this.fieldValues,
    this.conditionDefinitions = const [],
  });

  @override
  List<Object> get props =>
      [sections, draft, apiMap, fieldValues, conditionDefinitions];
}

class FormRunService {
  final FormBrowseRepository _formBrowseRepository;
  final FormDataBindingRepository _formDataBindingRepository;
  final ApiCatalogRepository _apiCatalogRepository;
  final ConditionFieldService _conditionFieldService;
  final SignOffRepository _signOffRepository;
  final SignOffService _signOffService;
  final LocalStorage _localStorage;
  // ignore: unused_field
  final DioClient _dioClient;

  static const String _draftKeyPrefix = 'form_run_draft_';
  static const String _dropdownSampleAsset =
      'lib/data/tempData/dropdown_options_sample.json';
  // 與 FormApplicationService 共用的「測試寫入」LocalStorage key（form_button_action_api_sample.json 內 path 一致）。
  static const String _signOffStorageKey = 'form_run_test_write_log';

  FormRunService(
    this._formBrowseRepository,
    this._formDataBindingRepository,
    this._apiCatalogRepository,
    this._conditionFieldService,
    this._signOffRepository,
    this._signOffService,
    this._localStorage,
    this._dioClient,
  );

  ConditionFieldService get conditionFieldService => _conditionFieldService;

  Future<Result<FormRunInitialData>> initialize(
    String formId,
    String bindingId, {
    String signOffId = '',
    // 給「預設_指定」(BindingNullStrategy.injected) 解析動態資料用
    String currentEmployeeId = '',
    String currentEmployeeName = '',
    String currentEmployeeCode = '',
    String currentDepartmentName = '',
    String currentRoleName = '',
  }) async {
    try {
      final sectionsResult = await _formBrowseRepository.loadSections(formId);
      if (!sectionsResult.isSuccess) {
        return Result.failure(sectionsResult.error ?? '載入表單區塊失敗');
      }

      final draftsResult =
          await _formDataBindingRepository.loadDraftsByFormId(formId);
      if (!draftsResult.isSuccess) {
        return Result.failure(draftsResult.error ?? '載入綁定設定失敗');
      }

      final drafts = draftsResult.data ?? [];
      FormDataBindingDraft draft;
      if (bindingId.isNotEmpty) {
        final found = drafts.cast<FormDataBindingDraft?>().firstWhere(
              (d) => d?.bindingId == bindingId,
              orElse: () => null,
            );
        draft = found ?? (drafts.isNotEmpty ? drafts.first : const FormDataBindingDraft());
      } else {
        draft = drafts.isNotEmpty ? drafts.first : const FormDataBindingDraft();
      }

      final apiResult = await _apiCatalogRepository.loadApiList();
      final dropdownApiResult =
          await _apiCatalogRepository.loadDropdownApiList();
      final apiMap = <String, ApiDefinition>{};
      if (apiResult.isSuccess) {
        for (final api in apiResult.data ?? []) {
          apiMap[api.apiId] = api;
        }
      }
      if (dropdownApiResult.isSuccess) {
        for (final api in dropdownApiResult.data ?? []) {
          apiMap[api.apiId] = api;
        }
      }

      final sections = sectionsResult.data ?? [];
      final fieldValues = _buildInitialFieldValues(
        draft,
        currentEmployeeId: currentEmployeeId,
        currentEmployeeName: currentEmployeeName,
        currentEmployeeCode: currentEmployeeCode,
        currentDepartmentName: currentDepartmentName,
        currentRoleName: currentRoleName,
      );
      final savedValues = _loadSavedDraft(formId, bindingId);
      if (savedValues.isNotEmpty) {
        for (final entry in savedValues.entries) {
          if (fieldValues.containsKey(entry.key)) {
            fieldValues[entry.key] =
                fieldValues[entry.key]!.copyWith(value: entry.value);
          }
        }
      }

      // 編輯模式：載入既有 signOff 並用其 fieldValues 覆寫預設 / 草稿值。
      // 規則：
      // - 只有 pending 可編輯，其他 status 立即 failure
      // - 用最新 form 設計（上面 sections 已是當前最新），itemId 在新 sections
      //   不存在的 signOff 值會自然丟棄；新 sections 多出的欄位用預設值
      if (signOffId.isNotEmpty) {
        final signOffResult = _loadSignOffById(signOffId);
        if (!signOffResult.isSuccess || signOffResult.data == null) {
          return Result.failure(signOffResult.error ?? '找不到此申請');
        }
        final signOff = signOffResult.data!;
        if (!signOff.isEditableByApplicant) {
          return Result.failure('此申請已被簽核者處理，無法編輯');
        }
        signOff.fieldValues.forEach((itemId, value) {
          if (fieldValues.containsKey(itemId)) {
            fieldValues[itemId] = fieldValues[itemId]!
                .copyWith(value: value?.toString() ?? '');
          }
        });
      }

      final conditionDraftResult =
          await _conditionFieldService.loadDraft(formId);
      final conditionDefinitions =
          (conditionDraftResult.isSuccess && conditionDraftResult.data != null)
              ? conditionDraftResult.data!.definitions
              : const <ConditionFieldDefinition>[];

      return Result.success(FormRunInitialData(
        sections: sections,
        draft: draft,
        apiMap: apiMap,
        fieldValues: fieldValues,
        conditionDefinitions: conditionDefinitions,
      ));
    } catch (ex) {
      return Result.failure('初始化表單執行失敗：${ex.toString()}');
    }
  }

  Map<String, FormRunFieldValue> _buildInitialFieldValues(
    FormDataBindingDraft draft, {
    String currentEmployeeId = '',
    String currentEmployeeName = '',
    String currentEmployeeCode = '',
    String currentDepartmentName = '',
    String currentRoleName = '',
  }) {
    final map = <String, FormRunFieldValue>{};
    for (final section in draft.sections) {
      for (final field in section.fields) {
        if (field.fieldKind == BindingFieldKind.button) continue;
        String initialValue;
        if (field.nullStrategy == BindingNullStrategy.custom) {
          initialValue = field.customDefaultValue;
        } else if (field.nullStrategy == BindingNullStrategy.injected) {
          initialValue = _resolveInjectedValue(
            field.providedDataKey,
            currentEmployeeId: currentEmployeeId,
            currentEmployeeName: currentEmployeeName,
            currentEmployeeCode: currentEmployeeCode,
            currentDepartmentName: currentDepartmentName,
            currentRoleName: currentRoleName,
          );
        } else {
          initialValue = '';
        }
        map[field.itemId] = FormRunFieldValue(
          itemId: field.itemId,
          outputKey: field.outputKey,
          valueType: field.valueType,
          nullStrategy: field.nullStrategy,
          customDefaultValue: field.customDefaultValue,
          providedDataKey: field.providedDataKey,
          value: initialValue,
        );
      }
    }
    return map;
  }

  /// 將 BindingNullStrategy.injected 的 providedDataKey 解析為實際字串值。
  /// 對應 [InjectedDataSource] 6 種候選；未知 key 回空字串。
  String _resolveInjectedValue(
    String providedDataKey, {
    required String currentEmployeeId,
    required String currentEmployeeName,
    required String currentEmployeeCode,
    required String currentDepartmentName,
    required String currentRoleName,
  }) {
    final source = InjectedDataSourceX.fromCode(providedDataKey);
    if (source == null) return '';
    switch (source) {
      case InjectedDataSource.currentEmployeeId:
        return currentEmployeeId;
      case InjectedDataSource.currentEmployeeName:
        return currentEmployeeName;
      case InjectedDataSource.currentEmployeeCode:
        return currentEmployeeCode;
      case InjectedDataSource.currentDepartmentName:
        return currentDepartmentName;
      case InjectedDataSource.currentRoleName:
        return currentRoleName;
      case InjectedDataSource.todayDate:
        final now = DateTime.now();
        final m = now.month.toString().padLeft(2, '0');
        final d = now.day.toString().padLeft(2, '0');
        return '${now.year}-$m-$d';
    }
  }

  Map<String, String> _loadSavedDraft(String formId, String bindingId) {
    try {
      final key = '$_draftKeyPrefix${formId}_$bindingId';
      final raw = _localStorage.getString(key);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Map<String, dynamic> buildApiParams(
    Map<String, FormRunFieldValue> fieldValues,
  ) {
    final params = <String, dynamic>{};
    for (final fv in fieldValues.values) {
      final effective = fv.effectiveValue;
      // skip 與 injected 在 effective 為空時都先略過（injected 等 runtime 解析任務實作）
      if (effective.isEmpty &&
          (fv.nullStrategy == BindingNullStrategy.skip ||
              fv.nullStrategy == BindingNullStrategy.injected)) {
        continue;
      }
      if (fv.outputKey.isNotEmpty) {
        params[fv.outputKey] = effective;
      }
    }
    return params;
  }

  Future<Result<List<String>>> executeLoadDropdownOptions(
    FormActionBindingDraft action,
    Map<String, ApiDefinition> apiMap,
  ) async {
    try {
      final api = apiMap[action.apiId];
      if (api == null) {
        return Result.failure('找不到 API 定義：${action.apiId}');
      }

      // 從 assets 讀取 dropdown_options_sample.json（後續替換為 call api）
      final raw = await rootBundle.loadString(_dropdownSampleAsset);
      if (raw.isEmpty) {
        return Result.failure('找不到下拉選項範例資料（$_dropdownSampleAsset）');
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final sources = (json['sources'] as List<dynamic>? ?? []);

      // 找出 apiId 對應的 source
      final source = sources.cast<Map<String, dynamic>?>().firstWhere(
            (s) => s?['apiId'] == action.apiId,
            orElse: () => null,
          );

      if (source == null) {
        return Result.failure('找不到 apiId「${action.apiId}」的下拉選項資料');
      }

      // 優先使用 action 設定的 parameterName，fallback 到 JSON 內的 dataSourceKey
      final key = action.parameterName.isNotEmpty
          ? action.parameterName.trim()
          : (source['dataSourceKey'] as String? ?? '').trim();
      final response = source['response'];
      List<dynamic> rawList;

      if (key.isNotEmpty && response is Map<String, dynamic>) {
        rawList = response[key] as List<dynamic>? ?? [];
      } else if (response is List<dynamic>) {
        rawList = response;
      } else {
        rawList = [];
      }

      // 支援字串陣列與 {value, label} 物件陣列
      final options = rawList.map((item) {
        if (item is String) return item;
        if (item is Map<String, dynamic>) {
          return (item['label'] ?? item['value'] ?? '').toString();
        }
        return item.toString();
      }).where((s) => s.isNotEmpty).toList();

      return Result.success(options);
    } catch (ex) {
      return Result.failure('載入下拉選項失敗：${ex.toString()}');
    }
  }

  Future<Result<Map<String, dynamic>>> executeCallApi(
    FormActionBindingDraft action,
    Map<String, ApiDefinition> apiMap,
    Map<String, dynamic> params,
  ) async {
    try {
      final api = apiMap[action.apiId];
      if (api == null) {
        return Result.failure('找不到 API 定義：${action.apiId}');
      }

      // 目前使用 mock 模式；切換為真實 API 時改為下方呼叫：
      // final response = await _dioClient.postWithTimeout(
      //   api.path, data: params, timeoutMs: api.timeoutMs,
      // );
      // return Result.success(response.data as Map<String, dynamic>);
      await Future.delayed(const Duration(milliseconds: 800));
      return Result.success({'status': 'mock_success', 'apiId': api.apiId});
    } catch (ex) {
      return Result.failure('呼叫 API 失敗：${ex.toString()}');
    }
  }

  /// 測試寫入特例（apiId == `test_write_to_storage_api`）。
  ///
  /// 把當前表單資料組成一筆 [SignOffInstance]，序列化後 append 至
  /// `api.path` 指定的 LocalStorage key（預設 `form_run_test_write_log`）。
  /// 用於 v1 簽核流程引擎完工前，開發/驗證階段模擬「送出簽核」並檢視資料形狀。
  ///
  /// applicantId / applicantName / departmentId 由呼叫端（FormRunBloc）從
  /// CurrentEmployeeBloc 帶入，確保「我的申請」過濾時能正確匹配當前登入者。
  Future<Result<Map<String, dynamic>>> executeTestWriteSignOff({
    required ApiDefinition api,
    required String formId,
    required String formName,
    required String bindingId,
    required String applicantId,
    required String applicantName,
    required String departmentId,
    required List<SectionModel> sections,
    required Map<String, FormRunFieldValue> fieldValues,
    required Map<String, String> computedValues,
  }) async {
    try {
      // 萃取 itemId → value（與 fieldValues 結構一致）
      final fieldData = <String, dynamic>{};
      fieldValues.forEach((itemId, fv) {
        fieldData[itemId] = fv.value;
      });

      // 序列化當下 sections 結構為快照 — 詳情頁可依此渲染原貌，
      // 即使表單設計後續被改動。
      final sectionsSnapshot =
          sections.map((s) => s.toMap()).toList();

      // 查找該 formId 的 active 簽核流程模板，把 templateId 寫入 model；
      // 找不到（表單尚未設模板）也不阻擋送出，templateId 保持空字串。
      final templateId = await _resolveActiveTemplateId(formId);

      // 送出當下 snapshot 簽核鏈 — 含 allowAgentFallback / agentEmployeeId 等
      // runtime 權限判定所需資訊。後續模板被改動不影響此筆流程。
      final chainSnapshot = await _buildResolvedChainSnapshot(
        templateId: templateId,
        applicantEmployeeId: applicantId,
        applicantFormData: computedValues,
      );

      // 從 snapshot 抽第一關簽核者 — 讓「我的申請」列表立即顯示誰在簽，
      // 而非等到第一次推進才填入。
      final (firstApproverId, firstApproverName) =
          _firstApproverFromSnapshot(chainSnapshot);

      final now = DateTime.now().toUtc().toIso8601String();
      final signOffId = 'test_signoff_${DateTime.now().microsecondsSinceEpoch}';
      final initialModel = SignOffInstance(
        signOffId: signOffId,
        submissionId: '${signOffId}_sub',
        templateId: templateId,
        formId: formId,
        formName: formName,
        applicantId: applicantId,
        applicantName: applicantName,
        departmentId: departmentId,
        fieldValues: fieldData,
        computedFields: computedValues,
        sectionsSnapshot: sectionsSnapshot,
        resolvedChainSnapshot: chainSnapshot,
        currentApproverId: firstApproverId,
        currentApproverName: firstApproverName,
        status: LeaveSignOffStatus.pending,
        submittedAt: now,
        updatedAt: now,
      );

      // A2：若首節點是 notify，立刻跳過至第一個非 notify 節點再寫入
      final model = applyLeadingNotifySkip(initialModel);

      final key = api.path.isEmpty ? 'form_run_test_write_log' : api.path;
      final existingRaw = _localStorage.getString(key);
      final List<dynamic> list = (existingRaw == null || existingRaw.isEmpty)
          ? <dynamic>[]
          : (jsonDecode(existingRaw) as List<dynamic>);
      list.add(model.toMap());
      await _localStorage.setString(key, jsonEncode(list));

      return Result.success({
        'status': 'test_write_success',
        'apiId': api.apiId,
        'storageKey': key,
        'signOffId': signOffId,
        'totalRecords': list.length,
      });
    } catch (ex) {
      return Result.failure('測試寫入失敗：${ex.toString()}');
    }
  }

  /// 編輯模式專用：以 signOffId 為 key 替換 LocalStorage 中對應 SignOffInstance。
  ///
  /// 規則：
  /// - 保留：signOffId / submissionId / formId / formName / applicantId /
  ///         applicantName / departmentId / status / actionHistory / submittedAt
  /// - 更新：fieldValues / computedFields / sectionsSnapshot / updatedAt
  Future<Result<Map<String, dynamic>>> executeUpdateSignOff({
    required ApiDefinition api,
    required String signOffId,
    required List<SectionModel> sections,
    required Map<String, FormRunFieldValue> fieldValues,
    required Map<String, String> computedValues,
  }) async {
    try {
      final key = api.path.isEmpty ? _signOffStorageKey : api.path;
      final raw = _localStorage.getString(key);
      if (raw == null || raw.isEmpty) {
        return Result.failure('找不到該筆申請（storage 為空）');
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return Result.failure('儲存格式錯誤');
      }
      final list = List<dynamic>.from(decoded);

      // 找出對應 signOffId 的 index
      var targetIndex = -1;
      SignOffInstance? existing;
      for (var i = 0; i < list.length; i++) {
        final item = list[i];
        if (item is Map) {
          final model = SignOffInstance.fromMap(
            Map<String, dynamic>.from(item),
          );
          if (model.signOffId == signOffId) {
            targetIndex = i;
            existing = model;
            break;
          }
        }
      }
      if (targetIndex < 0 || existing == null) {
        return Result.failure('找不到 signOffId「$signOffId」對應的申請');
      }

      // 組裝更新後的 model — 大部分欄位沿用既有
      final fieldData = <String, dynamic>{};
      fieldValues.forEach((itemId, fv) {
        fieldData[itemId] = fv.value;
      });

      // 重送情境 — 兩種：
      // 1. 退回後重送（returnBack）→ 流程重跑：stepIndex=0、re-resolve 鏈
      // 2. 補件後重送（requestSupplement）→ 流程暫停接續：stepIndex/currentApprover 不變
      final now = DateTime.now().toUtc().toIso8601String();
      final lastActionType = existing.actionHistory.isEmpty
          ? null
          : existing.actionHistory.last.actionType;
      final isResubmitAfterReturn =
          lastActionType == SignOffActionType.returnBack;
      final isResubmitAfterSupplement =
          lastActionType == SignOffActionType.requestSupplement;

      final List<SignOffActionRecord> newHistory =
          List<SignOffActionRecord>.from(existing.actionHistory);
      int newStepIndex = existing.currentStepIndex;
      List<Map<String, dynamic>> newChainSnapshot =
          existing.resolvedChainSnapshot;
      String newCurrentApproverId = existing.currentApproverId;
      String newCurrentApproverName = existing.currentApproverName;

      if (isResubmitAfterReturn) {
        newHistory.add(SignOffActionRecord(
          recordId: 'act_${DateTime.now().microsecondsSinceEpoch}',
          actionType: SignOffActionType.approve,
          approverId: existing.applicantId,
          approverName: existing.applicantName,
          comment: '申請人重新送出',
          actionAt: now,
        ));
        newStepIndex = 0;
        // 退回後重送 — re-resolve 鏈，申請人代理可能於送出後改變
        newChainSnapshot = await _buildResolvedChainSnapshot(
          templateId: existing.templateId,
          applicantEmployeeId: existing.applicantId,
          applicantFormData: computedValues,
        );
        // 重送後 currentApprover 重設為第一關
        final (id, name) = _firstApproverFromSnapshot(newChainSnapshot);
        newCurrentApproverId = id;
        newCurrentApproverName = name;
      } else if (isResubmitAfterSupplement) {
        // 補件後重送 — 流程暫停接續，stepIndex / currentApprover / snapshot 都不變
        // 僅追加軌跡告知簽核者「申請人已補件」
        newHistory.add(SignOffActionRecord(
          recordId: 'act_${DateTime.now().microsecondsSinceEpoch}',
          actionType: SignOffActionType.approve,
          approverId: existing.applicantId,
          approverName: existing.applicantName,
          comment: '申請人已補件',
          actionAt: now,
        ));
      }

      final preSkipModel = existing.copyWith(
        fieldValues: fieldData,
        computedFields: computedValues,
        sectionsSnapshot: sections.map((s) => s.toMap()).toList(),
        resolvedChainSnapshot: newChainSnapshot,
        actionHistory: newHistory,
        currentStepIndex: newStepIndex,
        currentApproverId: newCurrentApproverId,
        currentApproverName: newCurrentApproverName,
        updatedAt: now,
      );
      // A2：退回後重送（重設 step 0）— 首節點可能是 notify，立刻 skip
      final updatedModel = isResubmitAfterReturn
          ? applyLeadingNotifySkip(preSkipModel)
          : preSkipModel;
      list[targetIndex] = updatedModel.toMap();
      await _localStorage.setString(key, jsonEncode(list));

      return Result.success({
        'status': 'update_success',
        'apiId': api.apiId,
        'storageKey': key,
        'signOffId': signOffId,
        'totalRecords': list.length,
      });
    } catch (ex) {
      return Result.failure('編輯送出失敗：${ex.toString()}');
    }
  }

  /// 從 chain snapshot 取「第一個非申請起點」的 approver，回傳 (id, name)。
  /// 找不到時回 ('', '')。給送出/重送時寫入 currentApproverId/Name 用。
  (String, String) _firstApproverFromSnapshot(
      List<Map<String, dynamic>> chainSnapshot) {
    for (final entry in chainSnapshot) {
      if (entry['description'] == '申請起點') continue;
      final ids = entry['approverEmployeeIds'];
      final firstId = (ids is List && ids.isNotEmpty) ? ids.first.toString() : '';
      final name = entry['approverName']?.toString() ?? '';
      return (firstId, name);
    }
    return ('', '');
  }

  /// 給定 templateId + 申請人，解析簽核鏈並回傳 snapshot（List<Map>）。
  /// 找不到 template 或解析失敗時回 const []，由呼叫端決定容錯。
  Future<List<Map<String, dynamic>>> _buildResolvedChainSnapshot({
    required String templateId,
    required String applicantEmployeeId,
    Map<String, String>? applicantFormData,
  }) async {
    if (templateId.isEmpty || applicantEmployeeId.isEmpty) return const [];
    try {
      final loadResult = await _signOffRepository.loadById(templateId);
      if (!loadResult.isSuccess) return const [];
      final template = loadResult.data;
      if (template == null) return const [];
      final chainResult = await _signOffService.resolveApproverChain(
        template: template,
        applicantEmployeeId: applicantEmployeeId,
        applicantFormData: applicantFormData,
      );
      if (!chainResult.isSuccess) return const [];
      final chain = chainResult.data ?? const <ResolvedApprover>[];
      return chain.map((r) => r.toMap()).toList();
    } catch (_) {
      return const [];
    }
  }

  /// 查找該 formId 的 active 簽核流程模板，回傳 templateId；找不到回空字串。
  /// 多筆 active 時取第一筆（v1 假設一個表單僅有一個 active template）。
  Future<String> _resolveActiveTemplateId(String formId) async {
    if (formId.isEmpty) return '';
    try {
      final result = await _signOffRepository.loadByFormId(formId);
      if (!result.isSuccess) return '';
      final templates = result.data ?? const [];
      final active = templates
          .where((t) => t.status == 'active')
          .cast<dynamic>()
          .firstWhere((_) => true, orElse: () => null);
      if (active != null) return (active as dynamic).templateId as String;
      // 沒 active 時 fallback 取第一筆 draft（避免測試環境永遠拿不到）
      return templates.isNotEmpty ? templates.first.templateId : '';
    } catch (_) {
      return '';
    }
  }

  /// 從 LocalStorage 撈單筆 SignOffInstance — 供 initialize 編輯模式使用。
  Result<SignOffInstance> _loadSignOffById(String signOffId) {
    try {
      final raw = _localStorage.getString(_signOffStorageKey);
      if (raw == null || raw.isEmpty) {
        return Result.failure('找不到此申請（storage 為空）');
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return Result.failure('儲存格式錯誤');
      }
      for (final item in decoded) {
        if (item is Map) {
          final model = SignOffInstance.fromMap(
            Map<String, dynamic>.from(item),
          );
          if (model.signOffId == signOffId) {
            return Result.success(model);
          }
        }
      }
      return Result.failure('找不到 signOffId「$signOffId」對應的申請');
    } catch (ex) {
      return Result.failure('讀取申請失敗：${ex.toString()}');
    }
  }

  Future<Result<bool>> executeSaveDraft(
    String formId,
    String bindingId,
    Map<String, FormRunFieldValue> fieldValues,
  ) async {
    try {
      final key = '$_draftKeyPrefix${formId}_$bindingId';
      final data = fieldValues.map((k, v) => MapEntry(k, v.value));
      await _localStorage.setString(key, jsonEncode(data));
      return Result.success(true);
    } catch (ex) {
      return Result.failure('儲存草稿失敗：${ex.toString()}');
    }
  }
}
