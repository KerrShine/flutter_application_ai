---
name: create-test
description: "協助建立符合專案架構規範的 Flutter 單元測試與 Service 測試。Use when: 建立 test/service 測試、撰寫 mocktail 測試、驗證 Service 與 Repository 互動、補 service unit test。"
---

# Create Test Skill (建立測試)

此 Skill 協助你在本專案中建立符合既有風格的 Flutter 單元測試，優先針對 `test/service/` 下的 Service 測試。

## 使用時機 (When to use this skill)

- 當使用者要求為 `Service` 補單元測試時。
- 當需要在 `test/service/` 新增測試檔時。
- 當需要驗證 `Service` 與 `Repository` 的互動、回傳結果與錯誤處理時。
- 當需要使用 `mocktail` 撰寫 mock / fake 測試替身時。

## 規則與慣例 (Rules & Conventions)

1. **測試目錄與命名**
   - Service 測試放在 `test/service/`。
   - 檔名使用 `snake_case`，並以 `_test.dart` 結尾。
   - 檔名應對應被測試類別，例如：`org_design_service_test.dart`。

2. **測試套件與依賴**
   - 使用 `flutter_test`。
   - 使用 `mocktail` 建立 mock 與 fake。
   - 依專案既有設計，Service 測試直接 mock `Repository`，不要 mock `Service` 本身。

3. **測試結構**
   - 使用 `group()` 依照 Service method 分組，例如：`group('loadTreeDesignConfig', ...)`。
   - 使用 `test()` 描述行為結果，測試名稱偏向英文敘述句。
   - 基本結構採用 Arrange / Act / Assert，但不需額外寫註解標題。

4. **初始化模式**
   - `late` 宣告 repository 與 service。
   - 在 `setUp()` 中重建 mock 與 service instance。
   - 若 `mocktail` 需要 fallback value，於 `setUpAll()` 呼叫 `registerFallbackValue(...)`。

5. **驗證重點**
   - 先驗證 `result.isSuccess`、`result.data`、`result.error`。
   - 驗證 Service 是否正確轉譯 Repository 回傳結果。
   - 驗證 Repository 方法是否有被呼叫，必要時使用 `verify(...).called(1)`。
   - 避免只測 `called(1)`，要同時驗證輸出內容。

6. **與專案架構一致**
   - Service 必須透過 constructor 注入 Repository。
   - 測試應符合 `Result<T>` 回傳模式。
   - 若單一功能尚未可測，應先補足最小必要依賴後再回報。

## 既有風格參考 (Project Pattern)

目前 `test/service/` 已有下列模式：

- `class MockXxxRepository extends Mock implements XxxRepository {}`
- `class FakeXxxModel extends Fake implements XxxModel {}`
- `setUpAll(() { registerFallbackValue(...); })`
- `setUp(() { repository = Mock...; service = XxxService(repository); })`
- `when(() => repository.someMethod()).thenAnswer((_) async => Result.success(...))`
- `expect(result.isSuccess, isTrue)`
- `verify(() => repository.someMethod(any())).called(1)`

## 建議模板 (Template)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:[project_name]/repositories/interface/[feature]_repository.dart';
import 'package:[project_name]/service/[feature]_service.dart';
import 'package:[project_name]/unit/base/result.dart';

class Mock[Feature]Repository extends Mock implements [Feature]Repository {}

class Fake[InputModel] extends Fake implements [InputModel] {}

void main() {
  late Mock[Feature]Repository repository;
  late [Feature]Service service;

  setUpAll(() {
    registerFallbackValue(Fake[InputModel]());
  });

  setUp(() {
    repository = Mock[Feature]Repository();
    service = [Feature]Service(repository);
  });

  group('[methodName]', () {
    test('returns success when repository completes successfully', () async {
      when(() => repository.[methodName]())
          .thenAnswer((_) async => Result.success(true));

      final result = await service.[methodName]();

      expect(result.isSuccess, isTrue);
      verify(() => repository.[methodName]()).called(1);
    });
  });
}
```

## Service 測試撰寫準則

- 成功案例至少一筆。
- 失敗案例至少一筆。
- 若方法含資料轉換，需驗證轉換後欄位。
- 若方法含多個 repository 呼叫，需驗證呼叫順序與整合結果。
- 若方法負責寫入資料，需驗證寫入 API 被正確呼叫。

## 執行與驗證

依照專案 `AGENTS.md`，執行測試前請先準備環境變數：

```powershell
$env:TEMP="C:\temp"
$env:TMP="C:\temp"
mkdir C:\temp -Force
flutter test
```

若只驗證單一檔案，優先執行該測試檔，避免整包測試過慢。
