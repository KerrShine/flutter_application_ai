import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class FormDataBindingRepository {
  Future<Result<FormDataBindingDraft?>> loadDraftByBindingId(
    String formId,
    String bindingId,
  );
  Future<Result<List<FormDataBindingDraft>>> loadDraftsByFormId(String formId);
  Future<Result<bool>> saveDraft(FormDataBindingDraft draft);
}
