import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/data/tempData/temp_data_storage.dart';

import 'temp_data_storage_stub.dart'
    if (dart.library.html) 'temp_data_storage_web.dart'
    if (dart.library.io) 'temp_data_storage_io.dart';

TempDataStorage createTempDataStorage(LocalStorage localStorage) {
  return getTempDataStorage(localStorage);
}
