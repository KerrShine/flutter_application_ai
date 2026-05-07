import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class SignOffRepository {
  Future<Result<List<SignOffTemplateModel>>> loadAll();
  Future<Result<List<SignOffTemplateModel>>> loadByFormId(String formId);
  Future<Result<SignOffTemplateModel?>> loadById(String templateId);
  Future<Result<bool>> save(SignOffTemplateModel template);
  Future<Result<bool>> saveAll(List<SignOffTemplateModel> templates);
  Future<Result<bool>> delete(String templateId);
}
