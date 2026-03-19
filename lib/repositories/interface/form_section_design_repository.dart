abstract class FormSectionDesignRepository {
  Future<void> saveDraft(String json);
  String? loadDraft();
}
