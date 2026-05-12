---
name: create-theme
description: "協助建立或修改符合專案架構規範的 Flutter Theme 類別與樣式設定。Use when: 建立 theme、調整主題、管理 AppColors、TextSize、ThemeData、全域 UI 樣式、顏色與字級設定；產生 widgets 時若涉及樣式，也必須先參考此 Skill。"
---

# Create Theme Skill (建立 Theme 功能)

此 Skill 協助你在 Flutter 專案中建立或調整全域 Theme 設定，並遵守本專案在 AGENTS.md 中定義的 UI 規範。

## 使用時機 (When to use this skill)

- 當使用者要求建立新的 Theme 檔案或調整既有 Theme 設定時。
- 當你需要集中管理顏色、字體大小、按鈕樣式、輸入框樣式或其他全域 UI 規格時。
- 當功能頁面出現重複樣式，且應抽離到 Theme 層統一管理時。
- 當你要產生新的 Widget，且其中涉及顏色、字級、間距、按鈕、輸入框或其他可重用外觀規格時，需先回來參考此 Skill，判斷是否應優先建置在 `lib/theme/`。

## 規則與慣例 (Rules & Conventions)

1. 基本規範 (General Rules)
- Theme 僅負責管理全域 UI 規格，不可依賴任何商業邏輯或業務狀態。
- Widget 不得任意定義與全域規格衝突的樣式，除非是明確的設計特例。
- Theme 層不得處理資料、事件、導頁、Repository 或 Service 邏輯。

2. 位置與命名 (Location & Naming)
- Theme 相關檔案放在 `lib/theme/`。
- 檔名採用 `snake_case`。
- 若專案尚未拆分多檔，優先延續目前 repo 既有單檔模式：`lib/theme/theme.dart`。
- 若樣式內容成長過大，可再依用途拆成：
  - `app_colors.dart`
  - `text_size.dart`
  - `app_theme.dart`

3. 架構原則 (Architecture)
- 顏色常數集中於 `AppColors`。
- 字級常數集中於 `TextSize`。
- 若需擴充元件樣式，使用 `ThemeData` 或對應子題材，例如：
  - `ElevatedButtonThemeData`
  - `InputDecorationTheme`
  - `TextTheme`
  - `AppBarTheme`
- Theme 應提供可重用常數與明確命名，避免在頁面中散落 magic numbers。

4. 與本專案對齊 (Repository Alignment)
- 目前 repo 已存在 `lib/theme/theme.dart`。
- 目前 repo 已有以下結構：
  - `AppColors`
  - `TextSize`
- 若只是補充顏色、字級或元件樣式，應優先修改現有 `theme.dart`，而非重新發明另一套結構。

5. Main / App 接入原則 (App Integration)
- 若新增 `ThemeData`，應由 App 根層接入，例如 `MaterialApp(theme: ...)`。
- 不可在 `main.dart` 或 `MyApp` 中寫入商業邏輯；僅可做全域 Theme 設定注入。


## 目前 Repo 範例

目前 `lib/theme/theme.dart`：

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2962F1); // 主色
}

class TextSize {
  static const double bigText = 40;
}
```

## 建議建立方式 (Recommended Pattern)

### 1. 基礎常數

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2962F1);
  static const Color secondary = Color(0xFF0F172A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
}

class TextSize {
  static const double bigText = 40;
  static const double h1 = 28;
  static const double h2 = 22;
  static const double body = 14;
  static const double caption = 12;
}
```

### 2. ThemeData 擴充

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: TextSize.h1,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: TextSize.h2,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: TextSize.body,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: TextSize.caption,
        color: AppColors.textSecondary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
```

### 3. 在 MyApp 接入

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bloc Base',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## 執行準則 (Execution Checklist)

建立或修改 Theme 時，請遵守以下流程：

1. 先確認目前樣式是否已存在於 `lib/theme/`。
2. 若只是補充既有顏色或字級，優先擴充現有檔案。
3. 若需要新增 `ThemeData`，保持與現有 `AppColors` / `TextSize` 命名一致。
4. 不要把頁面專屬商業邏輯或狀態放進 Theme。
5. 若變更影響全域元件外觀，需同步檢查主要頁面顯示是否受影響。

## 常見錯誤 (Common Pitfalls)

- 在 Widget 中直接寫大量硬編碼顏色與字級，卻沒有抽到 Theme。
- 建立 Theme 類別但沒有在 `MaterialApp` 接入。
- Theme 檔混入 API、BLoC、Service、事件處理。
- 顏色與字級命名不明確，例如 `blue1`, `text2`。
- 同一個專案中同時存在多套互相衝突的主題常數。

## 預期輸出 (Expected Output)

當使用此 Skill 時，應優先產出以下其中一種結果：
- 修改 `lib/theme/theme.dart`，補齊 `AppColors`、`TextSize` 或 `AppTheme`
- 新增 `lib/theme/` 下的主題拆分檔案
- 協助將頁面中的重複樣式抽離到 Theme 層


