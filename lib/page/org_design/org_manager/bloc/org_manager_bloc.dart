import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/service/org_design_service.dart';
import 'package:flutter_application_ai/route/app_router.dart';

part 'org_manager_event.dart';
part 'org_manager_state.dart';

class OrgManagerBloc extends Bloc<OrgManagerEvent, OrgManagerState> {
  final OrgDesignService _service;

  OrgManagerBloc(this._service) : super(const OrgManagerState()) {
    on<InitEvent>(_onInitEvent);
    on<NavigateToOrgDesignConfigEvent>(_onNavigateToOrgDesignConfigEvent);
    on<NavigateToOrgTreeDesignEvent>(_onNavigateToOrgTreeDesignEvent);
    on<RequestDeleteOrganizationEvent>(_onRequestDeleteOrganizationEvent);
    on<ConfirmDeleteOrganizationEvent>(_onConfirmDeleteOrganizationEvent);
    on<DismissDeleteOrganizationDialogEvent>(
      _onDismissDeleteOrganizationDialogEvent,
    );
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<OrgManagerState> emit,
  ) async {
    emit(state.copyWith(status: OrgManagerStatus.loading, message: ''));

    final initResult = await _service.initData();

    if (!initResult.isSuccess) {
      emit(state.copyWith(
        status: OrgManagerStatus.failure,
        message: initResult.error ?? '初始化失敗',
      ));
      return;
    }

    final loadResult = await _service.loadConfig();
    if (!loadResult.isSuccess || loadResult.data == null) {
      emit(state.copyWith(
        status: OrgManagerStatus.failure,
        message: loadResult.error ?? '讀取組織設定失敗',
      ));
      return;
    }

    final config = loadResult.data!;
    emit(state.copyWith(
      status: OrgManagerStatus.success,
      orgName: config.orgName.trim().isEmpty
          ? OrgManagerState.defaultOrgName
          : config.orgName.trim(),
      departmentCount: config.departmentNodes.length,
      updatedAt: config.updatedAt,
      pendingDeleteOrgName: '',
    ));
  }

  void _onNavigateToOrgDesignConfigEvent(
    NavigateToOrgDesignConfigEvent event,
    Emitter<OrgManagerState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.orgDesignConfigPage));
    emit(state.copyWith(clearNavigateRoute: true));
  }

  void _onNavigateToOrgTreeDesignEvent(
    NavigateToOrgTreeDesignEvent event,
    Emitter<OrgManagerState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.orgTreeDesignPage));
    emit(state.copyWith(clearNavigateRoute: true));
  }

  void _onRequestDeleteOrganizationEvent(
    RequestDeleteOrganizationEvent event,
    Emitter<OrgManagerState> emit,
  ) {
    if (!state.hasOrganization) {
      return;
    }

    emit(state.copyWith(
      pendingDeleteOrgName: state.orgName,
      deleteDialogRequestId: state.deleteDialogRequestId + 1,
    ));
  }

  Future<void> _onConfirmDeleteOrganizationEvent(
    ConfirmDeleteOrganizationEvent event,
    Emitter<OrgManagerState> emit,
  ) async {
    emit(state.copyWith(status: OrgManagerStatus.loading, message: ''));

    final result = await _service.deleteOrganization();
    if (!result.isSuccess || result.data == null) {
      emit(state.copyWith(
        status: OrgManagerStatus.failure,
        message: result.error ?? '刪除組織失敗',
      ));
      return;
    }

    emit(state.copyWith(
      status: OrgManagerStatus.success,
      message: '',
      orgName: result.data!.orgName.trim().isEmpty
          ? OrgManagerState.defaultOrgName
          : result.data!.orgName.trim(),
      departmentCount: result.data!.departmentNodes.length,
      updatedAt: result.data!.updatedAt,
      pendingDeleteOrgName: '',
    ));
  }

  void _onDismissDeleteOrganizationDialogEvent(
    DismissDeleteOrganizationDialogEvent event,
    Emitter<OrgManagerState> emit,
  ) {
    emit(state.copyWith(pendingDeleteOrgName: ''));
  }
}
