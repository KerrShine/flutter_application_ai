abstract class TempDataStorage {
  Future<void> init();
  Future<void> writeJson({required String fileName, required String content});
  Future<String?> readJson(String fileName);
  Future<void> deleteJson(String fileName);
}
