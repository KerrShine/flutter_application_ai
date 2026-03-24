import 'dart:io';

import 'package:flutter_application_ai/data/tempData/temp_data_storage_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late IoTempDataStorage storage;
  late File jsonFile;

  setUp(() async {
    storage = IoTempDataStorage();
    jsonFile = File(
      p.join(Directory.current.path, 'data', 'tempData', 'tree_design.json'),
    );
    if (await jsonFile.exists()) {
      await jsonFile.delete();
    }
  });

  tearDown(() async {
    if (await jsonFile.exists()) {
      await jsonFile.delete();
    }
  });

  test('writes and reads actual json file in data/tempData', () async {
    const content = '{"orgId":"org-1","orgName":"測試組織"}';

    await storage.init();
    await storage.writeJson(
      fileName: 'tree_design.json',
      content: content,
    );

    expect(await jsonFile.exists(), isTrue);
    expect(await jsonFile.readAsString(), content);
    expect(await storage.readJson('tree_design.json'), content);
  });
}
