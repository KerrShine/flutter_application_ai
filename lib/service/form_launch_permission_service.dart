import 'dart:convert';

import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/repositories/interface/emp_role_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_launch_permission_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormLaunchPermissionInitialData {
  final List<FormModel> forms;
  final List<FormLaunchPermissionModel> permissions;
  final List<EmpRoleModel> roles;
  final List<OrgDepartmentNode> departments;

  const FormLaunchPermissionInitialData({
    this.forms = const [],
    this.permissions = const [],
    this.roles = const [],
    this.departments = const [],
  });
}

class EligibleEmployeeInfo {
  final String employeeId;
  final String employeeName;
  final String roleName;
  final String departmentId;

  const EligibleEmployeeInfo({
    required this.employeeId,
    required this.employeeName,
    required this.roleName,
    required this.departmentId,
  });
}

class FormLaunchPermissionService {
  final FormLaunchPermissionRepository _permissionRepository;
  final FormRepository _formRepository;
  final EmpRoleRepository _roleRepository;
  final EmpInfoRepository _empInfoRepository;
  final OrgDesignRepository _orgDesignRepository;

  FormLaunchPermissionService(
    this._permissionRepository,
    this._formRepository,
    this._roleRepository,
    this._empInfoRepository,
    this._orgDesignRepository,
  );

  Future<Result<FormLaunchPermissionInitialData>> initialize() async {
    try {
      final formsResult = await _formRepository.loadDraftForms();
      if (!formsResult.isSuccess) {
        return Result.failure(formsResult.error ?? '表單資料讀取失敗');
      }

      final permissionsResult = await _permissionRepository.loadAll();
      if (!permissionsResult.isSuccess) {
        return Result.failure(permissionsResult.error ?? '權限資料讀取失敗');
      }

      final rolesResult = await _roleRepository.loadRoles();
      if (!rolesResult.isSuccess) {
        return Result.failure(rolesResult.error ?? '角色資料讀取失敗');
      }

      final departments = await _loadDepartments();

      return Result.success(FormLaunchPermissionInitialData(
        forms: formsResult.data ?? const [],
        permissions: permissionsResult.data ?? const [],
        roles: rolesResult.data ?? const [],
        departments: departments,
      ));
    } catch (ex) {
      return Result.failure('初始化失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<FormLaunchPermissionModel>>> savePermission({
    required String permissionId,
    required String formId,
    required String formName,
    required String bindingId,
    required List<String> allowedRoleIds,
    required List<String> allowedDepartmentIds,
    required bool requireActiveStatus,
    required bool requireManagerRole,
    required int isEnabled,
  }) async {
    try {
      if (formId.isEmpty) {
        return Result.failure('請選擇表單');
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final resolvedId = permissionId.isEmpty
          ? 'perm_${DateTime.now().microsecondsSinceEpoch}'
          : permissionId;

      final existingResult =
          await _permissionRepository.loadById(resolvedId);
      final existing =
          existingResult.isSuccess ? existingResult.data : null;

      final model = FormLaunchPermissionModel(
        permissionId: resolvedId,
        formId: formId,
        formName: formName,
        bindingId: bindingId,
        allowedRoleIds: allowedRoleIds,
        allowedDepartmentIds: allowedDepartmentIds,
        requireActiveStatus: requireActiveStatus,
        requireManagerRole: requireManagerRole,
        isEnabled: isEnabled,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      final saveResult = await _permissionRepository.save(model);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '儲存失敗');
      }

      final reloadResult = await _permissionRepository.loadAll();
      if (!reloadResult.isSuccess) {
        return Result.failure(reloadResult.error ?? '重新讀取失敗');
      }

      return Result.success(reloadResult.data ?? const []);
    } catch (ex) {
      return Result.failure('儲存失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<FormLaunchPermissionModel>>> deletePermission(
      String permissionId) async {
    try {
      final deleteResult = await _permissionRepository.delete(permissionId);
      if (!deleteResult.isSuccess) {
        return Result.failure(deleteResult.error ?? '刪除失敗');
      }

      final reloadResult = await _permissionRepository.loadAll();
      return Result.success(reloadResult.data ?? const []);
    } catch (ex) {
      return Result.failure('刪除失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<EligibleEmployeeInfo>>> previewEligibleEmployees(
      FormLaunchPermissionModel permission) async {
    try {
      final empResult = await _empInfoRepository.loadEmployees();
      if (!empResult.isSuccess) {
        return Result.failure(empResult.error ?? '員工資料讀取失敗');
      }

      final employees = empResult.data ?? const <EmployeeModel>[];
      final topLevelDeptIds = _topLevelDeptIdsOf(await _loadDepartments());
      final eligible = <EligibleEmployeeInfo>[];

      for (final emp in employees) {
        if (_canLaunch(emp, permission, topLevelDeptIds)) {
          eligible.add(EligibleEmployeeInfo(
            employeeId: emp.employeeId,
            employeeName: emp.employeeName,
            roleName: emp.roleName,
            departmentId: emp.departmentId,
          ));
        }
      }

      return Result.success(eligible);
    } catch (ex) {
      return Result.failure('預覽失敗: ${ex.toString()}');
    }
  }

  bool _canLaunch(
    EmployeeModel emp,
    FormLaunchPermissionModel permission,
    Set<String> topLevelDeptIds,
  ) {
    if (permission.requireActiveStatus && !emp.isActive) return false;
    if (permission.requireManagerRole && !emp.isManagerLevel) return false;

    if (permission.allowedRoleIds.isNotEmpty &&
        !permission.allowedRoleIds.contains(emp.roleId)) {
      return false;
    }

    // 部門檢查：總管理（depthLevel == 0）員工 bypass — 對應編輯器將總管理排除於
    // 可選清單外的設計意圖（總管理預設享有所有發起權限）。
    final isTopLevelEmp = topLevelDeptIds.contains(emp.departmentId);
    if (!isTopLevelEmp &&
        permission.allowedDepartmentIds.isNotEmpty &&
        !permission.allowedDepartmentIds.contains(emp.departmentId)) {
      return false;
    }

    return true;
  }

  Set<String> _topLevelDeptIdsOf(List<OrgDepartmentNode> departments) {
    return departments
        .where((d) => d.depthLevel == 0)
        .map((d) => d.departmentId)
        .toSet();
  }

  Future<Result<String>> buildExportJson() async {
    try {
      final result = await _permissionRepository.loadAll();
      if (!result.isSuccess) {
        return Result.failure(result.error ?? '讀取失敗');
      }

      final payload = {
        'table': 'form_launch_permission',
        'total': result.data!.length,
        'items': result.data!.map((item) => item.toMap()).toList(),
      };

      return Result.success(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } catch (ex) {
      return Result.failure('匯出失敗: ${ex.toString()}');
    }
  }

  Future<List<OrgDepartmentNode>> _loadDepartments() async {
    try {
      final result = await _orgDesignRepository.loadConfig();
      if (!result.isSuccess || result.data == null) return [];

      return result.data!.departmentNodes;
    } catch (_) {
      return [];
    }
  }
}
