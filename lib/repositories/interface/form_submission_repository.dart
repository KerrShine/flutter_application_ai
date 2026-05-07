import 'package:flutter_application_ai/model/form_submission_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class FormSubmissionRepository {
  Future<Result<List<FormSubmissionModel>>> loadAll();
  Future<Result<List<FormSubmissionModel>>> loadByApplicantId(
      String applicantId);
  Future<Result<FormSubmissionModel?>> loadById(String submissionId);
  Future<Result<bool>> save(FormSubmissionModel submission);
  Future<Result<bool>> saveAll(List<FormSubmissionModel> submissions);
}
