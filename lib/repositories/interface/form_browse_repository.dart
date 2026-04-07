import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class FormBrowseRepository {
  Future<Result<List<SectionModel>>> loadSections(String formId);
}
