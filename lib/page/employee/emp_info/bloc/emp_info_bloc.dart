import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/unit/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/emp_info_service.dart';

part 'emp_info_event.dart';
part 'emp_info_state.dart';

class EmpInfoBloc extends Bloc<EmpInfoEvent, EmpInfoState> {
  final EmpInfoService _service;

  EmpInfoBloc(this._service) : super(const EmpInfoState()) {
    on<ConfirmDeleteEmployeeEvent>(_onConfirmDeleteEmployeeEvent);
    on<ConfirmSaveEmployeeEvent>(_onConfirmSaveEmployeeEvent);
    on<DismissDeleteEmployeeDialogEvent>(_onDismissDeleteEmployeeDialogEvent);
    on<DismissEmployeeDialogEvent>(_onDismissEmployeeDialogEvent);
    on<InitEvent>(_onInitEvent);
    on<NavigationHandledEvent>(_onNavigationHandledEvent);
    on<OpenCreateEmployeeDialogEvent>(_onOpenCreateEmployeeDialogEvent);
    on<OpenDeleteEmployeeDialogEvent>(_onOpenDeleteEmployeeDialogEvent);
    on<OpenEmployeeDepartmentBindingPageEvent>(
      _onOpenEmployeeDepartmentBindingPageEvent,
    );
    on<OpenEmpDepPageEvent>(_onOpenEmpDepPageEvent);
    on<OpenEditEmployeeDialogEvent>(_onOpenEditEmployeeDialogEvent);
    on<SearchKeywordChangedEvent>(_onSearchKeywordChangedEvent);
    on<RequestExportJsonEvent>(_onRequestExportJsonEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<EmpInfoState> emit,
  ) async {
    emit(state.copyWith(status: EmpInfoStatus.loading, message: ''));

    final result = await _service.initData();
    final departmentsResult = await _service.loadDepartments();
    final rolesResult = await _service.loadRoles();

    if (result.isSuccess) {
      final employees = result.data ?? const <EmployeeModel>[];
      emit(state.copyWith(
        status: EmpInfoStatus.success,
        departments: departmentsResult.data ?? state.departments,
        roles: rolesResult.data ?? state.roles,
        employees: employees,
        filteredEmployees: employees,
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpInfoStatus.failure,
      message: result.error ?? '職員資料初始化失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onConfirmSaveEmployeeEvent(
    ConfirmSaveEmployeeEvent event,
    Emitter<EmpInfoState> emit,
  ) async {
    emit(state.copyWith(status: EmpInfoStatus.loading, message: ''));

    final result = await _service.saveEmployee(
      employeeId: event.employeeId,
      employeeCode: event.employeeCode,
      employeeName: event.employeeName,
      account: event.account,
      departmentId: event.departmentId,
      roleId: event.roleId,
      status: event.status,
      hireDate: event.hireDate,
      leaveDate: event.leaveDate,
    );

    if (result.isSuccess) {
      final employees = result.data ?? const <EmployeeModel>[];
      final filteredResult = await _service.filterEmployees(
        keyword: state.keyword,
        employees: employees,
      );

      emit(state.copyWith(
        status: EmpInfoStatus.success,
        message: '',
        employees: employees,
        filteredEmployees: filteredResult.data ?? employees,
        deleteTargetEmployee: const EmployeeModel(),
        dialogMode: EmpInfoDialogMode.none,
        dialogEmployee: const EmployeeModel(),
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpInfoStatus.failure,
      message: result.error ?? '職員資料儲存失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onConfirmDeleteEmployeeEvent(
    ConfirmDeleteEmployeeEvent event,
    Emitter<EmpInfoState> emit,
  ) async {
    emit(state.copyWith(status: EmpInfoStatus.loading, message: ''));

    final result = await _service.deleteEmployee(event.employeeId);
    if (result.isSuccess) {
      final employees = result.data ?? const <EmployeeModel>[];
      final filteredResult = await _service.filterEmployees(
        keyword: state.keyword,
        employees: employees,
      );

      emit(state.copyWith(
        status: EmpInfoStatus.success,
        message: '',
        employees: employees,
        filteredEmployees: filteredResult.data ?? employees,
        deleteTargetEmployee: const EmployeeModel(),
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpInfoStatus.failure,
      message: result.error ?? '職員資料刪除失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onDismissDeleteEmployeeDialogEvent(
    DismissDeleteEmployeeDialogEvent event,
    Emitter<EmpInfoState> emit,
  ) {
    emit(state.copyWith(deleteTargetEmployee: const EmployeeModel()));
  }

  void _onDismissEmployeeDialogEvent(
    DismissEmployeeDialogEvent event,
    Emitter<EmpInfoState> emit,
  ) {
    emit(state.copyWith(
      dialogMode: EmpInfoDialogMode.none,
      dialogEmployee: const EmployeeModel(),
    ));
  }

  void _onNavigationHandledEvent(
    NavigationHandledEvent event,
    Emitter<EmpInfoState> emit,
  ) {
    emit(state.copyWith(navigateRoute: ''));
  }

  void _onOpenCreateEmployeeDialogEvent(
    OpenCreateEmployeeDialogEvent event,
    Emitter<EmpInfoState> emit,
  ) async {
    final departmentsResult = await _service.loadDepartments();
    final rolesResult = await _service.loadRoles();
    if (!departmentsResult.isSuccess) {
      emit(state.copyWith(
        status: EmpInfoStatus.failure,
        message: departmentsResult.error ?? '部門資料讀取失敗',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    if (!rolesResult.isSuccess) {
      emit(state.copyWith(
        status: EmpInfoStatus.failure,
        message: rolesResult.error ?? '角色資料讀取失敗',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    final departments = departmentsResult.data ?? const <OrgDepartmentNode>[];
    final roles = rolesResult.data ?? const <EmpRoleModel>[];
    if (roles.isEmpty) {
      emit(state.copyWith(
        status: EmpInfoStatus.failure,
        message: '需要先定義角色，才可新增職員。',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      departments: departments,
      roles: roles,
      dialogMode: EmpInfoDialogMode.create,
      dialogEmployee: const EmployeeModel(status: 1),
      employeeDialogRequestId: state.employeeDialogRequestId + 1,
    ));
  }

  void _onOpenEmployeeDepartmentBindingPageEvent(
    OpenEmployeeDepartmentBindingPageEvent event,
    Emitter<EmpInfoState> emit,
  ) {
    final queryParameters = <String, String>{
      'employeeId': event.employeeId,
    };
    if (event.departmentId.isNotEmpty) {
      queryParameters['departmentId'] = event.departmentId;
    }

    emit(state.copyWith(
      navigateRoute: Uri(
        path: RouteName.empDepPage,
        queryParameters: queryParameters,
      ).toString(),
    ));
  }

  void _onOpenEmpDepPageEvent(
    OpenEmpDepPageEvent event,
    Emitter<EmpInfoState> emit,
  ) {
    emit(state.copyWith(navigateRoute: RouteName.empDepPage));
  }

  Future<void> _onOpenEditEmployeeDialogEvent(
    OpenEditEmployeeDialogEvent event,
    Emitter<EmpInfoState> emit,
  ) async {
    final departmentsResult = state.departments.isNotEmpty
        ? Result.success(state.departments)
        : await _service.loadDepartments();

    if (!departmentsResult.isSuccess) {
      emit(state.copyWith(
        status: EmpInfoStatus.failure,
        message: departmentsResult.error ?? '部門資料讀取失敗',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    final rolesResult = state.roles.isNotEmpty
        ? Result.success(state.roles)
        : await _service.loadRoles();

    if (!rolesResult.isSuccess) {
      emit(state.copyWith(
        status: EmpInfoStatus.failure,
        message: rolesResult.error ?? '角色資料讀取失敗',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    final departments = departmentsResult.data ?? const <OrgDepartmentNode>[];
    final roles = rolesResult.data ?? const <EmpRoleModel>[];
    if (roles.isEmpty) {
      emit(state.copyWith(
        status: EmpInfoStatus.failure,
        message: '需要先定義角色，才可編輯職員。',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    final employee = state.employees.firstWhere(
      (item) => item.employeeId == event.employeeId,
      orElse: () => const EmployeeModel(),
    );

    emit(state.copyWith(
      departments: departments,
      roles: roles,
      dialogMode: EmpInfoDialogMode.edit,
      dialogEmployee: employee,
      employeeDialogRequestId: state.employeeDialogRequestId + 1,
    ));
  }

  void _onOpenDeleteEmployeeDialogEvent(
    OpenDeleteEmployeeDialogEvent event,
    Emitter<EmpInfoState> emit,
  ) {
    final employee = state.employees.firstWhere(
      (item) => item.employeeId == event.employeeId,
      orElse: () => const EmployeeModel(),
    );

    emit(state.copyWith(
      deleteTargetEmployee: employee,
      deleteDialogRequestId: state.deleteDialogRequestId + 1,
    ));
  }

  Future<void> _onRequestExportJsonEvent(
    RequestExportJsonEvent event,
    Emitter<EmpInfoState> emit,
  ) async {
    if (state.employees.isEmpty) {
      emit(state.copyWith(
        message: '目前沒有資料',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    final result = await _service.buildExportJson();
    if (result.isSuccess) {
      emit(state.copyWith(
        exportJson: result.data ?? '',
        exportDialogRequestId: state.exportDialogRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpInfoStatus.failure,
      message: result.error ?? '職員 JSON 匯出失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onSearchKeywordChangedEvent(
    SearchKeywordChangedEvent event,
    Emitter<EmpInfoState> emit,
  ) async {
    final result = await _service.filterEmployees(
      keyword: event.keyword,
      employees: state.employees,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        keyword: event.keyword,
        filteredEmployees: result.data ?? state.employees,
      ));
      return;
    }

    emit(state.copyWith(
      status: EmpInfoStatus.failure,
      message: result.error ?? '職員資料篩選失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }
}
