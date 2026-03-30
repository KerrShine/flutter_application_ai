import 'dart:convert';

import 'package:flutter_application_ai/model/emp_dep_binding_view_data.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/unit/result.dart';

class EmpDepService {
  final EmpInfoRepository _empInfoRepository;
  final OrgDesignRepository _orgDesignRepository;

  EmpDepService(this._empInfoRepository, this._orgDesignRepository);

  Future<Result<EmpDepBindingViewData>> initData({
    String initialDepartmentId = '',
    String focusedEmployeeId = '',
    String employeeKeyword = '',
  }) async {
    try {
      final departmentsResult = await _loadDepartments();
      if (!departmentsResult.isSuccess) {
        return Result.failure(departmentsResult.error ?? '部門資料讀取失敗');
      }

      final departments = departmentsResult.data ?? const <OrgDepartmentNode>[];
      if (departments.isEmpty) {
        return Result.failure('請先前往設計組織樹');
      }

      final employeesResult = await _loadEmployees();
      if (!employeesResult.isSuccess) {
        return Result.failure(employeesResult.error ?? '職員資料讀取失敗');
      }

      return buildViewData(
        departments: departments,
        employees: employeesResult.data ?? const <EmployeeModel>[],
        initialDepartmentId: initialDepartmentId,
        focusedEmployeeId: focusedEmployeeId,
        employeeKeyword: employeeKeyword,
      );
    } catch (ex) {
      return Result.failure('部門綁定初始化失敗: ${ex.toString()}');
    }
  }

  Result<String> buildExportJson({
    required List<OrgDepartmentNode> departments,
    required List<EmployeeModel> employees,
    String selectedDepartmentId = '',
    String selectedDepartmentDisplayName = '',
  }) {
    try {
      final sortedDepartments = List<OrgDepartmentNode>.from(departments)
        ..sort(
          (left, right) => left.departmentCode.compareTo(right.departmentCode),
        );
      final sortedEmployees = List<EmployeeModel>.from(employees)
        ..sort(
            (left, right) => left.employeeCode.compareTo(right.employeeCode));
      final unboundEmployees = sortedEmployees
          .where((employee) => employee.departmentId.isEmpty)
          .toList();

      final bindings = sortedDepartments.map((department) {
        final members = sortedEmployees
            .where(
                (employee) => employee.departmentId == department.departmentId)
            .toList();

        return {
          'department_id': department.departmentId,
          'department_name': _formatDepartmentDisplayName(department),
          'employee_count': members.length,
          'employees': members.map((employee) => employee.toMap()).toList(),
        };
      }).toList();

      final payload = {
        'module': 'emp_dep',
        'selected_department': {
          'department_id': selectedDepartmentId,
          'department_name': selectedDepartmentDisplayName,
        },
        'summary': {
          'department_total': sortedDepartments.length,
          'employee_total': sortedEmployees.length,
          'bound_employee_total':
              sortedEmployees.length - unboundEmployees.length,
          'unbound_employee_total': unboundEmployees.length,
        },
        'departments':
            sortedDepartments.map((department) => department.toMap()).toList(),
        'employees':
            sortedEmployees.map((employee) => employee.toMap()).toList(),
        'bindings': bindings,
        'unbound_employees':
            unboundEmployees.map((employee) => employee.toMap()).toList(),
      };

      return Result.success(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } catch (ex) {
      return Result.failure('部門綁定 JSON 匯出失敗: ${ex.toString()}');
    }
  }

  Future<Result<EmpDepBindingViewData>> buildViewData({
    required List<OrgDepartmentNode> departments,
    required List<EmployeeModel> employees,
    String initialDepartmentId = '',
    String focusedEmployeeId = '',
    String employeeKeyword = '',
  }) async {
    try {
      final selectedDepartmentId = _resolveSelectedDepartmentId(
        departments: departments,
        employees: employees,
        initialDepartmentId: initialDepartmentId,
        focusedEmployeeId: focusedEmployeeId,
      );

      final selectedDepartment = _findDepartment(
        departments,
        selectedDepartmentId,
      );

      final selectedDepartmentEmployees = List<EmployeeModel>.from(
        employees.where(
          (employee) => employee.departmentId == selectedDepartmentId,
        ),
      )..sort((left, right) => left.employeeCode.compareTo(right.employeeCode));

      final normalizedKeyword = employeeKeyword.trim().toLowerCase();
      final filteredEmployees = List<EmployeeModel>.from(
        employees.where(
          (employee) => normalizedKeyword.isEmpty
              ? true
              : employee.employeeName.toLowerCase().contains(normalizedKeyword),
        ),
      )..sort((left, right) => left.employeeCode.compareTo(right.employeeCode));

      final departmentEmployeeCounts = <String, int>{
        for (final department in departments)
          department.departmentId: employees
              .where((employee) =>
                  employee.departmentId == department.departmentId)
              .length,
      };

      final departmentDisplayNames = <String, String>{
        '': '未綁定',
        for (final department in departments)
          department.departmentId: _formatDepartmentDisplayName(department),
      };

      return Result.success(
        EmpDepBindingViewData(
          departments: departments,
          employees: employees,
          selectedDepartmentId: selectedDepartmentId,
          selectedDepartmentDisplayName:
              _formatDepartmentDisplayName(selectedDepartment),
          focusedEmployeeId: focusedEmployeeId,
          employeeKeyword: employeeKeyword,
          selectedDepartmentEmployees: selectedDepartmentEmployees,
          filteredEmployees: filteredEmployees,
          departmentEmployeeCounts: departmentEmployeeCounts,
          departmentDisplayNames: departmentDisplayNames,
        ),
      );
    } catch (ex) {
      return Result.failure('部門綁定資料整理失敗: ${ex.toString()}');
    }
  }

  Future<Result<EmpDepBindingViewData>> bindEmployeeToDepartment({
    required String employeeId,
    required String departmentId,
    String focusedEmployeeId = '',
    String employeeKeyword = '',
  }) async {
    try {
      if (departmentId.trim().isEmpty) {
        return Result.failure('請先選擇部門');
      }

      final employeesResult = await _loadEmployees();
      if (!employeesResult.isSuccess) {
        return Result.failure(employeesResult.error ?? '職員資料讀取失敗');
      }

      final employees = List<EmployeeModel>.from(
        employeesResult.data ?? const <EmployeeModel>[],
      );
      final employeeIndex = employees.indexWhere(
        (employee) => employee.employeeId == employeeId,
      );

      if (employeeIndex == -1) {
        return Result.failure('找不到指定職員');
      }

      final employee = employees[employeeIndex];
      if (!employee.isActive) {
        return Result.failure('停用職員不可綁定部門');
      }

      if (employee.departmentId.isNotEmpty) {
        return Result.failure('此職員已綁定部門');
      }

      final now = DateTime.now();
      employees[employeeIndex] = employee.copyWith(
        departmentId: departmentId,
        updatedDate: _formatDate(now),
        updatedTime: _formatTime(now),
      );

      final saveResult = await _empInfoRepository.saveAllEmployees(employees);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '部門綁定儲存失敗');
      }

      return initData(
        initialDepartmentId: departmentId,
        focusedEmployeeId:
            focusedEmployeeId.isEmpty ? employeeId : focusedEmployeeId,
        employeeKeyword: employeeKeyword,
      );
    } catch (ex) {
      return Result.failure('部門綁定儲存失敗: ${ex.toString()}');
    }
  }

  Future<Result<EmpDepBindingViewData>> unbindEmployeeFromDepartment({
    required String employeeId,
    required String departmentId,
    String employeeKeyword = '',
  }) async {
    try {
      final employeesResult = await _loadEmployees();
      if (!employeesResult.isSuccess) {
        return Result.failure(employeesResult.error ?? '職員資料讀取失敗');
      }

      final employees = List<EmployeeModel>.from(
        employeesResult.data ?? const <EmployeeModel>[],
      );
      final employeeIndex = employees.indexWhere(
        (employee) => employee.employeeId == employeeId,
      );

      if (employeeIndex == -1) {
        return Result.failure('找不到指定職員');
      }

      final employee = employees[employeeIndex];
      if (employee.departmentId != departmentId) {
        return Result.failure('此職員目前不在所選部門');
      }

      final now = DateTime.now();
      employees[employeeIndex] = employee.copyWith(
        departmentId: '',
        updatedDate: _formatDate(now),
        updatedTime: _formatTime(now),
      );

      final saveResult = await _empInfoRepository.saveAllEmployees(employees);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '移除部門綁定失敗');
      }

      return initData(
        initialDepartmentId: departmentId,
        focusedEmployeeId: employeeId,
        employeeKeyword: employeeKeyword,
      );
    } catch (ex) {
      return Result.failure('移除部門綁定失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<OrgDepartmentNode>>> _loadDepartments() async {
    final configResult = await _orgDesignRepository.loadConfig();
    if (!configResult.isSuccess) {
      return Result.failure(configResult.error ?? '部門資料讀取失敗');
    }

    final departments = List<OrgDepartmentNode>.from(
      configResult.data?.departmentNodes ?? const <OrgDepartmentNode>[],
    )
      ..retainWhere((department) => department.isActive)
      ..sort(
          (left, right) => left.departmentCode.compareTo(right.departmentCode));

    return Result.success(departments);
  }

  Future<Result<List<EmployeeModel>>> _loadEmployees() async {
    final employeesResult = await _empInfoRepository.loadEmployees();
    if (!employeesResult.isSuccess) {
      return Result.failure(employeesResult.error ?? '職員資料讀取失敗');
    }

    final employees = List<EmployeeModel>.from(
      employeesResult.data ?? const <EmployeeModel>[],
    )..sort((left, right) => left.employeeCode.compareTo(right.employeeCode));

    return Result.success(employees);
  }

  String _resolveSelectedDepartmentId({
    required List<OrgDepartmentNode> departments,
    required List<EmployeeModel> employees,
    required String initialDepartmentId,
    required String focusedEmployeeId,
  }) {
    if (initialDepartmentId.isNotEmpty &&
        departments.any(
          (department) => department.departmentId == initialDepartmentId,
        )) {
      return initialDepartmentId;
    }

    final focusedEmployee = _findEmployee(employees, focusedEmployeeId);
    final focusedDepartmentId = focusedEmployee?.departmentId ?? '';
    if (focusedDepartmentId.isNotEmpty &&
        departments.any(
          (department) => department.departmentId == focusedDepartmentId,
        )) {
      return focusedDepartmentId;
    }

    return departments.isEmpty ? '' : departments.first.departmentId;
  }

  OrgDepartmentNode? _findDepartment(
    List<OrgDepartmentNode> departments,
    String departmentId,
  ) {
    for (final department in departments) {
      if (department.departmentId == departmentId) {
        return department;
      }
    }

    return null;
  }

  EmployeeModel? _findEmployee(
    List<EmployeeModel> employees,
    String employeeId,
  ) {
    for (final employee in employees) {
      if (employee.employeeId == employeeId) {
        return employee;
      }
    }

    return null;
  }

  String _formatDepartmentDisplayName(OrgDepartmentNode? department) {
    if (department == null) {
      return '';
    }

    if (department.departmentCode.isEmpty) {
      return department.name;
    }

    return '${department.departmentCode} - ${department.name}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}
