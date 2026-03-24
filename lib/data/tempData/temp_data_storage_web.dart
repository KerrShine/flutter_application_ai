import 'package:web/web.dart' as web;
import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/data/tempData/temp_data_storage.dart';

TempDataStorage getTempDataStorage(LocalStorage localStorage) {
  return WebTempDataStorage();
}

class WebTempDataStorage implements TempDataStorage {
  static const String _tempDataPrefix = 'temp_data_file::';

  @override
  Future<void> init() async {}

  @override
  Future<String?> readJson(String fileName) async {
    return web.window.sessionStorage.getItem('$_tempDataPrefix$fileName');
  }

  @override
  Future<void> writeJson({
    required String fileName,
    required String content,
  }) async {
    web.window.sessionStorage.setItem('$_tempDataPrefix$fileName', content);
  }

  @override
  Future<void> deleteJson(String fileName) async {
    web.window.sessionStorage.removeItem('$_tempDataPrefix$fileName');
  }
}
