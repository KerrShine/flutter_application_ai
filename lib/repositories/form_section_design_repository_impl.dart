import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/repositories/interface/form_section_design_repository.dart';

const _kDraftKey = 'form_section_design_draft';

class FormSectionDesignRepositoryImpl implements FormSectionDesignRepository {
  final LocalStorage localStorage;

  FormSectionDesignRepositoryImpl(this.localStorage);

  @override
  Future<void> saveDraft(String json) async {
    await localStorage.setString(_kDraftKey, json);
  }

  @override
  String? loadDraft() => localStorage.getString(_kDraftKey);
}
