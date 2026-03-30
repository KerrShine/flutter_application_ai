import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';

class EmpDepBindingViewData extends Equatable {
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

  const EmpDepBindingViewData({
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

  @override
  List<Object> get props => [
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
