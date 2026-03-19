---
name: create-page
description: 協助建立符合專案架構規範的 Flutter Page 類別 (Generates Flutter Page classes following the project's architecture guidelines).
---

# Create Page Skill (建立 Page 功能)

此 Skill 協助你為 Flutter 應用程式建立一個新的 Page (頁面) 元件，包含正確的 BLoC 注入、生命週期管理與狀態監聽。

## 使用時機 (When to use this skill)

- 當使用者要求建立新的 "Page"、"畫面" 或 "View" 時。
- 當你需要新增一個完整的功能頁面並連接 BLoC 時。

## 規則與慣例 (Rules & Conventions)

1. **基本規範 (General Rules)**:
   - 頁面主檔必須繼承 `StatefulWidget`。
   - 檔名必須以 `_page.dart` 結尾 (例如: `home_page.dart`)。
   - 必須放置於 `lib/page/[feature]/` 目錄下。
   - View 層**嚴禁**處理商業邏輯、API 呼叫、資料計算、驗證邏輯、操作 Repository 或 Service 等內容。
   - View 層職責僅限於：畫面呈現、收集使用者互動、發送 BLoC Event、顯示 State 結果。
   - Navigator 操作邏輯通常外推至 RouteName / AppRouter ，View 只能觸發「導航事件」(Event)，導航決策可在 BLoC/外層協調層處理。

2. **BLoC 注入與生命週期 (BLoC Injection & Lifecycle)**:
   - 透過 `get_it` (即 `sl<[Name]Service>()`) 取出 Service 注入給 BLoC (或其他所需相依元件)。
   - 必須透過 `initState` 初始化 BLoC 實例並發送初始事件 (Initial Event)。
   - 必須透過 `dispose` 執行 `_bloc.close()` 來釋放資源。
   - BLoC 的提供**不得使用** `BlocProvider(create: ...)`，必須先在 State 宣告變數，再使用 `BlocProvider.value(value: _bloc, ...)` 提供給子層。

3. **狀態監聽與 UI 構建 (State Listening & UI Building)**:
   - 頂層結構必須是 `BlocProvider.value` 裡面包裹 `MultiBlocListener` (處理狀態監聽，包括 Loading 或各種狀態變更)，最內層才是 `BlocBuilder` 負責視圖更新。
   - `BlocListener` 需使用 `listenWhen: (previous, current) => previous.status != current.status` 做兩段式判斷，避免重複觸發。
   - Dialog（對話框）與 SnackBar 的觸發**必須**在 `BlocListener` 中根據 State 改變而執行，**嚴禁**在 `Button.onPressed` 或其他互動元件裡中直接呼叫 `showDialog` 或 `ScaffoldMessenger`。

4. **互動事件發送 (Interaction Events)**:
   - UI 的互動行為只能使用事件傳遞到 BLoC，不能做邏輯判斷。
   - 利用 `context.read<[Name]Bloc>().add([Event]())` 發送使用者的操作事件。

5. **私有元件 (Private Widgets)**:
   - 私有元件需放入該同層資料夾下 `widgets/` 目錄中。
   - 單個私有元件一個檔案。
   - 元件 (Widget) 頁面使用 `StatelessWidget`。
   - 檔名後方必須 `_widget.dart` 結尾 (例如: `login_widget.dart`)。
   - Widget 不得呼叫 Service、Repository 或執行資料處理，所有邏輯必須由 BLoC 事件觸發，或透過 CallBack 將事件或結果傳回 Parent。

## 程式碼模板 (Template)

**File**: `lib/page/[feature]/[name]_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection/injection.dart'; // import sl
import 'bloc/[name]_bloc.dart';
import '../../service/[name]_service.dart';

class [Name]Page extends StatefulWidget {
  const [Name]Page({super.key});

  @override
  State<[Name]Page> createState() => _[Name]PageState();
}

class _[Name]PageState extends State<[Name]Page> {
  late final [Name]Bloc _bloc;

  @override
  void initState() {
    super.initState();
    // 透過 DI 注入 Service 來初始化 Bloc
    _bloc = [Name]Bloc(sl<[Name]Service>());
    // 發送初始事件
    _bloc.add(const InitEvent());
  }

  @override
  void dispose() {
    // 關閉 Bloc
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          // 狀態監聽範例，例如：處理 Dialog、SnackBar、導航
          BlocListener<[Name]Bloc, [Name]State>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == [Name]Status.failure) {
                // 顯示錯誤訊息範例
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state.status == [Name]Status.success) {
                // 處理成功後邏輯
              }
            },
          ),
          /*
          BlocListener<[Name]Bloc, [Name]State>(
            listenWhen: (previous, current) => previous.isLoading != current.isLoading,
            listener: (context, state) {
              // 處理 Loading dialog 顯示與隱藏
            },
          ),
          */
        ],
        child: BlocBuilder<[Name]Bloc, [Name]State>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('[Name] Page'),
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, [Name]State state) {
    if (state.status == [Name]Status.init || state.status == [Name]Status.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // UI Layout 呈現
        Center(
          child: Text('Current Status: ${state.status}'),
        ),
        ElevatedButton(
          onPressed: () {
            // UI 的互動行為只能使用事件，不能做邏輯判斷
            context.read<[Name]Bloc>().add(const SomeActionEvent());
          },
          child: const Text('Action'),
        ),
      ],
    );
  }
}
```
