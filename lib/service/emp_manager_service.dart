import 'package:flutter_application_ai/unit/base/result.dart';

class EmpManagerService {
  EmpManagerService();

  Future<Result<bool>> initData() async {
    try {
      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
