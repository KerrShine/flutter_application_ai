import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/enum/designer_item_type.dart';

/// form_condition_field 支援的計算函式。
///
/// v1 限制：4 種 flat 函式，不支援巢狀 / Excel-like 自由公式。
/// 每種函式的 arg 數量 / 允許 DesignerItemType / 輸出 type 由 extension 定義，
/// editor dialog 依此動態決定 picker 行為。
enum ConditionComputeFunction {
  /// 直接取單一 DesignerItem 的值（不計算）。輸出 type 跟著 arg type 變動。
  direct,

  /// 兩個 datePicker 相減，輸出天數（number）。
  dateDiff,

  /// 多個 number 欄位加總，輸出 number。
  sum,

  /// 多個 string 欄位拼接，輸出 string。
  concat,
}

class ConditionComputeArgSpec {
  final int minArgs;
  final int maxArgs;
  final Set<DesignerItemType> allowedArgTypes;
  final ConditionFieldType? fixedOutputType;

  const ConditionComputeArgSpec({
    required this.minArgs,
    required this.maxArgs,
    required this.allowedArgTypes,
    this.fixedOutputType,
  });
}

extension ConditionComputeFunctionX on ConditionComputeFunction {
  String get code {
    switch (this) {
      case ConditionComputeFunction.direct:
        return 'direct';
      case ConditionComputeFunction.dateDiff:
        return 'dateDiff';
      case ConditionComputeFunction.sum:
        return 'sum';
      case ConditionComputeFunction.concat:
        return 'concat';
    }
  }

  String get label {
    switch (this) {
      case ConditionComputeFunction.direct:
        return '直接欄位';
      case ConditionComputeFunction.dateDiff:
        return '日期天數差';
      case ConditionComputeFunction.sum:
        return '加總';
      case ConditionComputeFunction.concat:
        return '字串拼接';
    }
  }

  String get description {
    switch (this) {
      case ConditionComputeFunction.direct:
        return '把表單欄位直接轉接為條件欄位（不計算）';
      case ConditionComputeFunction.dateDiff:
        return '結束日 - 開始日，輸出天數';
      case ConditionComputeFunction.sum:
        return '多個數值欄位加總';
      case ConditionComputeFunction.concat:
        return '多個文字欄位拼接';
    }
  }

  ConditionComputeArgSpec get argSpec {
    switch (this) {
      case ConditionComputeFunction.direct:
        return const ConditionComputeArgSpec(
          minArgs: 1,
          maxArgs: 1,
          allowedArgTypes: {
            DesignerItemType.textField,
            DesignerItemType.textArea,
            DesignerItemType.dropdown,
            DesignerItemType.radio,
            DesignerItemType.checkbox,
            DesignerItemType.datePicker,
          },
          // direct 的輸出 type 跟 arg item 一樣 — 由 service 層動態決定
        );
      case ConditionComputeFunction.dateDiff:
        return const ConditionComputeArgSpec(
          minArgs: 2,
          maxArgs: 2,
          allowedArgTypes: {DesignerItemType.datePicker},
          fixedOutputType: ConditionFieldType.number,
        );
      case ConditionComputeFunction.sum:
        return const ConditionComputeArgSpec(
          minArgs: 2,
          maxArgs: 99,
          allowedArgTypes: {
            DesignerItemType.textField,
          },
          fixedOutputType: ConditionFieldType.number,
        );
      case ConditionComputeFunction.concat:
        return const ConditionComputeArgSpec(
          minArgs: 2,
          maxArgs: 99,
          allowedArgTypes: {
            DesignerItemType.textField,
            DesignerItemType.textArea,
            DesignerItemType.dropdown,
            DesignerItemType.radio,
          },
          fixedOutputType: ConditionFieldType.string,
        );
    }
  }

  static ConditionComputeFunction fromCode(String? code) {
    switch (code) {
      case 'dateDiff':
        return ConditionComputeFunction.dateDiff;
      case 'sum':
        return ConditionComputeFunction.sum;
      case 'concat':
        return ConditionComputeFunction.concat;
      case 'direct':
      default:
        return ConditionComputeFunction.direct;
    }
  }
}
