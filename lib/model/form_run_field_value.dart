import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';

class FormRunFieldValue extends Equatable {
  final String itemId;
  final String outputKey;
  final String value;
  final BindingFieldValueType valueType;
  final BindingNullStrategy nullStrategy;
  final String customDefaultValue;

  const FormRunFieldValue({
    this.itemId = '',
    this.outputKey = '',
    this.value = '',
    this.valueType = BindingFieldValueType.string,
    this.nullStrategy = BindingNullStrategy.skip,
    this.customDefaultValue = '',
  });

  FormRunFieldValue copyWith({
    String? itemId,
    String? outputKey,
    String? value,
    BindingFieldValueType? valueType,
    BindingNullStrategy? nullStrategy,
    String? customDefaultValue,
  }) {
    return FormRunFieldValue(
      itemId: itemId ?? this.itemId,
      outputKey: outputKey ?? this.outputKey,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
      nullStrategy: nullStrategy ?? this.nullStrategy,
      customDefaultValue: customDefaultValue ?? this.customDefaultValue,
    );
  }

  String get effectiveValue {
    if (value.isNotEmpty) return value;
    if (nullStrategy == BindingNullStrategy.custom) return customDefaultValue;
    return '';
  }

  @override
  List<Object> get props =>
      [itemId, outputKey, value, valueType, nullStrategy, customDefaultValue];
}
