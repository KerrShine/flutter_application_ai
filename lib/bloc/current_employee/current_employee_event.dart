part of 'current_employee_bloc.dart';

abstract class CurrentEmployeeEvent extends Equatable {
  const CurrentEmployeeEvent();

  @override
  List<Object?> get props => [];
}

/// 從 LocalStorage 載入初始身分 + 候選清單。Home shell 啟動時呼叫一次。
class LoadInitialEvent extends CurrentEmployeeEvent {
  const LoadInitialEvent();
}

/// 切換到指定 employeeId（從 IdentitySwitcherDialog 觸發）。
class SwitchIdentityEvent extends CurrentEmployeeEvent {
  final String employeeId;
  const SwitchIdentityEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

/// 員工資料異動後刷新候選清單（不變更 current）。
class RefreshCandidatesEvent extends CurrentEmployeeEvent {
  const RefreshCandidatesEvent();
}

/// 清除短暫 SnackBar 訊息。
class DismissMessageEvent extends CurrentEmployeeEvent {
  const DismissMessageEvent();
}
