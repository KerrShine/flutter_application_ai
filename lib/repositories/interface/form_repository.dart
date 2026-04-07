import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart'; // assuming result.dart is here

abstract class FormRepository {
  Future<Result<bool>> saveDraftForm(FormModel model);
  Future<Result<List<FormModel>>> loadDraftForms();
  Future<Result<bool>> deleteDraftForm(String formId);
  Future<Result<bool>> saveAllDraftForms(List<FormModel> forms);
  Future<Result<FormModel?>> loadFormById(String formId);
}
