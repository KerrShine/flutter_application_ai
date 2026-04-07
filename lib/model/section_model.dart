import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/designer_item.dart';

class SectionModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<DesignerItem> items;

  const SectionModel({
    required this.id,
    required this.name,
    this.description = '',
    this.items = const [],
  });

  SectionModel copyWith({
    String? id,
    String? name,
    String? description,
    List<DesignerItem>? items,
  }) {
    return SectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory SectionModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return SectionModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      items: rawItems.map((e) {
        final m = e as Map<String, dynamic>;
        final rawOptions = m['options'] as List<dynamic>? ?? const [];
        return DesignerItem(
          id: m['id'] ?? '',
          type: DesignerItemType.values.firstWhere(
            (t) => t.name == m['type'],
            orElse: () => DesignerItemType.label,
          ),
          text: m['text'] ?? '',
          isBold: m['isBold'] as bool? ?? false,
          fieldName: m['fieldName'] ?? '',
          placeholder: m['placeholder'] ?? '',
          maxLength: (m['maxLength'] as int?) ?? 0,
          widthPercentage: (m['widthPercentage'] as num?)?.toDouble() ?? 1.0,
          rowIndex: (m['rowIndex'] as int?) ?? 0,
          alignment: DesignerItemAlignment.values.firstWhere(
            (item) => item.name == m['alignment'],
            orElse: () => DesignerItemAlignment.centerLeft,
          ),
          padding: (m['padding'] as num?)?.toDouble() ?? 8.0,
          buttonWidthMode: ButtonWidthMode.values.firstWhere(
            (item) => item.name == m['buttonWidthMode'],
            orElse: () => ButtonWidthMode.fill,
          ),
          buttonWidth: (m['buttonWidth'] as num?)?.toDouble() ?? 160.0,
          textAreaHeight: (m['textAreaHeight'] as num?)?.toDouble() ?? 120.0,
          isGrouped: m['isGrouped'] as bool? ?? false,
          options: rawOptions.map((item) => item.toString()).toList(),
          optionLayout: DesignerItemOptionLayout.values.firstWhere(
            (item) => item.name == m['optionLayout'],
            orElse: () => DesignerItemOptionLayout.vertical,
          ),
          optionSpacing: (m['optionSpacing'] as num?)?.toDouble() ?? 8.0,
          fontSize: (m['fontSize'] as num?)?.toDouble() ?? 14.0,
          dateFormat: m['dateFormat'] ?? 'yyyy-MM-dd',
          allowedTypes: m['allowedTypes'] ?? '',
          maxSize: (m['maxSize'] as int?) ?? 0,
          required: m['required'] as bool? ?? false,
          readonly: m['readonly'] as bool? ?? false,
          inputType: TextInputTypeMode.values.firstWhere(
            (mode) => mode.name == m['inputType'],
            orElse: () => TextInputTypeMode.text,
          ),
          dataSourceUrl: m['dataSourceUrl'] ?? '',
          dataSourceKey: m['dataSourceKey'] ?? '',
          buttonColorHex: m['buttonColorHex'] ?? '',
          buttonTextColorHex: m['buttonTextColorHex'] ?? '',
        );
      }).toList(),
    );
  }

  @override
  List<Object> get props => [id, name, description, items];
}
