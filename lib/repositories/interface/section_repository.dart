import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class SectionRepository {
  Future<Result<bool>> saveSection(SectionModel section);
  Future<Result<List<SectionModel>>> loadSections();
  Future<Result<SectionModel?>> loadSectionById(String sectionId);
  Future<Result<bool>> deleteSection(String sectionId);
}
