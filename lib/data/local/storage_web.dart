import 'package:web/web.dart' as web;
import 'package:flutter_application_ai/data/local/local_storage.dart';

LocalStorage getLocalStorage() => WebLocalStorage();

class WebLocalStorage implements LocalStorage {
  @override
  Future<void> init() async {
    // localStorage is already available synchronously
  }

  @override
  Future<void> setString(String key, String value) async {
    web.window.localStorage.setItem(key, value);
  }

  @override
  String? getString(String key) {
    return web.window.localStorage.getItem(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    web.window.localStorage.setItem(key, value.toString());
  }

  @override
  int? getInt(String key) {
    final val = web.window.localStorage.getItem(key);
    if (val != null) return int.tryParse(val);
    return null;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    web.window.localStorage.setItem(key, value.toString());
  }

  @override
  bool? getBool(String key) {
    final val = web.window.localStorage.getItem(key);
    if (val == 'true') return true;
    if (val == 'false') return false;
    return null;
  }

  @override
  Future<void> remove(String key) async {
    web.window.localStorage.removeItem(key);
  }

  @override
  Future<void> clear() async {
    web.window.localStorage.clear();
  }
}
