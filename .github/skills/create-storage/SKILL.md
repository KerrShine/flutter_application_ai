---
name: create-storage
description: 協助建立符合專案架構規範的跨平台本地資料儲存層 (Generates a multi-platform Local Storage layer for Web and App).
---

# Create Storage Skill (建立跨平台本地儲存層)

此 Skill 協助你為 Flutter 應用程式建立一個標準化的跨平台本地儲存層 (`data/local/`)，包含 Web (`package:web` session storage) 與 App (`shared_preferences`) 的實作。

## 使用時機 (When to use this skill)

-   當專案需要建立或重構本地資料儲存 (Local Storage) 機制時。
-   當專案需要同時支援 Flutter Web 與 Flutter App，且需要針對不同平台使用不同的儲存方案 (Web 用 session、App 用 SharedPreferences) 時。

## 規則與慣例 (Rules & Conventions)

1.  **資料夾結構 (Architecture)**:
    -   所有檔案必須放置於 `lib/data/local/` 內。
2.  **檔案與介面命名 (Naming & Interfaces)**:
    -   `local_storage.dart`: 必定包含抽象類別 `LocalStorage` 介面。包含如 `setString`, `getString`, `setInt`, `getInt`, `setBool`, `getBool`, `remove`, `clear` 等非同步宣告。
    -   `storage_mobile.dart`: 必定實作 `LocalStorage`，並利用 `shared_preferences` 實現。
    -   `storage_web.dart`: 必定實作 `LocalStorage`，並利用 `package:web/web.dart` 的 `window.sessionStorage` 實現 (注意：不要使用不支援 Wasm 的 `dart:html`)。
    -   `storage_stub.dart`: 提供預設拋出例外，給非 Web/App 環境備用。
    -   `local_storage_factory.dart`: 利用 Dart 的條件引入 (Conditional Imports) 來暴露出統一的 `createStorage()` 給外層使用。
3.  **相依套件 (Dependencies)**:
    -   必須確保 `pubspec.yaml` 已安裝 `shared_preferences` 與 `web`。
4.  **依賴注入 (DI)**:
    -   在 `lib/injection/dependency_injection.dart` 內註冊為 Singleton： `sl.registerSingleton<LocalStorage>(createStorage()..init());`

## 程式碼模板 (Template)

### 1. 介面層 `local_storage.dart`

```dart
abstract class LocalStorage {
  Future<void> init();
  Future<void> setString(String key, String value);
  String? getString(String key);
  // ... (其他 set/get 方法)
  Future<void> remove(String key);
  Future<void> clear();
}
```

### 2. App 實作層 `storage_mobile.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:[project_name]/data/local/local_storage.dart';

LocalStorage getLocalStorage() => SharedPrefsStorage();

class SharedPrefsStorage implements LocalStorage {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  @override
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  @override
  String? getString(String key) => _prefs?.getString(key);
  // ... 其他實作
}
```

### 3. Web 實作層 `storage_web.dart`

```dart
import 'package:web/web.dart' as web;
import 'package:[project_name]/data/local/local_storage.dart';

LocalStorage getLocalStorage() => WebSessionStorage();

class WebSessionStorage implements LocalStorage {
  @override
  Future<void> init() async {} // sessionStorage 是同步的

  @override
  Future<void> setString(String key, String value) async {
    web.window.sessionStorage.setItem(key, value);
  }

  @override
  String? getString(String key) => web.window.sessionStorage.getItem(key);
  // ... 其他實作
}
```

### 4. 條件引用層 `local_storage_factory.dart`

```dart
import 'package:[project_name]/data/local/local_storage.dart';

import 'storage_stub.dart'
    if (dart.library.html) 'storage_web.dart'
    if (dart.library.io) 'storage_mobile.dart';

LocalStorage createStorage() => getLocalStorage();
```
