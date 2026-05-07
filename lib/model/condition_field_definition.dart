import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/condition_compute_function.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';

/// 單一條件欄位定義 — 描述「拿什麼欄位、用什麼函式、輸出什麼型別」。
///
/// `fieldKey` 是條件比對的 stable key，sign_off path rule `condition.fieldId`
/// 直接引用此值。`argDesignerItemIds` 引用 form 內 DesignerItem.id（v1 只支援
/// 同 form 內欄位，不跨 form 引用）。
class ConditionFieldDefinition extends Equatable {
  final String fieldKey;
  final String label;
  final ConditionFieldType outputType;
  final ConditionComputeFunction function;
  final List<String> argDesignerItemIds;

  const ConditionFieldDefinition({
    required this.fieldKey,
    required this.label,
    required this.outputType,
    required this.function,
    required this.argDesignerItemIds,
  });

  ConditionFieldDefinition copyWith({
    String? fieldKey,
    String? label,
    ConditionFieldType? outputType,
    ConditionComputeFunction? function,
    List<String>? argDesignerItemIds,
  }) {
    return ConditionFieldDefinition(
      fieldKey: fieldKey ?? this.fieldKey,
      label: label ?? this.label,
      outputType: outputType ?? this.outputType,
      function: function ?? this.function,
      argDesignerItemIds: argDesignerItemIds ?? this.argDesignerItemIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fieldKey': fieldKey,
      'label': label,
      'outputType': outputType.code,
      'function': function.code,
      'argDesignerItemIds': argDesignerItemIds,
    };
  }

  factory ConditionFieldDefinition.fromMap(Map<String, dynamic> map) {
    final rawArgs = map['argDesignerItemIds'] as List<dynamic>? ?? const [];
    return ConditionFieldDefinition(
      fieldKey: map['fieldKey']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      outputType: ConditionFieldTypeX.fromCode(map['outputType']?.toString()),
      function:
          ConditionComputeFunctionX.fromCode(map['function']?.toString()),
      argDesignerItemIds:
          rawArgs.map((item) => item.toString()).toList(growable: false),
    );
  }

  @override
  List<Object> get props =>
      [fieldKey, label, outputType, function, argDesignerItemIds];
}
