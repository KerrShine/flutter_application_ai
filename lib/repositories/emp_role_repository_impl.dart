import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/repositories/interface/emp_role_repository.dart';
import 'package:flutter_application_ai/unit/result.dart';

class EmpRoleRepositoryImpl implements EmpRoleRepository {
  static const String _rolesKey = 'emp_roles_key';

  final LocalStorage _localStorage;

  EmpRoleRepositoryImpl(this._localStorage);

  @override
  Future<Result<List<EmpRoleModel>>> loadRoles() async {
    try {
      final raw = _localStorage.getString(_rolesKey);
      if (raw == null || raw.isEmpty) {
        return Result.success([]);
      }

      final list = (jsonDecode(raw) as List)
          .map((item) => EmpRoleModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<EmpRoleModel?>> loadRoleById(String roleId) async {
    final result = await loadRoles();
    if (!result.isSuccess) {
      return Result.failure(result.error ?? '角色資料讀取失敗');
    }

    final found = result.data!.cast<EmpRoleModel?>().firstWhere(
          (role) => role?.roleId == roleId,
          orElse: () => null,
        );
    return Result.success(found);
  }

  @override
  Future<Result<bool>> saveAllRoles(List<EmpRoleModel> roles) async {
    try {
      final payload = roles.map((role) => role.toMap()).toList();
      await _localStorage.setString(_rolesKey, jsonEncode(payload));
      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveRole(EmpRoleModel role) async {
    try {
      final currentResult = await loadRoles();
      final currentRoles = currentResult.isSuccess
          ? List<EmpRoleModel>.from(currentResult.data ?? const [])
          : <EmpRoleModel>[];

      final index = currentRoles.indexWhere(
        (item) => item.roleId == role.roleId,
      );

      if (index == -1) {
        currentRoles.add(role);
      } else {
        currentRoles[index] = role;
      }

      return saveAllRoles(currentRoles);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
