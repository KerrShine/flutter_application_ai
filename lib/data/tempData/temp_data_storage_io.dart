import 'dart:io';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/data/tempData/temp_data_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

TempDataStorage getTempDataStorage(LocalStorage localStorage) {
  return IoTempDataStorage();
}

class IoTempDataStorage implements TempDataStorage {
  static const String _rootFolderName = 'data';
  static const String _tempDataFolderName = 'tempData';

  Directory? _baseDirectory;

  @override
  Future<void> init() async {
    if (_baseDirectory != null) {
      return;
    }

    try {
      final projectDirectory = Directory(
        p.join(
          Directory.current.path,
          _rootFolderName,
          _tempDataFolderName,
        ),
      );
      await projectDirectory.create(recursive: true);
      _baseDirectory = projectDirectory;
    } catch (_) {
      try {
        final appDirectory = await getApplicationDocumentsDirectory();
        _baseDirectory = Directory(
          p.join(appDirectory.path, _rootFolderName, _tempDataFolderName),
        );
      } catch (_) {
        _baseDirectory = Directory(
          p.join(
            Directory.systemTemp.path,
            'flutter_application_ai',
            _rootFolderName,
            _tempDataFolderName,
          ),
        );
      }
    }

    if (!await _baseDirectory!.exists()) {
      _baseDirectory = Directory(
        _baseDirectory!.path,
      );
      await _baseDirectory!.create(recursive: true);
    }
  }

  @override
  Future<String?> readJson(String fileName) async {
    await init();
    final file = File(p.join(_baseDirectory!.path, fileName));
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  }

  @override
  Future<void> writeJson({
    required String fileName,
    required String content,
  }) async {
    await init();
    final file = File(p.join(_baseDirectory!.path, fileName));
    await file.writeAsString(content, flush: true);
  }

  @override
  Future<void> deleteJson(String fileName) async {
    await init();
    final file = File(p.join(_baseDirectory!.path, fileName));
    if (await file.exists()) {
      await file.delete();
    }
  }
}
