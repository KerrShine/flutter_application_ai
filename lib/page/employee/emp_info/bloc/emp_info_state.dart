part of 'emp_info_bloc.dart';

enum EmpInfoStatus {
  init,
  loading,
  success,
  failure,
}

enum EmpInfoDialogMode {
  none,
  create,
  edit,
}

class EmpInfoState extends Equatable {
  final EmpInfoStatus status;
  final String message;
  final int messageRequestId;
  final String navigateRoute;
  final List<OrgDepartmentNode> departments;
  final List<EmpRoleModel> roles;
  final List<EmployeeModel> employees;
  final List<EmployeeModel> filteredEmployees;
  final String keyword;
  final EmpInfoDialogMode dialogMode;
  final EmployeeModel dialogEmployee;
  final int employeeDialogRequestId;
  final EmployeeModel deleteTargetEmployee;
  final int deleteDialogRequestId;

  const EmpInfoState({
    this.status = EmpInfoStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.navigateRoute = '',
    this.departments = const [],
    this.roles = const [],
    this.employees = const [],
    this.filteredEmployees = const [],
    this.keyword = '',
    this.dialogMode = EmpInfoDialogMode.none,
    this.dialogEmployee = const EmployeeModel(),
    this.employeeDialogRequestId = 0,
    this.deleteTargetEmployee = const EmployeeModel(),
    this.deleteDialogRequestId = 0,
  });

  bool get isEditDialog => dialogMode == EmpInfoDialogMode.edit;

  EmpInfoState copyWith({
    EmpInfoStatus? status,
    String? message,
    int? messageRequestId,
    String? navigateRoute,
    List<OrgDepartmentNode>? departments,
    List<EmpRoleModel>? roles,
    List<EmployeeModel>? employees,
    List<EmployeeModel>? filteredEmployees,
    String? keyword,
    EmpInfoDialogMode? dialogMode,
    EmployeeModel? dialogEmployee,
    int? employeeDialogRequestId,
    EmployeeModel? deleteTargetEmployee,
    int? deleteDialogRequestId,
  }) {
    return EmpInfoState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      navigateRoute: navigateRoute ?? this.navigateRoute,
      departments: departments ?? this.departments,
      roles: roles ?? this.roles,
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      keyword: keyword ?? this.keyword,
      dialogMode: dialogMode ?? this.dialogMode,
      dialogEmployee: dialogEmployee ?? this.dialogEmployee,
      employeeDialogRequestId:
          employeeDialogRequestId ?? this.employeeDialogRequestId,
      deleteTargetEmployee: deleteTargetEmployee ?? this.deleteTargetEmployee,
      deleteDialogRequestId:
          deleteDialogRequestId ?? this.deleteDialogRequestId,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        messageRequestId,
        navigateRoute,
        departments,
        roles,
        employees,
        filteredEmployees,
        keyword,
        dialogMode,
        dialogEmployee,
        employeeDialogRequestId,
        deleteTargetEmployee,
        deleteDialogRequestId,
      ];
}
