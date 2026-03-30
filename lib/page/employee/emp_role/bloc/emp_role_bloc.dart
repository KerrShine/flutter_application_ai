import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/emp_role_service.dart';

part 'emp_role_event.dart';
part 'emp_role_state.dart';

class EmpRoleBloc extends Bloc<EmpRoleEvent, EmpRoleState> {
  final EmpRoleService _service;

  EmpRoleBloc(this._service) : super(const EmpRoleState()) {
    on<ConfirmSaveRoleEvent>(_onConfirmSaveRoleEvent);
    on<DismissRoleDialogEvent>(_onDismissRoleDialogEvent);
    on<InitEvent>(_onInitEvent);
    on<NavigationHandledEvent>(_onNavigationHandledEvent);
    on<OpenCreateRoleDialogEvent>(_onOpenCreateRoleDialogEvent);
    on<OpenEmpInfoPageEvent>(_onOpenEmpInfoPageEvent);
    on<OpenEditRoleDialogEvent>(_onOpenEditRoleDialogEvent);
    on<RequestExportJsonEvent>(_onRequestExportJsonEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<EmpRoleState> emit,
  ) async {
    emit(state.copyWith(status: EmpRoleStatus.loading, message: ''));

    final result = await _service.initData();

    if (result.isSuccess) {
      emit(state.copyWith(
        status: EmpRoleStatus.success,
        roles: result.data ?? const [],
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpRoleStatus.failure,
      message: result.error ?? '角色設定初始化失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onConfirmSaveRoleEvent(
    ConfirmSaveRoleEvent event,
    Emitter<EmpRoleState> emit,
  ) async {
    emit(state.copyWith(status: EmpRoleStatus.loading, message: ''));

    final result = await _service.saveRole(
      roleId: event.roleId,
      roleCode: event.roleCode,
      roleName: event.roleName,
      roleType: event.roleType,
      status: event.status,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: EmpRoleStatus.success,
        roles: result.data ?? state.roles,
        roleDialogMode: EmpRoleDialogMode.none,
        dialogRole: const EmpRoleModel(),
        message: '',
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpRoleStatus.failure,
      message: result.error ?? '角色儲存失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onDismissRoleDialogEvent(
    DismissRoleDialogEvent event,
    Emitter<EmpRoleState> emit,
  ) {
    emit(state.copyWith(
      roleDialogMode: EmpRoleDialogMode.none,
      dialogRole: const EmpRoleModel(),
    ));
  }

  void _onNavigationHandledEvent(
    NavigationHandledEvent event,
    Emitter<EmpRoleState> emit,
  ) {
    emit(state.copyWith(navigateRoute: ''));
  }

  void _onOpenCreateRoleDialogEvent(
    OpenCreateRoleDialogEvent event,
    Emitter<EmpRoleState> emit,
  ) {
    emit(state.copyWith(
      roleDialogMode: EmpRoleDialogMode.create,
      dialogRole: const EmpRoleModel(status: 1),
      roleDialogRequestId: state.roleDialogRequestId + 1,
    ));
  }

  void _onOpenEmpInfoPageEvent(
    OpenEmpInfoPageEvent event,
    Emitter<EmpRoleState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.empInfoPage));
  }

  void _onOpenEditRoleDialogEvent(
    OpenEditRoleDialogEvent event,
    Emitter<EmpRoleState> emit,
  ) {
    final role = state.roles.firstWhere(
      (item) => item.roleId == event.roleId,
      orElse: () => const EmpRoleModel(),
    );

    emit(state.copyWith(
      roleDialogMode: EmpRoleDialogMode.edit,
      dialogRole: role,
      roleDialogRequestId: state.roleDialogRequestId + 1,
    ));
  }

  Future<void> _onRequestExportJsonEvent(
    RequestExportJsonEvent event,
    Emitter<EmpRoleState> emit,
  ) async {
    if (state.roles.isEmpty) {
      emit(state.copyWith(
        infoMessage: '目前沒有資料',
        infoDialogRequestId: state.infoDialogRequestId + 1,
        exportJson: '',
      ));
      return;
    }

    final result = await _service.buildExportJson();
    if (result.isSuccess) {
      emit(state.copyWith(
        message: '',
        exportJson: result.data ?? '',
        exportDialogRequestId: state.exportDialogRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpRoleStatus.failure,
      message: result.error ?? '角色 JSON 匯出失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }
}
