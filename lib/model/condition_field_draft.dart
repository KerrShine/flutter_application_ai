import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';

/// 一份 form 的條件欄位定義集 — per-form 唯一 (formId 為 unique key)。
class ConditionFieldDraft extends Equatable {
  final String formId;
  final String formName;
  final List<ConditionFieldDefinition> definitions;
  final String updatedAt;

  const ConditionFieldDraft({
    required this.formId,
    this.formName = '',
    this.definitions = const [],
    this.updatedAt = '',
  });

  ConditionFieldDraft copyWith({
    String? formId,
    String? formName,
    List<ConditionFieldDefinition>? definitions,
    String? updatedAt,
  }) {
    return ConditionFieldDraft(
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      definitions: definitions ?? this.definitions,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'formId': formId,
      'formName': formName,
      'definitions': definitions.map((d) => d.toMap()).toList(),
      'updatedAt': updatedAt,
    };
  }

  factory ConditionFieldDraft.fromMap(Map<String, dynamic> map) {
    final rawDefinitions = map['definitions'] as List<dynamic>? ?? const [];
    return ConditionFieldDraft(
      formId: map['formId']?.toString() ?? '',
      formName: map['formName']?.toString() ?? '',
      definitions: rawDefinitions
          .map((item) =>
              ConditionFieldDefinition.fromMap(item as Map<String, dynamic>))
          .toList(),
      updatedAt: map['updatedAt']?.toString() ?? '',
    );
  }

  @override
  List<Object> get props => [formId, formName, definitions, updatedAt];
}
