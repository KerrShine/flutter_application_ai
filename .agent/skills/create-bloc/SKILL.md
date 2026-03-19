---
name: create-bloc
description: 協助建立符合專案架構規範的 Flutter BLoC 類別 (Generates Flutter BLoC, Event, and State classes following the project's architecture guidelines).
---

# Create Bloc Skill (建立 BLoC 功能)

此 Skill 協助你為 Flutter 應用程式建立一個新的 BLoC 元件，包含 Event、State 與 Bloc 本體。

## 使用時機 (When to use this skill)

-   當使用者要求建立新的 "Bloc"、"Cubit" (本專案偏好 BLoC) 或 "State Management" (狀態管理) 時。
-   用於處理複雜的頁面邏輯或全域狀態。

## 規則與慣例 (Rules & Conventions)

1.  **檔案結構 (File Structure)**:
    -   放置於 `lib/page/[feature]/bloc/` 或 `lib/data/[feature]/` (視功能層級而定)。
    -   通常包含三個類別：`[Feature]Bloc`, `[Feature]Event`, `[Feature]State`。
    -   建議放在同一個檔案或依照團隊慣例拆分 (本 Skill 預設依照範例拆分或合併，這裡採用單一功能資料夾下的結構)。

2.  **Event (事件) 規則**:
    -   **不使用 `abstract class` 宣告** Base Event (直接使用一般 class)。
    -   Class 命名: `PascalCase` (例如: `LoginEvent`)。
    -   必須繼承 `Equatable`。
    -   透過 `props` 實作比對。

3.  **State (狀態) 規則**:
    -   必須定義 Status Enum (例如: `LoginStatus { init, success, failure }`)。
    -   Class 命名: `PascalCase` (例如: `LoginState`)。
    -   必須繼承 `Equatable`。
    -   必須實作 `copyWith` 方法。
    -   所有變數必須有初始值。

4.  **Bloc (邏輯) 規則**:
    -   **Constructor Injection**: 注入 `Service` 層 (不可直接注入 Repository)。
    -   **Event Handler**:
        -   使用 `on<Event>(_onEvent)` 註冊。
        -   實作邏輯必須封裝在 **私有函式** (例如: `_onInitEvent`)。
        -   變數採用 `lowerCamelCase`。
        -   事件排序依照英文大寫字母排序。
    -   **邏輯限制**:
        -   所有邏輯必須由 Event 觸發。
        -   只負責處理業務邏輯轉發與狀態變更。

5.  **依賴注入 (DI)**:
    -   必須在 `lib/main.dart` (或 `initDI` 函式中) 註冊。
    -   使用 `sl.registerFactory<[Name]Bloc>(() => [Name]Bloc(sl<[Name]Service>()));`。

## 程式碼模板 (Template)

### 1. Event Class

**File**: `lib/page/[feature]/bloc/[name]_event.dart`

```dart
part of '[name]_bloc.dart';

class [Name]Event extends Equatable {
  const [Name]Event();

  @override
  List<Object> get props => [];
}

// 範例：初始化事件
class InitEvent extends [Name]Event {
  const InitEvent();
}

// 範例：帶參數事件
class SomeActionEvent extends [Name]Event {
  final String id;
  const SomeActionEvent(this.id);

  @override
  List<Object> get props => [id];
}
```

### 2. State Class

**File**: `lib/page/[feature]/bloc/[name]_state.dart`

```dart
part of '[name]_bloc.dart';

enum [Name]Status {
  init,
  loading,
  success,
  failure,
}

class [Name]State extends Equatable {
  final [Name]Status status;
  final String message;
  // 其他資料欄位

  const [Name]State({
    this.status = [Name]Status.init,
    this.message = '',
  });

  [Name]State copyWith({
    [Name]Status? status,
    String? message,
  }) {
    return [Name]State(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [status, message];
}
```

### 3. Bloc Class

**File**: `lib/page/[feature]/bloc/[name]_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:[project_name]/service/[name]_service.dart'; // Import Service

part '[name]_event.dart';
part '[name]_state.dart';

class [Name]Bloc extends Bloc<[Name]Event, [Name]State> {
  final [Name]Service _service;

  [Name]Bloc(this._service) : super(const [Name]State()) {
    on<InitEvent>(_onInitEvent);
    on<SomeActionEvent>(_onSomeAction);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<[Name]State> emit,
  ) async {
    // Logic here
  }

  Future<void> _onSomeAction(
    SomeActionEvent event,
    Emitter<[Name]State> emit,
  ) async {
    emit(state.copyWith(status: [Name]Status.loading));
    
    final result = await _service.doSomething(event.id);
    
    if (result.isSuccess) {
      emit(state.copyWith(
        status: [Name]Status.success,
        // data: result.data
      ));
    } else {
      emit(state.copyWith(
        status: [Name]Status.failure,
        message: result.error,
      ));
    }
  }
}
```

### 4. DI Registration

**File**: `lib/main.dart` (inside `initDI` function)

```dart
// [Name] Bloc
sl.registerFactory<[Name]Bloc>(() => [Name]Bloc(
  sl<[Name]Service>(),
));
```
