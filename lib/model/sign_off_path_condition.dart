import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/enum/sign_off_condition_operator.dart';

/// Path Rule 的條件表達式 — field + operator + value(s)。
///
/// fieldId 引用 form 內的 DesignerItem.id。
/// fieldName 是 snapshot（表單欄位重新命名後仍可顯示舊名稱於模板上）。
/// fieldType 決定 operator dropdown 與 value 輸入元件。
/// value 為字串編碼，依 fieldType 解析（number → 數值；date → ISO 字串）。
/// valueMax 僅 between operator 使用。
class SignOffPathCondition extends Equatable {
  final String fieldId;
  final String fieldName;
  final ConditionFieldType fieldType;
  final SignOffConditionOperator operator;
  final String value;
  final String valueMax;

  const SignOffPathCondition({
    this.fieldId = '',
    this.fieldName = '',
    this.fieldType = ConditionFieldType.string,
    this.operator = SignOffConditionOperator.equal,
    this.value = '',
    this.valueMax = '',
  });

  SignOffPathCondition copyWith({
    String? fieldId,
    String? fieldName,
    ConditionFieldType? fieldType,
    SignOffConditionOperator? operator,
    String? value,
    String? valueMax,
  }) {
    return SignOffPathCondition(
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      valueMax: valueMax ?? this.valueMax,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fieldId': fieldId,
      'fieldName': fieldName,
      'fieldType': fieldType.code,
      'operator': operator.code,
      'value': value,
      'valueMax': valueMax,
    };
  }

  factory SignOffPathCondition.fromMap(Map<String, dynamic> map) {
    return SignOffPathCondition(
      fieldId: map['fieldId']?.toString() ?? '',
      fieldName: map['fieldName']?.toString() ?? '',
      fieldType:
          ConditionFieldTypeX.fromCode(map['fieldType']?.toString()),
      operator: SignOffConditionOperatorX.fromCode(map['operator']?.toString()),
      value: map['value']?.toString() ?? '',
      valueMax: map['valueMax']?.toString() ?? '',
    );
  }

  /// 顯示用條件摘要（如「請假天數 >= 7」「介於 5 ~ 30」）。
  String get summary {
    final field = fieldName.isEmpty ? fieldId : fieldName;
    if (operator == SignOffConditionOperator.between) {
      return '$field 介於 $value ~ $valueMax';
    }
    return '$field ${operator.symbol} $value';
  }

  @override
  List<Object> get props => [
        fieldId,
        fieldName,
        fieldType,
        operator,
        value,
        valueMax,
      ];
}
