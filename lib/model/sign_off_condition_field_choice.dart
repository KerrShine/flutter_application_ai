import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';

/// 「設定 Path Rule 條件用的欄位選項」中介模型。
///
/// 抽象掉資料來源細節（form_data_binding draft 是 source of truth），
/// UI 只認這個結構。**outputKey 是 runtime 提交資料的真實 key** —
/// `SignOffPathCondition.fieldId` 必須儲存此值以便執行階段條件能命中。
class SignOffConditionFieldChoice extends Equatable {
  /// runtime 提交時的 key（form_data_binding 設定）。
  /// 條件比對時 `formData[outputKey]` → 取值。
  final String outputKey;

  /// 顯示用 label（form_data_binding 已選好的 fieldName/text/id 三選一）。
  final String label;

  /// 原始 DesignerItem.fieldName（debug 與 fallback 用）。
  final String fieldName;

  /// 條件比對型別 — 由 `BindingFieldValueType` 映射而來。
  final ConditionFieldType fieldType;

  const SignOffConditionFieldChoice({
    required this.outputKey,
    required this.label,
    this.fieldName = '',
    required this.fieldType,
  });

  @override
  List<Object?> get props => [outputKey, label, fieldName, fieldType];
}
