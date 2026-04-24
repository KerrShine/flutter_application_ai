import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class MainService {
  final LocalStorage _localStorage;

  static const String _shortcutsKey = 'main_quick_shortcuts';
  static const int maxShortcuts = 6;

  MainService(this._localStorage);

  Future<Result<bool>> initData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  /// 從 LocalStorage 讀取已儲存的快捷路由路徑清單。
  List<String> loadShortcuts() {
    try {
      final raw = _localStorage.getString(_shortcutsKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// 將快捷路由路徑清單寫入 LocalStorage（最多 [maxShortcuts] 筆）。
  Future<Result<bool>> saveShortcuts(List<String> paths) async {
    try {
      final trimmed = paths.take(maxShortcuts).toList();
      await _localStorage.setString(_shortcutsKey, jsonEncode(trimmed));
      return Result.success(true);
    } catch (ex) {
      return Result.failure('儲存快捷失敗：${ex.toString()}');
    }
  }
}
