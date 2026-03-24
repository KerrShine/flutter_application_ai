import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/data/tempData/temp_data_storage.dart';

TempDataStorage getTempDataStorage(LocalStorage localStorage) {
  throw UnsupportedError(
    'Cannot create a TempDataStorage without a web or io implementation',
  );
}
