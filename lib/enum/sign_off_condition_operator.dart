import 'package:flutter_application_ai/enum/condition_field_type.dart';

/// 簽核流程條件 — 比較運算子。
enum SignOffConditionOperator {
  equal,
  notEqual,
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
  between,
  contains,
}

extension SignOffConditionOperatorX on SignOffConditionOperator {
  String get code {
    switch (this) {
      case SignOffConditionOperator.equal:
        return 'eq';
      case SignOffConditionOperator.notEqual:
        return 'ne';
      case SignOffConditionOperator.greaterThan:
        return 'gt';
      case SignOffConditionOperator.greaterThanOrEqual:
        return 'gte';
      case SignOffConditionOperator.lessThan:
        return 'lt';
      case SignOffConditionOperator.lessThanOrEqual:
        return 'lte';
      case SignOffConditionOperator.between:
        return 'between';
      case SignOffConditionOperator.contains:
        return 'contains';
    }
  }

  String get label {
    switch (this) {
      case SignOffConditionOperator.equal:
        return '等於';
      case SignOffConditionOperator.notEqual:
        return '不等於';
      case SignOffConditionOperator.greaterThan:
        return '大於';
      case SignOffConditionOperator.greaterThanOrEqual:
        return '大於等於';
      case SignOffConditionOperator.lessThan:
        return '小於';
      case SignOffConditionOperator.lessThanOrEqual:
        return '小於等於';
      case SignOffConditionOperator.between:
        return '介於';
      case SignOffConditionOperator.contains:
        return '包含';
    }
  }

  String get symbol {
    switch (this) {
      case SignOffConditionOperator.equal:
        return '==';
      case SignOffConditionOperator.notEqual:
        return '!=';
      case SignOffConditionOperator.greaterThan:
        return '>';
      case SignOffConditionOperator.greaterThanOrEqual:
        return '>=';
      case SignOffConditionOperator.lessThan:
        return '<';
      case SignOffConditionOperator.lessThanOrEqual:
        return '<=';
      case SignOffConditionOperator.between:
        return 'between';
      case SignOffConditionOperator.contains:
        return 'contains';
    }
  }

  /// 該 operator 是否需要第二個值（valueMax）— 僅 between
  bool get needsValueMax => this == SignOffConditionOperator.between;

  /// 該 operator 是否適用於指定 fieldType
  bool isApplicableTo(ConditionFieldType fieldType) {
    switch (fieldType) {
      case ConditionFieldType.number:
        return this != SignOffConditionOperator.contains;
      case ConditionFieldType.date:
        return this != SignOffConditionOperator.contains;
      case ConditionFieldType.string:
        return this == SignOffConditionOperator.equal ||
            this == SignOffConditionOperator.notEqual ||
            this == SignOffConditionOperator.contains;
    }
  }

  /// 取得指定 fieldType 適用的所有 operator
  static List<SignOffConditionOperator> applicableFor(
      ConditionFieldType fieldType) {
    return SignOffConditionOperator.values
        .where((op) => op.isApplicableTo(fieldType))
        .toList();
  }

  static SignOffConditionOperator fromCode(String? code) {
    switch (code) {
      case 'ne':
        return SignOffConditionOperator.notEqual;
      case 'gt':
        return SignOffConditionOperator.greaterThan;
      case 'gte':
        return SignOffConditionOperator.greaterThanOrEqual;
      case 'lt':
        return SignOffConditionOperator.lessThan;
      case 'lte':
        return SignOffConditionOperator.lessThanOrEqual;
      case 'between':
        return SignOffConditionOperator.between;
      case 'contains':
        return SignOffConditionOperator.contains;
      case 'eq':
      default:
        return SignOffConditionOperator.equal;
    }
  }
}
