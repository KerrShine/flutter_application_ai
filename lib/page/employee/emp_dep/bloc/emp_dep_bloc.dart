import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/emp_dep_binding_view_data.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/emp_dep_service.dart';

part 'emp_dep_event.dart';
part 'emp_dep_state.dart';

class EmpDepBloc extends Bloc<EmpDepEvent, EmpDepState> {
  final EmpDepService _service;

  EmpDepBloc(this._service) : super(const EmpDepState()) {
    on<BindEmployeeToDepartmentEvent>(_onBindEmployeeToDepartmentEvent);
    on<InitEvent>(_onInitEvent);
    on<NavigationHandledEvent>(_onNavigationHandledEvent);
    on<OpenEmpAgentPageEvent>(_onOpenEmpAgentPageEvent);
    on<RemoveEmployeeFromDepartmentEvent>(_onRemoveEmployeeFromDepartmentEvent);
    on<RequestExportJsonEvent>(_onRequestExportJsonEvent);
    on<SearchEmployeeKeywordChangedEvent>(_onSearchEmployeeKeywordChangedEvent);
    on<SelectEmployeeEvent>(_onSelectEmployeeEvent);
    on<SelectDepartmentEvent>(_onSelectDepartmentEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<EmpDepState> emit,
  ) async {
    emit(state.copyWith(status: EmpDepStatus.loading, message: ''));

    final result = await _service.initData(
      initialDepartmentId: event.initialDepartmentId,
      focusedEmployeeId: event.focusedEmployeeId,
      employeeKeyword: state.employeeKeyword,
    );
    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpDepStatus.failure,
      message: result.error ?? '部門綁定初始化失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onNavigationHandledEvent(
    NavigationHandledEvent event,
    Emitter<EmpDepState> emit,
  ) {
    emit(state.copyWith(navigateRoute: ''));
  }

  void _onOpenEmpAgentPageEvent(
    OpenEmpAgentPageEvent event,
    Emitter<EmpDepState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.empAgentPage));
  }

  Future<void> _onBindEmployeeToDepartmentEvent(
    BindEmployeeToDepartmentEvent event,
    Emitter<EmpDepState> emit,
  ) async {
    final result = await _service.bindEmployeeToDepartment(
      employeeId: event.employeeId,
      departmentId: event.departmentId,
      focusedEmployeeId: event.employeeId,
      employeeKeyword: state.employeeKeyword,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpDepStatus.failure,
      message: result.error ?? '部門綁定儲存失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onRemoveEmployeeFromDepartmentEvent(
    RemoveEmployeeFromDepartmentEvent event,
    Emitter<EmpDepState> emit,
  ) async {
    final result = await _service.unbindEmployeeFromDepartment(
      employeeId: event.employeeId,
      departmentId: event.departmentId,
      employeeKeyword: state.employeeKeyword,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpDepStatus.failure,
      message: result.error ?? '移除部門綁定失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onRequestExportJsonEvent(
    RequestExportJsonEvent event,
    Emitter<EmpDepState> emit,
  ) {
    final result = _service.buildExportJson(
      departments: state.departments,
      employees: state.employees,
      selectedDepartmentId: state.selectedDepartmentId,
      selectedDepartmentDisplayName: state.selectedDepartmentDisplayName,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        exportJson: result.data ?? '',
        exportDialogRequestId: state.exportDialogRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpDepStatus.failure,
      message: result.error ?? '部門綁定 JSON 匯出失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSelectDepartmentEvent(
    SelectDepartmentEvent event,
    Emitter<EmpDepState> emit,
  ) async {
    final result = await _service.buildViewData(
      departments: state.departments,
      employees: state.employees,
      initialDepartmentId: event.departmentId,
      focusedEmployeeId: '',
      employeeKeyword: state.employeeKeyword,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpDepStatus.failure,
      message: result.error ?? '部門資料切換失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSearchEmployeeKeywordChangedEvent(
    SearchEmployeeKeywordChangedEvent event,
    Emitter<EmpDepState> emit,
  ) async {
    final result = await _service.buildViewData(
      departments: state.departments,
      employees: state.employees,
      initialDepartmentId: state.selectedDepartmentId,
      focusedEmployeeId: state.focusedEmployeeId,
      employeeKeyword: event.keyword,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpDepStatus.failure,
      message: result.error ?? '員工篩選失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSelectEmployeeEvent(
    SelectEmployeeEvent event,
    Emitter<EmpDepState> emit,
  ) async {
    final employee = state.employees.where(
      (item) => item.employeeId == event.employeeId,
    );
    final selectedEmployee = employee.isEmpty ? null : employee.first;

    final result = await _service.buildViewData(
      departments: state.departments,
      employees: state.employees,
      initialDepartmentId:
          selectedEmployee == null || selectedEmployee.departmentId.isEmpty
              ? state.selectedDepartmentId
              : selectedEmployee.departmentId,
      focusedEmployeeId: event.employeeId,
      employeeKeyword: state.employeeKeyword,
    );

    if (result.isSuccess) {
      emit(_mergeViewData(state, result.data));
      return;
    }

    emit(state.copyWith(
      status: EmpDepStatus.failure,
      message: result.error ?? '員工定位失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  EmpDepState _mergeViewData(
    EmpDepState currentState,
    EmpDepBindingViewData? viewData,
  ) {
    if (viewData == null) {
      return currentState.copyWith(status: EmpDepStatus.success, message: '');
    }

    return currentState.copyWith(
      status: EmpDepStatus.success,
      message: '',
      departments: viewData.departments,
      employees: viewData.employees,
      selectedDepartmentId: viewData.selectedDepartmentId,
      selectedDepartmentDisplayName: viewData.selectedDepartmentDisplayName,
      focusedEmployeeId: viewData.focusedEmployeeId,
      employeeKeyword: viewData.employeeKeyword,
      selectedDepartmentEmployees: viewData.selectedDepartmentEmployees,
      filteredEmployees: viewData.filteredEmployees,
      departmentEmployeeCounts: viewData.departmentEmployeeCounts,
      departmentDisplayNames: viewData.departmentDisplayNames,
    );
  }
}
