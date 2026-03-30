import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/emp_manager_service.dart';

part 'emp_manager_event.dart';
part 'emp_manager_state.dart';

class EmpManagerBloc extends Bloc<EmpManagerEvent, EmpManagerState> {
  final EmpManagerService _service;

  EmpManagerBloc(this._service) : super(const EmpManagerState()) {
    on<InitEvent>(_onInitEvent);
    on<NavigationHandledEvent>(_onNavigationHandledEvent);
    on<OpenEmpAgentPageEvent>(_onOpenEmpAgentPageEvent);
    on<OpenEmpDepPageEvent>(_onOpenEmpDepPageEvent);
    on<OpenEmpInfoPageEvent>(_onOpenEmpInfoPageEvent);
    on<OpenEmpRolePageEvent>(_onOpenEmpRolePageEvent);
    on<OpenGuidePageEvent>(_onOpenGuidePageEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<EmpManagerState> emit,
  ) async {
    emit(state.copyWith(status: EmpManagerStatus.loading));

    final result = await _service.initData();

    if (result.isSuccess) {
      emit(state.copyWith(status: EmpManagerStatus.success));
      return;
    }

    emit(state.copyWith(
      status: EmpManagerStatus.failure,
      message: result.error ?? '初始化失敗',
    ));
  }

  void _onNavigationHandledEvent(
    NavigationHandledEvent event,
    Emitter<EmpManagerState> emit,
  ) {
    emit(state.copyWith(navigateRoute: ''));
  }

  void _onOpenGuidePageEvent(
    OpenGuidePageEvent event,
    Emitter<EmpManagerState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.empManagerGuidePage));
  }

  void _onOpenEmpAgentPageEvent(
    OpenEmpAgentPageEvent event,
    Emitter<EmpManagerState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.empAgentPage));
  }

  void _onOpenEmpInfoPageEvent(
    OpenEmpInfoPageEvent event,
    Emitter<EmpManagerState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.empInfoPage));
  }

  void _onOpenEmpDepPageEvent(
    OpenEmpDepPageEvent event,
    Emitter<EmpManagerState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.empDepPage));
  }

  void _onOpenEmpRolePageEvent(
    OpenEmpRolePageEvent event,
    Emitter<EmpManagerState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.empRolePage));
  }
}
