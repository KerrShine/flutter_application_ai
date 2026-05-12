---
name: create-router
description: 協助在專案中新增或修改符合規範的 Router 設定 (Helps add or modify GoRouter routing configurations following the project's architecture).
---

# Create Router Skill (新增與管理路由)

此 Skill 協助你為 Flutter 應用程式新增或修改頁面路由設定。本專案目前採用 `go_router` 進行路由管理，以完美支援 Web SPA 的重新整理與深層連結 (Deep Link) 行為。

## 使用時機 (When to use this skill)

- 當新增了畫面 (Page) 且需要加入到應用程式的導航系統時。
- 當需要設定巢狀路由 (Nested Routes) 或底部導航列切換 (使用 ShellRoute) 時。
- 當使用者要求「將頁面加入路由」時。

## 規則與慣例 (Rules & Conventions)

1. **路由宣告位置**:
   - 所有路由定義必須集中在 `lib/route/app_router.dart` 內。
   - 絕對禁止在畫面 (View) 層面直接實作分散式的 Navigator push/pop 邏輯，需統一使用 `context.go()` 或是 `context.push()`。

2. **路由名稱統一管理 (`RouteName`)**:
   - 必須在 `RouteName` 類別中新增靜態常數 (Static Const String)。
   - 命名規則：`lowerCamelCase`，對應變數名稱需加上 `Page` 結尾 (例: `loginPage`、`formDesignerPage`)。
   - 網址路徑 (Path)：需為絕對路徑或有層次關係的路徑，全小寫加上中線 (e.g. `'/home/form-designer'`)。

3. **路由結構 (`GoRouter` 設定)**:
   - 全域的 Router 定義於 `AppRouter.router` 中。
   - 若為獨立全螢幕頁面 (如登入頁)，使用 `GoRoute` 放在頂層。
   - 若為帶有共用 UI (如側邊欄、BottomNavigationBar 的首頁架構)，需使用 **`ShellRoute`** 包覆，並將子頁面放到 `routes` 清單中。

## 程式碼模板 (Template)

### 修改 `app_router.dart`

每次新增路由時，請務必按照此結構調整 `lib/route/app_router.dart`：

```dart
import 'package:go_router/go_router.dart';
// 1. 引入新畫面的檔案
import 'package:[project_name]/page/[feature]/[feature]_page.dart';

class RouteName {
  // 滿版獨立頁面
  static const String loginPage = '/login';
  // 底部導航/側邊欄 的根節點
  static const String homePage = '/home';
  // 隸屬在 homePage 下的子功能
  static const String newFeaturePage = '/home/new-feature'; 
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteName.loginPage,
    routes: [
      // 2. 獨立路由 (無共用主框架)
      GoRoute(
        path: RouteName.loginPage,
        builder: (context, state) => const LoginPage(),
      ),
      
      // 3. 巢狀路由 (具有共用主框架如 HomePage)
      ShellRoute(
        builder: (context, state, child) {
          // HomePage 內必須有一個接收 Widget 的 child 參數
          return HomePage(child: child); 
        },
        routes: [
          GoRoute(
            path: RouteName.newFeaturePage,
            builder: (context, state) => const NewFeaturePage(),
          ),
          // 在這裡繼續新增其他的 ShellRoute 子路由...
        ],
      ),
    ],
  );
}
```

### 畫面導航方式 (Navigation in View)

若要在 BLoC Listener 或畫面上呼叫路由切換，請使用：
```dart
import 'package:go_router/go_router.dart';

// 直接跳轉，不留歷史紀錄 (替換當前位置)
context.go(RouteName.newFeaturePage);

// 推疊跳轉 (可返回)
context.push(RouteName.newFeaturePage);
```
