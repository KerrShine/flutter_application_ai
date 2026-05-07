import 'package:flutter/material.dart';

/// sign_off_editor header chip 顯示對應表單的「條件欄位」設定狀態。
///
/// 取代既有 `SignOffFormBindingStatus`：條件欄位是原子定義（一個 definition
/// 不是「半完成」就是「完成」由 saveDraft 強制驗證），所以無 partial 狀態。
enum SignOffConditionFieldStatus {
  /// ✅ 已定義：draft 存在且至少有 1 個 ConditionFieldDefinition
  ready,

  /// ❌ 未定義：draft 不存在或 definitions 為空
  none,
}

extension SignOffConditionFieldStatusX on SignOffConditionFieldStatus {
  IconData get icon {
    switch (this) {
      case SignOffConditionFieldStatus.ready:
        return Icons.check_circle;
      case SignOffConditionFieldStatus.none:
        return Icons.error_outline;
    }
  }

  /// 短文字（dropdown item 用）。
  String get shortLabel {
    switch (this) {
      case SignOffConditionFieldStatus.ready:
        return '已定義';
      case SignOffConditionFieldStatus.none:
        return '未定義';
    }
  }

  /// chip 詳細文字（含計數）。
  String fullLabel(int definitionCount) {
    switch (this) {
      case SignOffConditionFieldStatus.ready:
        return '已定義 $definitionCount 個條件欄位';
      case SignOffConditionFieldStatus.none:
        return '未定義條件欄位';
    }
  }
}
