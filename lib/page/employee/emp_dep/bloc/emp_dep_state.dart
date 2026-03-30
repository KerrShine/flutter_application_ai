part of 'emp_dep_bloc.dart';

enum EmpDepStatus {
  init,
  loading,
  success,
  failure,
}

class EmpDepState extends Equatable {
  final EmpDepStatus status;
  final String message;
  final int messageRequestId;
  final String exportJson;
  final int exportDialogRequestId;
  final String navigateRoute;
  final List<OrgDepartmentNode> departments;
  final List<EmployeeModel> employees;
  final String selectedDepartmentId;
  final String selectedDepartmentDisplayName;
  final String focusedEmployeeId;
  final String employeeKeyword;
  final List<EmployeeModel> selectedDepartmentEmployees;
  final List<EmployeeModel> filteredEmployees;
  final Map<String, int> departmentEmployeeCounts;
  final Map<String, String> departmentDisplayNames;

  const EmpDepState({
    this.status = EmpDepStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.exportJson = '',
    this.exportDialogRequestId = 0,
    this.navigateRoute = '',
    this.departments = const [],
    this.employees = const [],
    this.selectedDepartmentId = '',
    this.selectedDepartmentDisplayName = '',
    this.focusedEmployeeId = '',
    this.employeeKeyword = '',
    this.selectedDepartmentEmployees = const [],
    this.filteredEmployees = const [],
    this.departmentEmployeeCounts = const {},
    this.departmentDisplayNames = const {},
  });

  bool get hasDepartments => departments.isNotEmpty;

  EmpDepState copyWith({
    EmpDepStatus? status,
    String? message,
    int? messageRequestId,
    String? exportJson,
    int? exportDialogRequestId,
    String? navigateRoute,
    List<OrgDepartmentNode>? departments,
    List<EmployeeModel>? employees,
    String? selectedDepartmentId,
    String? selectedDepartmentDisplayName,
    String? focusedEmployeeId,
    String? employeeKeyword,
    List<EmployeeModel>? selectedDepartmentEmployees,
    List<EmployeeModel>? filteredEmployees,
    Map<String, int>? departmentEmployeeCounts,
    Map<String, String>? departmentDisplayNames,
  }) {
    return EmpDepState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
      navigateRoute: navigateRoute ?? this.navigateRoute,
      departments: departments ?? this.departments,
      employees: employees ?? this.employees,
      selectedDepartmentId: selectedDepartmentId ?? this.selectedDepartmentId,
      selectedDepartmentDisplayName:
          selectedDepartmentDisplayName ?? this.selectedDepartmentDisplayName,
      focusedEmployeeId: focusedEmployeeId ?? this.focusedEmployeeId,
      employeeKeyword: employeeKeyword ?? this.employeeKeyword,
      selectedDepartmentEmployees:
          selectedDepartmentEmployees ?? this.selectedDepartmentEmployees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      departmentEmployeeCounts:
          departmentEmployeeCounts ?? this.departmentEmployeeCounts,
      departmentDisplayNames:
          departmentDisplayNames ?? this.departmentDisplayNames,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        messageRequestId,
        exportJson,
        exportDialogRequestId,
        navigateRoute,
        departments,
        employees,
        selectedDepartmentId,
        selectedDepartmentDisplayName,
        focusedEmployeeId,
        employeeKeyword,
        selectedDepartmentEmployees,
        filteredEmployees,
        departmentEmployeeCounts,
        departmentDisplayNames,
      ];
}
