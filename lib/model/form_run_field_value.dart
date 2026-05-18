import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';

class FormRunFieldValue extends Equatable {
  final String itemId;
  final String outputKey;
  final String value;
  final BindingFieldValueType valueType;
  final BindingNullStrategy nullStrategy;
  final String customDefaultValue;

  /// nullStrategy = injected 時的資料源 key（對應 InjectedDataSource.code）；
  /// runtime 解析任務會依此 key 從系統 context 取值。
  final String providedDataKey;

  const FormRunFieldValue({
    this.itemId = '',
    this.outputKey = '',
    this.value = '',
    this.valueType = BindingFieldValueType.string,
    this.nullStrategy = BindingNullStrategy.skip,
    this.customDefaultValue = '',
    this.providedDataKey = '',
  });

  FormRunFieldValue copyWith({
    String? itemId,
    String? outputKey,
    String? value,
    BindingFieldValueType? valueType,
    BindingNullStrategy? nullStrategy,
    String? customDefaultValue,
    String? providedDataKey,
  }) {
    return FormRunFieldValue(
      itemId: itemId ?? this.itemId,
      outputKey: outputKey ?? this.outputKey,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
      nullStrategy: nullStrategy ?? this.nullStrategy,
      customDefaultValue: customDefaultValue ?? this.customDefaultValue,
      providedDataKey: providedDataKey ?? this.providedDataKey,
    );
  }

  String get effectiveValue {
    if (value.isNotEmpty) return value;
    if (nullStrategy == BindingNullStrategy.custom) return customDefaultValue;
    // TODO: nullStrategy == injected → 依 providedDataKey 從系統 context（登入者 / 日期）取值
    //   v1 暫返空字串；待 runtime 解析任務實作。
    return '';
  }

  @override
  List<Object> get props => [
        itemId,
        outputKey,
        value,
        valueType,
        nullStrategy,
        customDefaultValue,
        providedDataKey,
      ];
}
