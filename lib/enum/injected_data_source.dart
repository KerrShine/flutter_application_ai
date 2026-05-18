/// 欄位「帶入指定資料」策略的候選資料源。
///
/// 對應 `BindingNullStrategy.injected` — 編輯者選此策略時須再選一個資料源 key，
/// runtime 依該 key 從系統 context（如 CurrentEmployeeBloc / DateTime.now()）取值。
///
/// v1 僅做框架；runtime 解析待後續任務實作。
enum InjectedDataSource {
  /// 登入者 employeeId
  currentEmployeeId,

  /// 登入者姓名
  currentEmployeeName,

  /// 登入者員工代碼
  currentEmployeeCode,

  /// 登入者所屬部門名稱
  currentDepartmentName,

  /// 登入者角色名稱
  currentRoleName,

  /// 今日日期（yyyy-MM-dd）
  todayDate,
}

extension InjectedDataSourceX on InjectedDataSource {
  String get code {
    switch (this) {
      case InjectedDataSource.currentEmployeeId:
        return 'currentEmployeeId';
      case InjectedDataSource.currentEmployeeName:
        return 'currentEmployeeName';
      case InjectedDataSource.currentEmployeeCode:
        return 'currentEmployeeCode';
      case InjectedDataSource.currentDepartmentName:
        return 'currentDepartmentName';
      case InjectedDataSource.currentRoleName:
        return 'currentRoleName';
      case InjectedDataSource.todayDate:
        return 'todayDate';
    }
  }

  String get label {
    switch (this) {
      case InjectedDataSource.currentEmployeeId:
        return '登入者 ID';
      case InjectedDataSource.currentEmployeeName:
        return '登入者姓名';
      case InjectedDataSource.currentEmployeeCode:
        return '登入者員編';
      case InjectedDataSource.currentDepartmentName:
        return '登入者部門名稱';
      case InjectedDataSource.currentRoleName:
        return '登入者角色名稱';
      case InjectedDataSource.todayDate:
        return '今日日期';
    }
  }

  static InjectedDataSource? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final v in InjectedDataSource.values) {
      if (v.code == code) return v;
    }
    return null;
  }
}
