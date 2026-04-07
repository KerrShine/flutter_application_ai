import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/section_model.dart';

class FormSectionDesignDraftModel extends Equatable {
  final String sectionId;
  final String formName;
  final String description;
  final int rowCount;
  final List<DesignerItem> items;

  const FormSectionDesignDraftModel({
    this.sectionId = '',
    this.formName = '',
    this.description = '',
    this.rowCount = 1,
    this.items = const [],
  });

  factory FormSectionDesignDraftModel.fromMap(Map<String, dynamic> map) {
    final normalizedMap = {
      'id': map['sectionId'] ?? '',
      'name': map['formName'] ?? '',
      'description': map['description'] ?? '',
      'items': map['items'] ?? const [],
    };
    final section = SectionModel.fromMap(normalizedMap);

    return FormSectionDesignDraftModel(
      sectionId: map['sectionId']?.toString() ?? '',
      formName: map['formName']?.toString() ?? '',
      description: section.description,
      rowCount: (map['rowCount'] as num?)?.toInt() ?? 1,
      items: section.items,
    );
  }

  @override
  List<Object> get props => [sectionId, formName, description, rowCount, items];
}
