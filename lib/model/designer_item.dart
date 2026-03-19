import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/designer_item_alignment.dart';
import 'package:flutter_application_ai/enum/designer_item_option_layout.dart';
import 'package:flutter_application_ai/enum/designer_item_type.dart';
import 'package:flutter_application_ai/enum/button_width_mode.dart';
import 'package:flutter_application_ai/enum/text_input_type.dart';

export 'package:flutter_application_ai/enum/designer_item_alignment.dart';
export 'package:flutter_application_ai/enum/designer_item_option_layout.dart';
export 'package:flutter_application_ai/enum/designer_item_type.dart';
export 'package:flutter_application_ai/enum/button_width_mode.dart';
export 'package:flutter_application_ai/enum/text_input_type.dart';

class DesignerItem extends Equatable {
  final String id;
  final DesignerItemType type;
  final String text;
  final bool isBold;
  final String fieldName;
  final String placeholder;
  final int maxLength;
  final double widthPercentage;
  final int rowIndex;
  final DesignerItemAlignment alignment;
  final double padding;
  final ButtonWidthMode buttonWidthMode;
  final double buttonWidth;
  final double textAreaHeight;
  final bool isGrouped;
  final List<String> options;
  final DesignerItemOptionLayout optionLayout;
  final double optionSpacing;
  final String dateFormat;
  final double fontSize;
  final String allowedTypes;
  final int maxSize;
  final bool required;
  final bool readonly;
  final TextInputTypeMode inputType;
  final String dataSourceUrl;
  final String dataSourceKey;

  const DesignerItem({
    required this.id,
    required this.type,
    required this.text,
    this.isBold = false,
    this.fieldName = '',
    this.placeholder = '',
    this.maxLength = 0,
    this.widthPercentage = 1.0,
    this.rowIndex = 0,
    this.alignment = DesignerItemAlignment.centerLeft,
    this.padding = 8.0,
    this.buttonWidthMode = ButtonWidthMode.fill,
    this.buttonWidth = 160.0,
    this.textAreaHeight = 120.0,
    this.isGrouped = false,
    this.options = const ['Option 1', 'Option 2'],
    this.optionLayout = DesignerItemOptionLayout.vertical,
    this.optionSpacing = 8.0,
    this.dateFormat = 'yyyy-MM-dd',
    this.fontSize = 14.0,
    this.allowedTypes = '',
    this.maxSize = 0,
    this.required = false,
    this.readonly = false,
    this.inputType = TextInputTypeMode.text,
    this.dataSourceUrl = '',
    this.dataSourceKey = '',
  });

  DesignerItem copyWith({
    String? id,
    DesignerItemType? type,
    String? text,
    bool? isBold,
    String? fieldName,
    String? placeholder,
    int? maxLength,
    double? widthPercentage,
    int? rowIndex,
    DesignerItemAlignment? alignment,
    double? padding,
    ButtonWidthMode? buttonWidthMode,
    double? buttonWidth,
    double? textAreaHeight,
    bool? isGrouped,
    List<String>? options,
    DesignerItemOptionLayout? optionLayout,
    double? optionSpacing,
    String? dateFormat,
    double? fontSize,
    String? allowedTypes,
    int? maxSize,
    bool? required,
    bool? readonly,
    TextInputTypeMode? inputType,
    String? dataSourceUrl,
    String? dataSourceKey,
  }) {
    return DesignerItem(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      isBold: isBold ?? this.isBold,
      fieldName: fieldName ?? this.fieldName,
      placeholder: placeholder ?? this.placeholder,
      maxLength: maxLength ?? this.maxLength,
      widthPercentage: widthPercentage ?? this.widthPercentage,
      rowIndex: rowIndex ?? this.rowIndex,
      alignment: alignment ?? this.alignment,
      padding: padding ?? this.padding,
      buttonWidthMode: buttonWidthMode ?? this.buttonWidthMode,
      buttonWidth: buttonWidth ?? this.buttonWidth,
      textAreaHeight: textAreaHeight ?? this.textAreaHeight,
      isGrouped: isGrouped ?? this.isGrouped,
      options: options ?? this.options,
      optionLayout: optionLayout ?? this.optionLayout,
      optionSpacing: optionSpacing ?? this.optionSpacing,
      dateFormat: dateFormat ?? this.dateFormat,
      fontSize: fontSize ?? this.fontSize,
      allowedTypes: allowedTypes ?? this.allowedTypes,
      maxSize: maxSize ?? this.maxSize,
      required: required ?? this.required,
      readonly: readonly ?? this.readonly,
      inputType: inputType ?? this.inputType,
      dataSourceUrl: dataSourceUrl ?? this.dataSourceUrl,
      dataSourceKey: dataSourceKey ?? this.dataSourceKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'text': text,
      'isBold': isBold,
      'fieldName': fieldName,
      'placeholder': placeholder,
      'maxLength': maxLength,
      'widthPercentage': widthPercentage,
      'rowIndex': rowIndex,
      'alignment': alignment.name,
      'padding': padding,
      'buttonWidthMode': buttonWidthMode.name,
      'buttonWidth': buttonWidth,
      'textAreaHeight': textAreaHeight,
      'isGrouped': isGrouped,
      'options': options,
      'optionLayout': optionLayout.name,
      'optionSpacing': optionSpacing,
      'dateFormat': dateFormat,
      'fontSize': fontSize,
      'allowedTypes': allowedTypes,
      'maxSize': maxSize,
      'required': required,
      'readonly': readonly,
      'inputType': inputType.name,
      'dataSourceUrl': dataSourceUrl,
      'dataSourceKey': dataSourceKey,
    };
  }

  @override
  List<Object> get props => [
        id,
        type,
        text,
        isBold,
        fieldName,
        placeholder,
        maxLength,
        widthPercentage,
        rowIndex,
        alignment,
        padding,
        buttonWidthMode,
        buttonWidth,
        textAreaHeight,
        isGrouped,
        options,
        optionLayout,
        optionSpacing,
        dateFormat,
        fontSize,
        allowedTypes,
        maxSize,
        required,
        readonly,
        inputType,
        dataSourceUrl,
        dataSourceKey,
      ];
}
