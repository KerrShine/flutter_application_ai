import 'package:flutter_application_ai/model/condition_field_draft.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class ConditionFieldRepository {
  Future<Result<ConditionFieldDraft?>> loadDraft(String formId);
  Future<Result<List<ConditionFieldDraft>>> loadAllDrafts();
  Future<Result<bool>> saveDraft(ConditionFieldDraft draft);
  Future<Result<bool>> deleteDraft(String formId);
}
