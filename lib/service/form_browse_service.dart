import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/form_browse_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormBrowseService {
  final FormBrowseRepository _formBrowseRepository;

  FormBrowseService(this._formBrowseRepository);

  Future<Result<List<SectionModel>>> loadSections(String formId) async {
    try {
      return await _formBrowseRepository.loadSections(formId);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
