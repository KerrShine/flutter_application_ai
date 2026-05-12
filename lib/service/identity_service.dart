import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

/// 身分切換器初始載入結果。
///
/// `current` 為 null 代表「系統內無任何員工」，UI 應顯示引導建立員工狀態；
/// 其餘情況 service 會自動 fallback 並寫回 LocalStorage，呼叫端不需另外處理。
///
/// `departmentNames` 是 `Map<departmentId, name>` — 給 UI 顯示部門名稱用，
/// 避免在 widget 層每次 lookup org config。
class IdentityInitialData {
  final EmployeeModel? current;
  final List<EmployeeModel> candidates;
  final Map<String, String> departmentNames;

  const IdentityInitialData({
    this.current,
    this.candidates = const [],
    this.departmentNames = const {},
  });

  bool get hasIdentity => current != null;
}

/// 模擬「目前登入身分」的 dev impersonation service。
///
/// 配合 `CurrentEmployeeBloc` 與 home drawer 的 `IdentityCardWidget`，
/// 提供可在執行期切換的當前員工狀態。LocalStorage 持久化以便重啟保留。
///
/// 不負責 RBAC（誰能做什麼）— 那由各功能依 currentEmployee 自行判斷。
class IdentityService {
  final EmpInfoRepository _empInfoRepository;
  final OrgDesignRepository _orgDesignRepository;
  final LocalStorage _localStorage;

  static const String storageKey = 'current_employee_id_key';

  IdentityService(
    this._empInfoRepository,
    this._orgDesignRepository,
    this._localStorage,
  );

  /// 載入當前身分 + 全部候選員工。
  ///
  /// 解析順序：
  ///   1. 讀 LocalStorage 內 employeeId → 找到對應 EmployeeModel
  ///   2. 找不到（已刪 / 空值）→ fallback 到第一個 isActive 員工，並寫回 storage
  ///   3. 連 isActive 都沒有 → 用第一筆（即使停用）
  ///   4. 員工清單空 → 回傳 `current = null`
  Future<Result<IdentityInitialData>> loadInitial() async {
    try {
      final empsResult = await _empInfoRepository.loadEmployees();
      if (!empsResult.isSuccess) {
        return Result.failure(empsResult.error ?? '員工資料讀取失敗');
      }
      final all = empsResult.data ?? const <EmployeeModel>[];
      final departmentNames = await _loadDepartmentNames();
      if (all.isEmpty) {
        return Result.success(IdentityInitialData(
          departmentNames: departmentNames,
        ));
      }

      final stored = _localStorage.getString(storageKey);
      EmployeeModel? current;
      if (stored != null && stored.isNotEmpty) {
        current = all.cast<EmployeeModel?>().firstWhere(
              (e) => e?.employeeId == stored,
              orElse: () => null,
            );
      }
      current ??= all.cast<EmployeeModel?>().firstWhere(
            (e) => e?.isActive ?? false,
            orElse: () => null,
          );
      current ??= all.first;

      // 將 fallback 結果寫回，使下次重啟一致
      if (stored != current.employeeId) {
        await _localStorage.setString(storageKey, current.employeeId);
      }

      return Result.success(IdentityInitialData(
        current: current,
        candidates: all,
        departmentNames: departmentNames,
      ));
    } catch (ex) {
      return Result.failure('載入身分失敗: ${ex.toString()}');
    }
  }

  /// 從組織設定 config 取出 `departmentId → name` 映射。失敗回空 map。
  Future<Map<String, String>> _loadDepartmentNames() async {
    try {
      final result = await _orgDesignRepository.loadConfig();
      if (!result.isSuccess || result.data == null) return const {};
      return {
        for (final node in result.data!.departmentNodes)
          node.departmentId: node.name,
      };
    } catch (_) {
      return const {};
    }
  }

  /// 切換到指定 employeeId。回傳完整 EmployeeModel 給 caller 更新 state。
  Future<Result<EmployeeModel>> switchTo(String employeeId) async {
    try {
      if (employeeId.isEmpty) {
        return Result.failure('employeeId 不可為空');
      }
      final found = await _empInfoRepository.loadById(employeeId);
      if (!found.isSuccess) {
        return Result.failure(found.error ?? '查詢失敗');
      }
      if (found.data == null) {
        return Result.failure('找不到員工 $employeeId');
      }
      await _localStorage.setString(storageKey, employeeId);
      return Result.success(found.data!);
    } catch (ex) {
      return Result.failure('切換失敗: ${ex.toString()}');
    }
  }

  /// 重新載入候選列表（員工資料被異動後 caller 可呼叫）。
  Future<Result<List<EmployeeModel>>> reloadCandidates() async {
    return _empInfoRepository.loadEmployees();
  }

  /// 清除目前身分（測試 / 登出用）。
  Future<void> clear() async {
    await _localStorage.remove(storageKey);
  }
}
