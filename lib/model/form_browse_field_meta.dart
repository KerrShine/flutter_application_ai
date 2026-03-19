import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/section_model.dart';

class FormBrowseFieldMeta {
  final SectionModel section;
  final DesignerItem item;

  const FormBrowseFieldMeta({
    required this.section,
    required this.item,
  });
}
