/// 條件欄位的輸出型別 — 跨 sign_off / form_condition_field 共用。
///
/// 決定 path rule operator dropdown 列出哪些選項、value input 用什麼鍵盤 / 元件。
/// 取代既有 `SignOffConditionFieldType`（語意不變、提升至共用 enum）。
enum ConditionFieldType {
  number,
  string,
  date,
}

extension ConditionFieldTypeX on ConditionFieldType {
  String get code {
    switch (this) {
      case ConditionFieldType.number:
        return 'number';
      case ConditionFieldType.string:
        return 'string';
      case ConditionFieldType.date:
        return 'date';
    }
  }

  String get label {
    switch (this) {
      case ConditionFieldType.number:
        return '數字';
      case ConditionFieldType.string:
        return '文字';
      case ConditionFieldType.date:
        return '日期';
    }
  }

  static ConditionFieldType fromCode(String? code) {
    switch (code) {
      case 'number':
        return ConditionFieldType.number;
      case 'date':
        return ConditionFieldType.date;
      case 'string':
      default:
        return ConditionFieldType.string;
    }
  }
}
