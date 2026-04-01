---
name: create-service
description: 協助建立符合專案架構規範的 Flutter Service 類別 (Generates a Flutter service class following the project's architecture guidelines using BLoC pattern and DioClient).
---

# Create Service Skill (建立 Service 功能)

此 Skill 協助你為 Flutter 應用程式建立一個新的 Service 類別。

## 使用時機 (When to use this skill)

-   當使用者要求建立新的 "Service" 或 "Business Logic Layer" (商業邏輯層) 時。
-   用於標準化商業邏輯與 Repository 及 BLoC 之間的互動方式。

## 規則與慣例 (Rules & Conventions)

1.  **命名 (Naming)**:
    -   檔案名稱: `snake_case` (例如: `auth_service.dart`)
    -   類別名稱: `PascalCase` (例如: `AuthService`)
    -   資料夾位置: `lib/service/`
2.  **架構 (Architecture)**:
    -   Service **不需要**定義介面 (Interface)。
    -   必須透過建構子 (Constructor) 注入依賴的 `Repository`。
    -   **絕對不可**處理 UI 或狀態管理 (State Management)。
3.  **正規化輸出 (Normalized Output)**:
    -   所有公開方法必須回傳 `Result<T>` (包含成功/失敗狀態)。
    -   **不可**直接回傳原始資料或 throw exception 給上層。

4.  **錯誤處理 (Error Handling)**:
    -   必須捕捉所有例外 (Catch all exceptions)。
    -   需將底層例外轉換為使用者友善的錯誤訊息。
    -   使用 `Result.failure(message)` 回傳錯誤。

## 程式碼模板 (Template)

### 1. Result Class (正規化物件)

若專案中尚未定義 `Result` 類別，請參考以下結構 (通常位於 `lib/unit/result.dart` 或類似位置，若已存在則直接引用):

```dart
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._(this.data, this.error, this.isSuccess);
  factory Result.success(T data) => Result._(data, null, true);
  factory Result.failure(String error) => Result._(null, error, false);
}
```

### 2. Service Class

```dart
import 'package:[project_name]/service/result.dart'; // 引用 Result 定義
import 'package:[project_name]/repositories/interface/[name]_repository.dart';

class [Name]Service {
  final [Name]Repository _repository;

  [Name]Service(this._repository);

  // 必須回傳 Result<T>
  Future<Result<List<[Model]>>> getData() async {
    try {
      final data = await _repository.fetchData();
      return Result.success(data);
    } catch (ex) {
      // 統一轉譯錯誤
      return Result.failure(ex.toString());
    }
  }
}
```
