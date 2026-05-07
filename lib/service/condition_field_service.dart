import 'package:flutter_application_ai/enum/condition_compute_function.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';
import 'package:flutter_application_ai/model/condition_field_draft.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/condition_field_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/repositories/interface/section_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

/// 條件欄位 service — 設計階段 CRUD + Phase B 用的 evaluate。
///
/// loadDraft 一個 form 至多一筆 draft（formId 為唯一）。Sign_off 透過
/// `loadDraft(formId).definitions` 拿到條件欄位列表，當作 path rule 比對候選。
class ConditionFieldService {
  final ConditionFieldRepository _repository;
  final FormRepository _formRepository;
  final SectionRepository _sectionRepository;

  ConditionFieldService(
    this._repository,
    this._formRepository,
    this._sectionRepository,
  );

  /// 取出 form 對應的 draft（若不存在回 null，並非錯誤）。
  Future<Result<ConditionFieldDraft?>> loadDraft(String formId) async {
    if (formId.isEmpty) return Result.success(null);
    return _repository.loadDraft(formId);
  }

  /// 批次載入指定 formIds 的 draft（用於 sign_off chip 狀態 / 列表頁）。
  Future<Result<Map<String, ConditionFieldDraft?>>> loadDraftsByFormIds(
      List<String> formIds) async {
    final result = <String, ConditionFieldDraft?>{};
    for (final formId in formIds) {
      if (formId.isEmpty) continue;
      try {
        final r = await _repository.loadDraft(formId);
        result[formId] = r.isSuccess ? r.data : null;
      } catch (_) {
        result[formId] = null;
      }
    }
    return Result.success(result);
  }

  Future<Result<bool>> saveDraft(ConditionFieldDraft draft) async {
    final stamped = draft.copyWith(updatedAt: DateTime.now().toIso8601String());
    return _repository.saveDraft(stamped);
  }

  Future<Result<bool>> deleteDraft(String formId) =>
      _repository.deleteDraft(formId);

  /// 載入 form 內可作為 condition arg 的 DesignerItem 列表（依 function spec 過濾）。
  ///
  /// editor dialog 用此輸出建立 arg picker 候選；type-mismatch 的 item 會被移除。
  Future<Result<List<ConditionArgItemChoice>>> loadFormItems(
      String formId) async {
    if (formId.isEmpty) return Result.success(const []);
    final formResult = await _formRepository.loadFormById(formId);
    if (!formResult.isSuccess) {
      return Result.failure(formResult.error ?? '讀取表單失敗');
    }
    final form = formResult.data;
    if (form == null) return Result.success(const []);

    final sectionsResult = await _sectionRepository.loadSections();
    if (!sectionsResult.isSuccess) {
      return Result.failure(sectionsResult.error ?? '讀取區塊失敗');
    }
    final sections = sectionsResult.data ?? const <SectionModel>[];
    final orderedSections = form.sectionIds
        .map((id) => sections.cast<SectionModel?>().firstWhere(
              (s) => s?.id == id,
              orElse: () => null,
            ))
        .whereType<SectionModel>()
        .toList();

    final choices = <ConditionArgItemChoice>[];
    for (final section in orderedSections) {
      for (final item in section.items) {
        if (!_isSelectableForCondition(item)) continue;
        choices.add(ConditionArgItemChoice(
          itemId: item.id,
          label: _resolveLabel(item),
          designerType: item.type,
          inferredFieldType: _inferFieldType(item),
          sectionName: section.name,
        ));
      }
    }
    return Result.success(choices);
  }

  /// 驗證 definition：fieldKey 唯一、args 數量 + 型別符合 function spec。
  ///
  /// `existing` 列表用於檢查 fieldKey 重複（不含正在編輯的自己 — 由 caller 過濾）。
  String? validateDefinition(
    ConditionFieldDefinition def,
    List<ConditionFieldDefinition> existing,
    List<ConditionArgItemChoice> availableItems,
  ) {
    if (def.fieldKey.trim().isEmpty) return 'fieldKey 不可為空';
    if (def.label.trim().isEmpty) return '顯示名稱不可為空';
    if (existing.any((d) => d.fieldKey == def.fieldKey)) {
      return 'fieldKey「${def.fieldKey}」已存在';
    }

    final spec = def.function.argSpec;
    if (def.argDesignerItemIds.length < spec.minArgs) {
      return '${def.function.label} 至少需要 ${spec.minArgs} 個參數';
    }
    if (def.argDesignerItemIds.length > spec.maxArgs) {
      return '${def.function.label} 至多 ${spec.maxArgs} 個參數';
    }

    for (final argId in def.argDesignerItemIds) {
      final item = availableItems.cast<ConditionArgItemChoice?>().firstWhere(
            (c) => c?.itemId == argId,
            orElse: () => null,
          );
      if (item == null) return '參數欄位 $argId 不存在於此表單';
      if (!spec.allowedArgTypes.contains(item.designerType)) {
        return '${def.function.label} 不接受「${item.designerType.name}」型別欄位';
      }
    }

    final expectedOutput = resolveOutputType(def, availableItems);
    if (expectedOutput != def.outputType) {
      return '輸出型別應為 ${expectedOutput.label}';
    }

    return null;
  }

  /// 依 function 與 args 推斷 outputType。
  ///
  /// `direct`：跟著 arg item 的 inferredFieldType；否則用 spec.fixedOutputType。
  static ConditionFieldType resolveOutputType(
    ConditionFieldDefinition def,
    List<ConditionArgItemChoice> availableItems,
  ) {
    final spec = def.function.argSpec;
    if (spec.fixedOutputType != null) return spec.fixedOutputType!;

    if (def.function == ConditionComputeFunction.direct &&
        def.argDesignerItemIds.isNotEmpty) {
      final first = availableItems.cast<ConditionArgItemChoice?>().firstWhere(
            (c) => c?.itemId == def.argDesignerItemIds.first,
            orElse: () => null,
          );
      if (first != null) return first.inferredFieldType;
    }
    return ConditionFieldType.string;
  }

  /// Phase B 用：依 form rawData (Map<DesignerItem.id, value>) 計算
  /// 所有 fieldKey 的衍生值，回傳 Map<fieldKey, computedValue>。
  ///
  /// v1 設計階段不接此 API；保留以便日後 sign_off resolveActivatedNodeIds
  /// 直接吃 fieldKey-keyed map。
  Future<Result<Map<String, String>>> evaluate(
    String formId,
    Map<String, String> rawFormData,
  ) async {
    final draftResult = await loadDraft(formId);
    if (!draftResult.isSuccess) {
      return Result.failure(draftResult.error ?? '');
    }
    final draft = draftResult.data;
    if (draft == null) return Result.success(const {});

    final out = <String, String>{};
    for (final def in draft.definitions) {
      out[def.fieldKey] = _computeValue(def, rawFormData);
    }
    return Result.success(out);
  }

  String _computeValue(
    ConditionFieldDefinition def,
    Map<String, String> rawFormData,
  ) {
    final args =
        def.argDesignerItemIds.map((id) => rawFormData[id] ?? '').toList();

    switch (def.function) {
      case ConditionComputeFunction.direct:
        return args.isEmpty ? '' : args.first;
      case ConditionComputeFunction.dateDiff:
        if (args.length < 2) return '';
        final start = DateTime.tryParse(args[0]);
        final end = DateTime.tryParse(args[1]);
        if (start == null || end == null) return '';
        return end.difference(start).inDays.toString();
      case ConditionComputeFunction.sum:
        var total = 0.0;
        for (final a in args) {
          final n = double.tryParse(a.trim());
          if (n == null) return '';
          total += n;
        }
        // 整數結果不顯示小數
        if (total == total.truncateToDouble()) {
          return total.toInt().toString();
        }
        return total.toString();
      case ConditionComputeFunction.concat:
        return args.join();
    }
  }

  // ---------- DesignerItem helpers ----------

  bool _isSelectableForCondition(DesignerItem item) {
    switch (item.type) {
      case DesignerItemType.label:
      case DesignerItemType.button:
      case DesignerItemType.fileUpload:
        return false;
      case DesignerItemType.textField:
      case DesignerItemType.textArea:
      case DesignerItemType.dropdown:
      case DesignerItemType.radio:
      case DesignerItemType.checkbox:
      case DesignerItemType.datePicker:
        return true;
    }
  }

  ConditionFieldType _inferFieldType(DesignerItem item) {
    if (item.type == DesignerItemType.datePicker) {
      return ConditionFieldType.date;
    }
    if (item.inputType == TextInputTypeMode.number) {
      return ConditionFieldType.number;
    }
    return ConditionFieldType.string;
  }

  String _resolveLabel(DesignerItem item) {
    if (item.text.trim().isNotEmpty) return item.text.trim();
    if (item.fieldName.trim().isNotEmpty) return item.fieldName.trim();
    return item.id;
  }
}

/// editor dialog arg picker 用的 DesignerItem 候選。
class ConditionArgItemChoice {
  final String itemId;
  final String label;
  final DesignerItemType designerType;
  final ConditionFieldType inferredFieldType;
  final String sectionName;

  const ConditionArgItemChoice({
    required this.itemId,
    required this.label,
    required this.designerType,
    required this.inferredFieldType,
    required this.sectionName,
  });
}
