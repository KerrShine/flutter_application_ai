import 'package:flutter_application_ai/unit/result.dart';

class MainService {
  MainService();

  // 必須回傳 Result<T>
  Future<Result<bool>> initData() async {
    try {
      // 在此處實作資料初始化邏輯
      await Future.delayed(const Duration(milliseconds: 500));
      return Result.success(true);
    } catch (ex) {
      // 統一轉譯錯誤
      return Result.failure(ex.toString());
    }
  }
}
