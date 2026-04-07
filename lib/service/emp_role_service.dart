import 'dart:convert';

import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/repositories/interface/emp_role_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class EmpRoleService {
  final EmpRoleRepository _repository;

  EmpRoleService(this._repository);

  Future<Result<List<EmpRoleModel>>> initData() async {
    try {
      final rolesResult = await _repository.loadRoles();
      if (!rolesResult.isSuccess) {
        return Result.failure(rolesResult.error ?? '角色資料讀取失敗');
      }

      return Result.success(rolesResult.data ?? const <EmpRoleModel>[]);
    } catch (ex) {
      return Result.failure('角色初始化失敗: ${ex.toString()}');
    }
  }

  Future<Result<String>> buildExportJson() async {
    try {
      final rolesResult = await _repository.loadRoles();
      if (!rolesResult.isSuccess) {
        return Result.failure(rolesResult.error ?? '角色資料讀取失敗');
      }

      final payload = {
        'table': 'emp_role',
        'total': rolesResult.data!.length,
        'items': rolesResult.data!.map((role) => role.toMap()).toList(),
      };

      return Result.success(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } catch (ex) {
      return Result.failure('角色 JSON 匯出失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<EmpRoleModel>>> saveRole({
    required String roleId,
    required String roleCode,
    required String roleName,
    required int roleType,
    required int status,
  }) async {
    try {
      final normalizedCode = roleCode.trim().toUpperCase();
      final normalizedName = roleName.trim();

      if (normalizedCode.isEmpty) {
        return Result.failure('角色代碼不可為空');
      }

      if (normalizedName.isEmpty) {
        return Result.failure('角色名稱不可為空');
      }

      final rolesResult = await _repository.loadRoles();
      if (!rolesResult.isSuccess) {
        return Result.failure(rolesResult.error ?? '角色資料讀取失敗');
      }

      final roles = List<EmpRoleModel>.from(rolesResult.data ?? const []);
      final duplicateIndex = roles.indexWhere(
        (role) =>
            role.roleCode.toUpperCase() == normalizedCode &&
            role.roleId != roleId,
      );
      if (duplicateIndex != -1) {
        return Result.failure('角色代碼已存在，請使用其他代碼');
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final resolvedRoleId = roleId.isEmpty
          ? 'role_${DateTime.now().microsecondsSinceEpoch}'
          : roleId;

      final existingIndex = roles.indexWhere(
        (role) => role.roleId == resolvedRoleId,
      );

      final existing = existingIndex == -1 ? null : roles[existingIndex];
      final model = EmpRoleModel(
        roleId: resolvedRoleId,
        roleCode: normalizedCode,
        roleName: normalizedName,
        roleType: roleType,
        status: status,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      final saveResult = await _repository.saveRole(model);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '角色儲存失敗');
      }

      final reloadResult = await _repository.loadRoles();
      if (!reloadResult.isSuccess) {
        return Result.failure(reloadResult.error ?? '角色資料讀取失敗');
      }

      return Result.success(reloadResult.data ?? const []);
    } catch (ex) {
      return Result.failure('角色儲存失敗: ${ex.toString()}');
    }
  }
}
