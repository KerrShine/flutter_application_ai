part of 'current_employee_bloc.dart';

enum CurrentEmployeeStatus { initial, loading, ready, failure }

class CurrentEmployeeState extends Equatable {
  final CurrentEmployeeStatus status;
  final EmployeeModel current;
  final List<EmployeeModel> candidates;
  final Map<String, String> departmentNames;
  final String message;

  const CurrentEmployeeState({
    this.status = CurrentEmployeeStatus.initial,
    this.current = const EmployeeModel(),
    this.candidates = const [],
    this.departmentNames = const {},
    this.message = '',
  });

  /// 取部門名稱；找不到 fallback 為原 ID 字串。
  String departmentNameOf(String departmentId) {
    if (departmentId.isEmpty) return '';
    return departmentNames[departmentId] ?? departmentId;
  }

  /// 是否已成功載入身分（current 非空 model）。
  bool get hasIdentity => current.employeeId.isNotEmpty;

  /// 候選列表為空（系統內無員工）。UI 應顯示引導。
  bool get hasNoCandidates => candidates.isEmpty;

  /// 顯示用：身分標題（姓名 + 角色）。
  String get displayTitle {
    if (!hasIdentity) return '尚未設定身分';
    if (current.roleName.isEmpty) return current.employeeName;
    return '${current.employeeName} · ${current.roleName}';
  }

  /// 顯示用：身分 sub-title（部門名稱 + 在職狀態）。
  String get displaySubtitle {
    if (!hasIdentity) return '請先建立員工資料';
    final deptName = current.departmentId.isEmpty
        ? '未綁部門'
        : departmentNameOf(current.departmentId);
    final activeTag = current.isActive ? '在職' : '停用';
    return '$deptName · $activeTag';
  }

  CurrentEmployeeState copyWith({
    CurrentEmployeeStatus? status,
    EmployeeModel? current,
    List<EmployeeModel>? candidates,
    Map<String, String>? departmentNames,
    String? message,
  }) {
    return CurrentEmployeeState(
      status: status ?? this.status,
      current: current ?? this.current,
      candidates: candidates ?? this.candidates,
      departmentNames: departmentNames ?? this.departmentNames,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [status, current, candidates, departmentNames, message];
}
