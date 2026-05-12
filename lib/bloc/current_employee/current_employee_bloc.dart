import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/service/identity_service.dart';

part 'current_employee_event.dart';
part 'current_employee_state.dart';

/// 全域「目前登入身分」狀態管理。
///
/// 由 home shell 層級 BlocProvider 提供，登入後所有 child route 共用。
/// 切換 employeeId 時自動寫入 LocalStorage（透過 `IdentityService`），
/// 重啟仍保留。
class CurrentEmployeeBloc
    extends Bloc<CurrentEmployeeEvent, CurrentEmployeeState> {
  final IdentityService _identityService;

  CurrentEmployeeBloc(this._identityService)
      : super(const CurrentEmployeeState()) {
    on<LoadInitialEvent>(_onLoadInitial);
    on<SwitchIdentityEvent>(_onSwitchIdentity);
    on<RefreshCandidatesEvent>(_onRefreshCandidates);
    on<DismissMessageEvent>(_onDismissMessage);
  }

  Future<void> _onLoadInitial(
    LoadInitialEvent event,
    Emitter<CurrentEmployeeState> emit,
  ) async {
    emit(state.copyWith(status: CurrentEmployeeStatus.loading, message: ''));
    final result = await _identityService.loadInitial();
    if (result.isSuccess) {
      final data = result.data!;
      emit(state.copyWith(
        status: CurrentEmployeeStatus.ready,
        current: data.current ?? const EmployeeModel(),
        candidates: data.candidates,
        departmentNames: data.departmentNames,
      ));
      return;
    }
    emit(state.copyWith(
      status: CurrentEmployeeStatus.failure,
      message: result.error ?? '身分載入失敗',
    ));
  }

  Future<void> _onSwitchIdentity(
    SwitchIdentityEvent event,
    Emitter<CurrentEmployeeState> emit,
  ) async {
    final result = await _identityService.switchTo(event.employeeId);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: CurrentEmployeeStatus.ready,
        current: result.data!,
        message: '已切換為 ${result.data!.employeeName}',
      ));
      return;
    }
    emit(state.copyWith(
      status: CurrentEmployeeStatus.failure,
      message: result.error ?? '切換失敗',
    ));
  }

  Future<void> _onRefreshCandidates(
    RefreshCandidatesEvent event,
    Emitter<CurrentEmployeeState> emit,
  ) async {
    final result = await _identityService.reloadCandidates();
    if (result.isSuccess) {
      emit(state.copyWith(candidates: result.data ?? const []));
    }
  }

  void _onDismissMessage(
    DismissMessageEvent event,
    Emitter<CurrentEmployeeState> emit,
  ) {
    emit(state.copyWith(message: ''));
  }
}
