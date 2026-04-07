import 'dart:convert';
import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/form_browse_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormBrowseRepositoryImpl implements FormBrowseRepository {
  final LocalStorage _localStorage;
  static const String _sectionsKey = 'sections_key';
  static const String _draftFormsKey = 'draft_forms_key';

  FormBrowseRepositoryImpl(this._localStorage);

  @override
  Future<Result<List<SectionModel>>> loadSections(String formId) async {
    try {
      if (formId.isEmpty) {
        return Result.failure('找不到表單');
      }

      final formsRaw = _localStorage.getString(_draftFormsKey);
      if (formsRaw == null || formsRaw.isEmpty) {
        return Result.failure('找不到表單');
      }

      final forms = (jsonDecode(formsRaw) as List)
          .map((item) => FormModel.fromMap(item as Map<String, dynamic>))
          .toList();
      final form = forms.cast<FormModel?>().firstWhere(
            (item) => item?.id == formId,
            orElse: () => null,
          );

      if (form == null) {
        return Result.failure('找不到表單');
      }

      final sectionsRaw = _localStorage.getString(_sectionsKey);
      if (sectionsRaw == null || sectionsRaw.isEmpty) {
        return Result.success([]);
      }

      final sections = (jsonDecode(sectionsRaw) as List)
          .map((item) => SectionModel.fromMap(item as Map<String, dynamic>))
          .toList();

      final orderedSections = form.sectionIds
          .map(
            (sectionId) => sections.cast<SectionModel?>().firstWhere(
                  (section) => section?.id == sectionId,
                  orElse: () => null,
                ),
          )
          .whereType<SectionModel>()
          .toList();

      return Result.success(orderedSections);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
