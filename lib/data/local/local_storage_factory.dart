import 'package:flutter_application_ai/data/local/local_storage.dart';

import 'storage_stub.dart'
    if (dart.library.html) 'storage_web.dart'
    if (dart.library.io) 'storage_mobile.dart';

LocalStorage createStorage() => getLocalStorage();
