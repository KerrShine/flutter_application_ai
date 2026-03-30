---
name: create-repository
description: 協助建立符合專案架構規範的 Flutter Repository 類別 (Generates Flutter repository classes following the project's architecture guidelines, including Interface and Implementation).
---

# Create Repository Skill (建立 Repository 功能)

此 Skill 協助你為 Flutter 應用程式建立一個新的 Repository，包含介面 (Interface) 與實作 (Implementation)。

## 使用時機 (When to use this skill)

-   當使用者要求建立新的 "Repository" 或 "Data Access Layer" (資料存取層) 時。
-   用於封裝 API 呼叫、資料庫存取或其他資料來源。

## 規則與慣例 (Rules & Conventions)

1.  **分層結構 (Layering)**:
    -   Repository 必須分為 **介面 (Interface)** 與 **實作 (Implementation)** 兩部分。
    -   **介面**位置: `lib/repositories/interface/`
    -   **實作**位置: `lib/repositories/`

2.  **命名 (Naming)**:
    -   **介面檔案**: `snake_case` (例如: `login_repository.dart`)
    -   **介面類別**: `PascalCase` (例如: `LoginRepository`)
    -   **實作檔案**: `snake_case` + `_impl` (例如: `login_repository_impl.dart`)
    -   **實作類別**: `PascalCase` + `Impl` (例如: `LoginRepositoryImpl`)

3.  **職責 (Responsibility)**:
    -   專職處理資料存取 (API, DB, Local Storage)。
    -   **絕對不可**包含商業邏輯 (Business Logic)。
    -   **絕對不可**處理 UI 或狀態管理。

4.  **依賴 (Dependencies)**:
    -   透過建構子注入 `DioClient` (若需 API) 或 `Dao` (若需 DB)。

5.  **依賴注入 (Dependency Injection)**:
    -   必須在 `lib/main.dart` (或 `initDI` 函式中) 註冊。
    -   使用 `sl.registerFactory<Interface>(() => Implementation(...))`。

## 程式碼模板 (Template)

### 1. Repository Interface (介面)

**File**: `lib/repositories/interface/[name]_repository.dart`

```dart
abstract class [Name]Repository {
  Future<[ReturnType]> fetchData([Params]);
}
```

### 2. Repository Implementation (實作)

**File**: `lib/repositories/[name]_repository_impl.dart`

```dart
import 'package:[project_name]/repositories/interface/[name]_repository.dart';

class [Name]RepositoryImpl implements [Name]Repository {
  final DioClient _dioClient;
  // final [Name]Dao _dao; // 若有本地資料庫需求

  [Name]RepositoryImpl(this._dioClient);

  @override
  Future<[ReturnType]> fetchData([Params]) async {
    return await _dioClient.apiRequest(
      request: () => _dioClient.get('/api/path'), // 或 post 等
      mapper: (data) {
        // Mapping logic here
        return [ReturnType].fromMap(data);
      },
    );
  }
}
```

### 3. DI Registration (註冊)

**File**: `lib/main.dart` (inside `initDI` function)

```dart
// [Name] Repository
sl.registerFactory<[Name]Repository>(() => [Name]RepositoryImpl(
  sl<DioClient>(),
));
```
