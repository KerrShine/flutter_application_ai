import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/emp_agent_assignment_model.dart';
import 'package:flutter_application_ai/model/emp_agent_assignment_view_model.dart';
import 'package:flutter_application_ai/model/emp_agent_view_data.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/service/emp_agent_service.dart';

part 'emp_agent_event.dart';
part 'emp_agent_state.dart';

class EmpAgentBloc extends Bloc<EmpAgentEvent, EmpAgentState> {
  final EmpAgentService _service;

  EmpAgentBloc(this._service) : super(const EmpAgentState()) {
    on<DeleteAssignmentEvent>(_onDeleteAssignmentEvent);
    on<InitEvent>(_onInitEvent);
    on<SelectAgentDepartmentEvent>(_onSelectAgentDepartmentEvent);
    on<SelectAgentEmployeeEvent>(_onSelectAgentEmployeeEvent);
    on<SelectPrincipalDepartmentEvent>(_onSelectPrincipalDepartmentEvent);
    on<SelectPrincipalEmployeeEvent>(_onSelectPrincipalEmployeeEvent);
    on<SubmitAssignmentEvent>(_onSubmitAssignmentEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<EmpAgentState> emit,
  ) async {
    emit(state.copyWith(status: EmpAgentStatus.loading, message: ''));

    final result = await _service.initData();
    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpAgentStatus.failure,
      message: result.error ?? '代理人設定初始化失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onDeleteAssignmentEvent(
    DeleteAssignmentEvent event,
    Emitter<EmpAgentState> emit,
  ) async {
    final result = await _service.deleteAssignment(
      assignmentId: event.assignmentId,
      principalDepartmentId: state.principalDepartmentId,
      principalEmployeeId: state.principalEmployeeId,
      agentDepartmentId: state.agentDepartmentId,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpAgentStatus.failure,
      message: result.error ?? '代理資料刪除失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSelectAgentDepartmentEvent(
    SelectAgentDepartmentEvent event,
    Emitter<EmpAgentState> emit,
  ) async {
    final result = await _service.buildViewData(
      departments: state.departments,
      employees: state.employees,
      assignments: state.assignments,
      principalDepartmentId: state.principalDepartmentId,
      principalEmployeeId: state.principalEmployeeId,
      agentDepartmentId: event.departmentId,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpAgentStatus.failure,
      message: result.error ?? '代理人部門切換失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSelectAgentEmployeeEvent(
    SelectAgentEmployeeEvent event,
    Emitter<EmpAgentState> emit,
  ) async {
    final result = await _service.buildViewData(
      departments: state.departments,
      employees: state.employees,
      assignments: state.assignments,
      principalDepartmentId: state.principalDepartmentId,
      principalEmployeeId: state.principalEmployeeId,
      agentDepartmentId: state.agentDepartmentId,
      agentEmployeeId: event.employeeId,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpAgentStatus.failure,
      message: result.error ?? '代理人選擇失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSelectPrincipalDepartmentEvent(
    SelectPrincipalDepartmentEvent event,
    Emitter<EmpAgentState> emit,
  ) async {
    final result = await _service.buildViewData(
      departments: state.departments,
      employees: state.employees,
      assignments: state.assignments,
      principalDepartmentId: event.departmentId,
      agentDepartmentId: event.departmentId,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpAgentStatus.failure,
      message: result.error ?? '被代理部門切換失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSelectPrincipalEmployeeEvent(
    SelectPrincipalEmployeeEvent event,
    Emitter<EmpAgentState> emit,
  ) async {
    final result = await _service.buildViewData(
      departments: state.departments,
      employees: state.employees,
      assignments: state.assignments,
      principalDepartmentId: state.principalDepartmentId,
      principalEmployeeId: event.employeeId,
      agentDepartmentId: state.agentDepartmentId,
      agentEmployeeId: state.agentEmployeeId,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpAgentStatus.failure,
      message: result.error ?? '被代理員工選擇失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSubmitAssignmentEvent(
    SubmitAssignmentEvent event,
    Emitter<EmpAgentState> emit,
  ) async {
    emit(state.copyWith(status: EmpAgentStatus.loading, message: ''));

    final result = await _service.createAssignment(
      principalDepartmentId: state.principalDepartmentId,
      principalEmployeeId: state.principalEmployeeId,
      agentDepartmentId: state.agentDepartmentId,
      agentEmployeeId: state.agentEmployeeId,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: EmpAgentStatus.success,
        message: '代理人設定已新增',
        messageRequestId: state.messageRequestId + 1,
      ));
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpAgentStatus.failure,
      message: result.error ?? '代理人設定儲存失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  EmpAgentState _mergeViewData(
    EmpAgentState currentState,
    EmpAgentViewData? viewData,
  ) {
    if (viewData == null) {
      return currentState.copyWith(status: EmpAgentStatus.success, message: '');
    }

    return currentState.copyWith(
      status: EmpAgentStatus.success,
      message: '',
      departments: viewData.departments,
      employees: viewData.employees,
      assignments: viewData.assignments,
      principalDepartmentId: viewData.principalDepartmentId,
      principalEmployees: viewData.principalEmployees,
      principalEmployeeId: viewData.principalEmployeeId,
      selectedPrincipalEmployee: viewData.selectedPrincipalEmployee,
      agentDepartmentId: viewData.agentDepartmentId,
      agentCandidates: viewData.agentCandidates,
      agentEmployeeId: viewData.agentEmployeeId,
      selectedAgentEmployee: viewData.selectedAgentEmployee,
      assignmentRows: viewData.assignmentRows,
    );
  }
}
