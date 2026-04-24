import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/data/remote/dio_client.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/model/form_run_field_value.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/api_catalog_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_browse_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_data_binding_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormRunInitialData extends Equatable {
  final List<SectionModel> sections;
  final FormDataBindingDraft draft;
  final Map<String, ApiDefinition> apiMap;
  final Map<String, FormRunFieldValue> fieldValues;

  const FormRunInitialData({
    required this.sections,
    required this.draft,
    required this.apiMap,
    required this.fieldValues,
  });

  @override
  List<Object> get props => [sections, draft, apiMap, fieldValues];
}

class FormRunService {
  final FormBrowseRepository _formBrowseRepository;
  final FormDataBindingRepository _formDataBindingRepository;
  final ApiCatalogRepository _apiCatalogRepository;
  final LocalStorage _localStorage;
  // ignore: unused_field
  final DioClient _dioClient;

  static const String _draftKeyPrefix = 'form_run_draft_';
  static const String _dropdownSampleAsset =
      'lib/data/tempData/dropdown_options_sample.json';

  FormRunService(
    this._formBrowseRepository,
    this._formDataBindingRepository,
    this._apiCatalogRepository,
    this._localStorage,
    this._dioClient,
  );

  Future<Result<FormRunInitialData>> initialize(
    String formId,
    String bindingId,
  ) async {
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
      final fieldValues = _buildInitialFieldValues(draft);
      final savedValues = _loadSavedDraft(formId, bindingId);
      if (savedValues.isNotEmpty) {
        for (final entry in savedValues.entries) {
          if (fieldValues.containsKey(entry.key)) {
            fieldValues[entry.key] =
                fieldValues[entry.key]!.copyWith(value: entry.value);
          }
        }
      }

      return Result.success(FormRunInitialData(
        sections: sections,
        draft: draft,
        apiMap: apiMap,
        fieldValues: fieldValues,
      ));
    } catch (ex) {
      return Result.failure('初始化表單執行失敗：${ex.toString()}');
    }
  }

  Map<String, FormRunFieldValue> _buildInitialFieldValues(
    FormDataBindingDraft draft,
  ) {
    final map = <String, FormRunFieldValue>{};
    for (final section in draft.sections) {
      for (final field in section.fields) {
        if (field.fieldKind == BindingFieldKind.button) continue;
        map[field.itemId] = FormRunFieldValue(
          itemId: field.itemId,
          outputKey: field.outputKey,
          valueType: field.valueType,
          nullStrategy: field.nullStrategy,
          customDefaultValue: field.customDefaultValue,
          value: field.nullStrategy == BindingNullStrategy.custom
              ? field.customDefaultValue
              : '',
        );
      }
    }
    return map;
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
      if (effective.isEmpty &&
          fv.nullStrategy == BindingNullStrategy.skip) {
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
