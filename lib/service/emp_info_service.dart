import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/repositories/interface/emp_role_repository.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/unit/result.dart';

class EmpInfoService {
  final EmpInfoRepository _repository;
  final OrgDesignRepository _orgDesignRepository;
  final EmpRoleRepository _empRoleRepository;

  EmpInfoService(
    this._repository,
    this._orgDesignRepository,
    this._empRoleRepository,
  );

  Future<Result<List<EmployeeModel>>> initData() async {
    try {
      final employeesResult = await _repository.loadEmployees();
      if (!employeesResult.isSuccess) {
        return Result.failure(employeesResult.error ?? '職員資料讀取失敗');
      }

      final sortedEmployees = List<EmployeeModel>.from(
        employeesResult.data ?? const <EmployeeModel>[],
      )..sort((left, right) => left.employeeCode.compareTo(right.employeeCode));

      return Result.success(sortedEmployees);
    } catch (ex) {
      return Result.failure('職員資料初始化失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<EmployeeModel>>> filterEmployees({
    required String keyword,
    required List<EmployeeModel> employees,
  }) async {
    try {
      return Result.success(_filterEmployees(keyword, employees));
    } catch (ex) {
      return Result.failure('職員資料篩選失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<OrgDepartmentNode>>> loadDepartments() async {
    try {
      final configResult = await _orgDesignRepository.loadConfig();
      if (!configResult.isSuccess) {
        return Result.failure(configResult.error ?? '部門資料讀取失敗');
      }

      final departments = List<OrgDepartmentNode>.from(
        configResult.data?.departmentNodes ?? const <OrgDepartmentNode>[],
      )
        ..retainWhere((department) => department.isActive)
        ..sort((left, right) =>
            left.departmentCode.compareTo(right.departmentCode));

      return Result.success(departments);
    } catch (ex) {
      return Result.failure('部門資料讀取失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<EmpRoleModel>>> loadRoles() async {
    try {
      final rolesResult = await _empRoleRepository.loadRoles();
      if (!rolesResult.isSuccess) {
        return Result.failure(rolesResult.error ?? '角色資料讀取失敗');
      }

      final roles = List<EmpRoleModel>.from(
        rolesResult.data ?? const <EmpRoleModel>[],
      )
        ..retainWhere((role) => role.isActive)
        ..sort((left, right) => left.roleCode.compareTo(right.roleCode));

      return Result.success(roles);
    } catch (ex) {
      return Result.failure('角色資料讀取失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<EmployeeModel>>> saveEmployee({
    required String employeeId,
    required String employeeCode,
    required String employeeName,
    required String account,
    required String departmentId,
    required String roleId,
    required int status,
    required String hireDate,
    required String leaveDate,
    String createdBy = '',
    String createdByName = '',
    String updatedBy = '',
    String updatedByName = '',
  }) async {
    try {
      final normalizedCode = employeeCode.trim().toUpperCase();
      final normalizedName = employeeName.trim();
      final normalizedAccount = account.trim();
      final normalizedDepartmentId = departmentId.trim();
      final normalizedRoleId = roleId.trim();
      final normalizedHireDate = hireDate.trim();
      final normalizedLeaveDate = leaveDate.trim();
      final normalizedCreatedBy = createdBy.trim();
      final normalizedCreatedByName = createdByName.trim();
      final normalizedUpdatedBy = updatedBy.trim();
      final normalizedUpdatedByName = updatedByName.trim();

      if (normalizedCode.isEmpty) {
        return Result.failure('工號不可為空');
      }

      if (normalizedName.isEmpty) {
        return Result.failure('姓名不可為空');
      }

      if (normalizedAccount.isEmpty) {
        return Result.failure('帳號不可為空');
      }

      if (normalizedRoleId.isEmpty) {
        return Result.failure('角色不可為空');
      }

      if (normalizedHireDate.isEmpty) {
        return Result.failure('入職日期不可為空');
      }

      final parsedHireDate = DateTime.tryParse(normalizedHireDate);
      if (parsedHireDate == null) {
        return Result.failure('入職日期格式錯誤，請使用 YYYY-MM-DD');
      }

      if (normalizedLeaveDate.isNotEmpty) {
        final parsedLeaveDate = DateTime.tryParse(normalizedLeaveDate);
        if (parsedLeaveDate == null) {
          return Result.failure('離職日期格式錯誤，請使用 YYYY-MM-DD');
        }

        if (parsedLeaveDate.isBefore(parsedHireDate)) {
          return Result.failure('離職日期不可早於入職日期');
        }
      }

      final rolesResult = await loadRoles();
      if (!rolesResult.isSuccess) {
        return Result.failure(rolesResult.error ?? '角色資料讀取失敗');
      }

      final role = rolesResult.data?.cast<EmpRoleModel?>().firstWhere(
            (item) => item?.roleId == normalizedRoleId,
            orElse: () => null,
          );

      if (role == null) {
        return Result.failure('請選擇有效角色');
      }

      final employeesResult = await _repository.loadEmployees();
      if (!employeesResult.isSuccess) {
        return Result.failure(employeesResult.error ?? '職員資料讀取失敗');
      }

      final employees = List<EmployeeModel>.from(
        employeesResult.data ?? const [],
      );

      final duplicateIndex = employees.indexWhere(
        (employee) =>
            employee.employeeCode.toUpperCase() == normalizedCode &&
            employee.employeeId != employeeId,
      );

      if (duplicateIndex != -1) {
        return Result.failure('工號已存在，請使用其他工號');
      }

      final now = DateTime.now();
      final existingIndex = employees.indexWhere(
        (employee) => employee.employeeId == employeeId,
      );
      final existingEmployee =
          existingIndex == -1 ? null : employees[existingIndex];

      final employee = EmployeeModel(
        employeeId: employeeId.isEmpty
            ? 'emp_${now.microsecondsSinceEpoch}'
            : employeeId,
        employeeCode: normalizedCode,
        employeeName: normalizedName,
        account: normalizedAccount,
        departmentId: normalizedDepartmentId,
        roleId: role.roleId,
        roleName: role.roleName,
        roleType: role.roleType,
        status: status,
        hireDate: normalizedHireDate,
        leaveDate: normalizedLeaveDate,
        createdDate: existingEmployee?.createdDate ?? _formatDate(now),
        createdTime: existingEmployee?.createdTime ?? _formatTime(now),
        createdBy: existingEmployee?.createdBy ?? normalizedCreatedBy,
        createdByName:
            existingEmployee?.createdByName ?? normalizedCreatedByName,
        updatedDate: _formatDate(now),
        updatedTime: _formatTime(now),
        updatedBy: normalizedUpdatedBy.isEmpty
            ? (existingEmployee?.updatedBy ?? normalizedCreatedBy)
            : normalizedUpdatedBy,
        updatedByName: normalizedUpdatedByName.isEmpty
            ? (existingEmployee?.updatedByName ?? normalizedCreatedByName)
            : normalizedUpdatedByName,
      );

      final saveResult = await _repository.saveEmployee(employee);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '職員資料儲存失敗');
      }

      return initData();
    } catch (ex) {
      return Result.failure('職員資料儲存失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<EmployeeModel>>> deleteEmployee(String employeeId) async {
    try {
      final employeesResult = await _repository.loadEmployees();
      if (!employeesResult.isSuccess) {
        return Result.failure(employeesResult.error ?? '職員資料讀取失敗');
      }

      final employees = List<EmployeeModel>.from(
        employeesResult.data ?? const <EmployeeModel>[],
      );
      final targetIndex = employees.indexWhere(
        (employee) => employee.employeeId == employeeId,
      );

      if (targetIndex == -1) {
        return Result.failure('找不到指定職員');
      }

      employees.removeAt(targetIndex);

      final saveResult = await _repository.saveAllEmployees(employees);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '職員資料刪除失敗');
      }

      return initData();
    } catch (ex) {
      return Result.failure('職員資料刪除失敗: ${ex.toString()}');
    }
  }

  List<EmployeeModel> _filterEmployees(
    String keyword,
    List<EmployeeModel> employees,
  ) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) {
      return List<EmployeeModel>.from(employees);
    }

    return employees.where((employee) {
      final searchableText = [
        employee.employeeCode,
        employee.employeeName,
        employee.account,
        employee.departmentId,
        employee.roleName,
        employee.hireDate,
        employee.leaveDate,
        employee.createdByName,
        employee.updatedByName,
      ].join(' ').toLowerCase();

      return searchableText.contains(normalizedKeyword);
    }).toList();
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
