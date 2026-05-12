import 'dart:convert';

import 'package:flutter_application_ai/model/emp_agent_assignment_model.dart';
import 'package:flutter_application_ai/model/emp_agent_assignment_view_model.dart';
import 'package:flutter_application_ai/model/emp_agent_view_data.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/repositories/interface/emp_agent_repository.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class EmpAgentService {
  final EmpAgentRepository _repository;
  final EmpInfoRepository _empInfoRepository;
  final OrgDesignRepository _orgDesignRepository;

  EmpAgentService(
    this._repository,
    this._empInfoRepository,
    this._orgDesignRepository,
  );

  Future<Result<EmpAgentViewData>> initData() async {
    try {
      final sourceResult = await _loadSourceData();
      if (!sourceResult.isSuccess || sourceResult.data == null) {
        return Result.failure(sourceResult.error ?? '代理資料初始化失敗');
      }

      final source = sourceResult.data!;
      final firstDepartmentId = source.departments.isNotEmpty
          ? source.departments.first.departmentId
          : '';

      return buildViewData(
        departments: source.departments,
        employees: source.employees,
        assignments: source.assignments,
        principalDepartmentId: firstDepartmentId,
        agentDepartmentId: firstDepartmentId,
      );
    } catch (ex) {
      return Result.failure('代理人設定初始化失敗: ${ex.toString()}');
    }
  }

  Future<Result<EmpAgentViewData>> buildViewData({
    required List<OrgDepartmentNode> departments,
    required List<EmployeeModel> employees,
    required List<EmpAgentAssignmentModel> assignments,
    String principalDepartmentId = '',
    String principalEmployeeId = '',
    String agentDepartmentId = '',
    String agentEmployeeId = '',
  }) async {
    try {
      final sortedDepartments = List<OrgDepartmentNode>.from(departments)
        ..retainWhere((item) => item.isActive)
        ..sort(
          (left, right) => left.departmentCode.compareTo(right.departmentCode),
        );
      final sortedEmployees = List<EmployeeModel>.from(employees)
        ..sort(
            (left, right) => left.employeeCode.compareTo(right.employeeCode));
      final sortedAssignments = List<EmpAgentAssignmentModel>.from(assignments)
        ..sort((left, right) {
          final principalCompare = left.principalDepartmentId.compareTo(
            right.principalDepartmentId,
          );
          if (principalCompare != 0) {
            return principalCompare;
          }

          final employeeCompare = left.principalEmployeeId.compareTo(
            right.principalEmployeeId,
          );
          if (employeeCompare != 0) {
            return employeeCompare;
          }

          final updatedDateCompare = right.updatedDate.compareTo(
            left.updatedDate,
          );
          if (updatedDateCompare != 0) {
            return updatedDateCompare;
          }

          return right.updatedTime.compareTo(left.updatedTime);
        });

      final resolvedPrincipalDepartmentId = _resolveDepartmentId(
        departments: sortedDepartments,
        departmentId: principalDepartmentId,
      );
      final principalEmployees = sortedEmployees
          .where(
            (item) =>
                item.departmentId == resolvedPrincipalDepartmentId &&
                item.isActive &&
                item.hireDate.isNotEmpty,
          )
          .toList();
      final resolvedPrincipalEmployeeId = _resolveEmployeeId(
        employees: principalEmployees,
        employeeId: principalEmployeeId,
      );
      final selectedPrincipalEmployee = _findEmployee(
        employees: sortedEmployees,
        employeeId: resolvedPrincipalEmployeeId,
      );

      final fallbackAgentDepartmentId = resolvedPrincipalDepartmentId;
      final resolvedAgentDepartmentId = _resolveDepartmentId(
        departments: sortedDepartments,
        departmentId: agentDepartmentId.isEmpty
            ? fallbackAgentDepartmentId
            : agentDepartmentId,
      );
      final agentCandidates = sortedEmployees
          .where(
            (item) =>
                item.departmentId == resolvedAgentDepartmentId &&
                item.isActive &&
                item.hireDate.isNotEmpty,
          )
          .toList();
      final resolvedAgentEmployeeId = _resolveEmployeeId(
        employees: agentCandidates,
        employeeId: agentEmployeeId,
      );
      final selectedAgentEmployee = _findEmployee(
        employees: sortedEmployees,
        employeeId: resolvedAgentEmployeeId,
      );

      return Result.success(
        EmpAgentViewData(
          departments: sortedDepartments,
          employees: sortedEmployees,
          assignments: sortedAssignments,
          principalDepartmentId: resolvedPrincipalDepartmentId,
          principalEmployees: principalEmployees,
          principalEmployeeId: resolvedPrincipalEmployeeId,
          selectedPrincipalEmployee: selectedPrincipalEmployee,
          agentDepartmentId: resolvedAgentDepartmentId,
          agentCandidates: agentCandidates,
          agentEmployeeId: resolvedAgentEmployeeId,
          selectedAgentEmployee: selectedAgentEmployee,
          assignmentRows: _buildAssignmentRows(
            assignments: sortedAssignments,
            departments: sortedDepartments,
            employees: sortedEmployees,
            principalEmployeeId: resolvedPrincipalEmployeeId,
          ),
        ),
      );
    } catch (ex) {
      return Result.failure('代理資料整理失敗: ${ex.toString()}');
    }
  }

  Future<Result<EmpAgentViewData>> createAssignment({
    required String principalDepartmentId,
    required String principalEmployeeId,
    required String agentDepartmentId,
    required String agentEmployeeId,
  }) async {
    try {
      final sourceResult = await _loadSourceData();
      if (!sourceResult.isSuccess || sourceResult.data == null) {
        return Result.failure(sourceResult.error ?? '代理資料讀取失敗');
      }

      final source = sourceResult.data!;
      final principalEmployee = _findEmployee(
        employees: source.employees,
        employeeId: principalEmployeeId,
      );
      final agentEmployee = _findEmployee(
        employees: source.employees,
        employeeId: agentEmployeeId,
      );

      final validationMessage = _validateAssignment(
        principalDepartmentId: principalDepartmentId,
        principalEmployee: principalEmployee,
        agentDepartmentId: agentDepartmentId,
        agentEmployee: agentEmployee,
        existingAssignments: source.assignments,
      );
      if (validationMessage.isNotEmpty) {
        return Result.failure(validationMessage);
      }

      final now = DateTime.now();
      final assignment = EmpAgentAssignmentModel(
        assignmentId: 'agent_${now.microsecondsSinceEpoch}',
        principalDepartmentId: principalDepartmentId,
        principalEmployeeId: principalEmployeeId,
        agentDepartmentId: agentDepartmentId,
        agentEmployeeId: agentEmployeeId,
        status: 1,
        createdDate: _formatDate(now),
        createdTime: _formatTime(now),
        updatedDate: _formatDate(now),
        updatedTime: _formatTime(now),
      );

      final saveResult = await _repository.saveAssignment(assignment);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '代理資料儲存失敗');
      }

      final refreshResult = await _loadSourceData();
      if (!refreshResult.isSuccess || refreshResult.data == null) {
        return Result.failure(refreshResult.error ?? '代理資料重整失敗');
      }

      return buildViewData(
        departments: refreshResult.data!.departments,
        employees: refreshResult.data!.employees,
        assignments: refreshResult.data!.assignments,
        principalDepartmentId: principalDepartmentId,
        principalEmployeeId: principalEmployeeId,
        agentDepartmentId: agentDepartmentId,
      );
    } catch (ex) {
      return Result.failure('代理資料儲存失敗: ${ex.toString()}');
    }
  }

  Future<Result<EmpAgentViewData>> deleteAssignment({
    required String assignmentId,
    required String principalDepartmentId,
    required String principalEmployeeId,
    required String agentDepartmentId,
  }) async {
    try {
      final deleteResult = await _repository.deleteAssignment(assignmentId);
      if (!deleteResult.isSuccess) {
        return Result.failure(deleteResult.error ?? '代理資料刪除失敗');
      }

      final refreshResult = await _loadSourceData();
      if (!refreshResult.isSuccess || refreshResult.data == null) {
        return Result.failure(refreshResult.error ?? '代理資料重整失敗');
      }

      return buildViewData(
        departments: refreshResult.data!.departments,
        employees: refreshResult.data!.employees,
        assignments: refreshResult.data!.assignments,
        principalDepartmentId: principalDepartmentId,
        principalEmployeeId: principalEmployeeId,
        agentDepartmentId: agentDepartmentId,
      );
    } catch (ex) {
      return Result.failure('代理資料刪除失敗: ${ex.toString()}');
    }
  }

  /// 把代理人指派與員工 join 成 dropdown 期待的 `{value, label}` JSON 字串。
  ///
  /// - value = agentEmployeeId
  /// - label = 員工姓名（找不到員工時 fallback 為 employeeId）
  /// - 過濾 status != 1 的指派；同 agent 去重；依 label 排序
  /// - 用於 dropdown_options_sample.json 中 emp_agent_options_api 的 response.data
  Future<Result<String>> buildAgentOptionsJson() async {
    try {
      final sourceResult = await _loadSourceData();
      if (!sourceResult.isSuccess || sourceResult.data == null) {
        return Result.failure(sourceResult.error ?? '代理資料讀取失敗');
      }

      final source = sourceResult.data!;
      final empById = {for (final e in source.employees) e.employeeId: e};
      final seen = <String>{};
      final entries = <Map<String, String>>[];
      for (final assignment in source.assignments) {
        if (assignment.status != 1) continue;
        if (!seen.add(assignment.agentEmployeeId)) continue;
        final emp = empById[assignment.agentEmployeeId];
        entries.add({
          'value': assignment.agentEmployeeId,
          'label': emp?.employeeName ?? assignment.agentEmployeeId,
        });
      }
      entries.sort((x, y) => x['label']!.compareTo(y['label']!));

      return Result.success(
        const JsonEncoder.withIndent('  ').convert(entries),
      );
    } catch (ex) {
      return Result.failure('代理人下拉 JSON 匯出失敗: ${ex.toString()}');
    }
  }

  String buildEmploymentPeriod(EmployeeModel employee) {
    if (employee.employeeId.isEmpty) {
      return '未指定';
    }

    final hireDate = employee.hireDate.isEmpty ? '未設定' : employee.hireDate;
    final leaveDate = employee.leaveDate.isEmpty ? '在職中' : employee.leaveDate;
    return '$hireDate ~ $leaveDate';
  }

  Future<Result<_EmpAgentSourceData>> _loadSourceData() async {
    try {
      final departmentsResult = await _orgDesignRepository.loadConfig();
      if (!departmentsResult.isSuccess) {
        return Result.failure(departmentsResult.error ?? '部門資料讀取失敗');
      }

      final employeesResult = await _empInfoRepository.loadEmployees();
      if (!employeesResult.isSuccess) {
        return Result.failure(employeesResult.error ?? '職員資料讀取失敗');
      }

      final assignmentsResult = await _repository.loadAssignments();
      if (!assignmentsResult.isSuccess) {
        return Result.failure(assignmentsResult.error ?? '代理資料讀取失敗');
      }

      final departments = List<OrgDepartmentNode>.from(
        departmentsResult.data?.departmentNodes ?? const <OrgDepartmentNode>[],
      );
      final employees = List<EmployeeModel>.from(
        employeesResult.data ?? const <EmployeeModel>[],
      );
      final assignments = List<EmpAgentAssignmentModel>.from(
        assignmentsResult.data ?? const <EmpAgentAssignmentModel>[],
      );

      return Result.success(
        _EmpAgentSourceData(
          departments: departments,
          employees: employees,
          assignments: assignments,
        ),
      );
    } catch (ex) {
      return Result.failure('代理資料讀取失敗: ${ex.toString()}');
    }
  }

  List<EmpAgentAssignmentViewModel> _buildAssignmentRows({
    required List<EmpAgentAssignmentModel> assignments,
    required List<OrgDepartmentNode> departments,
    required List<EmployeeModel> employees,
    String principalEmployeeId = '',
  }) {
    final filtered = principalEmployeeId.isEmpty
        ? <EmpAgentAssignmentModel>[]
        : assignments
            .where((a) => a.principalEmployeeId == principalEmployeeId)
            .toList();
    return filtered.map((assignment) {
      final principalEmployee = _findEmployee(
        employees: employees,
        employeeId: assignment.principalEmployeeId,
      );
      final agentEmployee = _findEmployee(
        employees: employees,
        employeeId: assignment.agentEmployeeId,
      );

      return EmpAgentAssignmentViewModel(
        assignmentId: assignment.assignmentId,
        principalDepartmentName: _findDepartmentName(
          departments: departments,
          departmentId: assignment.principalDepartmentId,
        ),
        principalEmployeeName: principalEmployee.employeeName,
        principalEmployeeCode: principalEmployee.employeeCode,
        principalRoleName: principalEmployee.roleName,
        principalEmploymentPeriod: buildEmploymentPeriod(principalEmployee),
        agentDepartmentName: _findDepartmentName(
          departments: departments,
          departmentId: assignment.agentDepartmentId,
        ),
        agentEmployeeName: agentEmployee.employeeName,
        agentEmployeeCode: agentEmployee.employeeCode,
        agentRoleName: agentEmployee.roleName,
        agentEmploymentPeriod: buildEmploymentPeriod(agentEmployee),
      );
    }).toList();
  }

  String _validateAssignment({
    required String principalDepartmentId,
    required EmployeeModel principalEmployee,
    required String agentDepartmentId,
    required EmployeeModel agentEmployee,
    required List<EmpAgentAssignmentModel> existingAssignments,
  }) {
    if (principalDepartmentId.isEmpty) {
      return '請選擇被代理部門';
    }

    if (principalEmployee.employeeId.isEmpty) {
      return '請選擇被代理員工';
    }

    if (!principalEmployee.isActive) {
      return '被代理員工需為在職';
    }

    if (principalEmployee.departmentId != principalDepartmentId) {
      return '被代理員工不屬於所選部門';
    }

    if (principalEmployee.hireDate.isEmpty) {
      return '被代理員工尚未設定入職日期';
    }

    if (agentDepartmentId.isEmpty) {
      return '請選擇代理人部門';
    }

    if (agentEmployee.employeeId.isEmpty) {
      return '請選擇代理人';
    }

    if (!agentEmployee.isActive) {
      return '代理人需為在職';
    }

    if (agentEmployee.departmentId != agentDepartmentId) {
      return '代理人不屬於所選部門';
    }

    if (agentEmployee.hireDate.isEmpty) {
      return '代理人尚未設定入職日期';
    }

    if (principalEmployee.employeeId == agentEmployee.employeeId) {
      return '代理人不可為本人';
    }

    final duplicated = existingAssignments.any((item) {
      if (item.principalEmployeeId != principalEmployee.employeeId ||
          item.agentEmployeeId != agentEmployee.employeeId ||
          !item.isActive) {
        return false;
      }

      return true;
    });
    if (duplicated) {
      return '相同代理人設定已存在';
    }

    return '';
  }

  String _findDepartmentName({
    required List<OrgDepartmentNode> departments,
    required String departmentId,
  }) {
    final department =
        departments.where((item) => item.departmentId == departmentId);
    if (department.isEmpty) {
      return '未指定部門';
    }

    final data = department.first;
    if (data.departmentCode.isEmpty) {
      return data.name;
    }

    return '${data.departmentCode} - ${data.name}';
  }

  EmployeeModel _findEmployee({
    required List<EmployeeModel> employees,
    required String employeeId,
  }) {
    final employee = employees.where((item) => item.employeeId == employeeId);
    if (employee.isEmpty) {
      return const EmployeeModel();
    }

    return employee.first;
  }

  String _resolveDepartmentId({
    required List<OrgDepartmentNode> departments,
    required String departmentId,
  }) {
    if (departments.isEmpty) {
      return '';
    }

    final hasDepartment =
        departments.any((item) => item.departmentId == departmentId);
    if (hasDepartment) {
      return departmentId;
    }

    return departments.first.departmentId;
  }

  String _resolveEmployeeId({
    required List<EmployeeModel> employees,
    required String employeeId,
  }) {
    final hasEmployee = employees.any((item) => item.employeeId == employeeId);
    return hasEmployee ? employeeId : '';
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class _EmpAgentSourceData {
  final List<OrgDepartmentNode> departments;
  final List<EmployeeModel> employees;
  final List<EmpAgentAssignmentModel> assignments;

  const _EmpAgentSourceData({
    required this.departments,
    required this.employees,
    required this.assignments,
  });
}
