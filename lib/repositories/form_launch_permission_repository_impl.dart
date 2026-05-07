import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/repositories/interface/form_launch_permission_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormLaunchPermissionRepositoryImpl
    implements FormLaunchPermissionRepository {
  static const String _storageKey = 'form_launch_permissions_key';

  final LocalStorage _localStorage;

  FormLaunchPermissionRepositoryImpl(this._localStorage);

  @override
  Future<Result<List<FormLaunchPermissionModel>>> loadAll() async {
    try {
      final raw = _localStorage.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return Result.success([]);
      }

      final list = (jsonDecode(raw) as List)
          .map((item) =>
              FormLaunchPermissionModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<List<FormLaunchPermissionModel>>> loadByFormId(
      String formId) async {
    final result = await loadAll();
    if (!result.isSuccess) return Result.failure(result.error ?? '讀取失敗');

    final filtered =
        result.data!.where((item) => item.formId == formId).toList();
    return Result.success(filtered);
  }

  @override
  Future<Result<FormLaunchPermissionModel?>> loadById(
      String permissionId) async {
    final result = await loadAll();
    if (!result.isSuccess) return Result.failure(result.error ?? '讀取失敗');

    final found = result.data!.cast<FormLaunchPermissionModel?>().firstWhere(
          (item) => item?.permissionId == permissionId,
          orElse: () => null,
        );
    return Result.success(found);
  }

  @override
  Future<Result<bool>> save(FormLaunchPermissionModel permission) async {
    try {
      final currentResult = await loadAll();
      final currentList = currentResult.isSuccess
          ? List<FormLaunchPermissionModel>.from(currentResult.data ?? const [])
          : <FormLaunchPermissionModel>[];

      final index = currentList.indexWhere(
        (item) => item.permissionId == permission.permissionId,
      );

      if (index == -1) {
        currentList.add(permission);
      } else {
        currentList[index] = permission;
      }

      return saveAll(currentList);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveAll(
      List<FormLaunchPermissionModel> permissions) async {
    try {
      final payload = permissions.map((item) => item.toMap()).toList();
      await _localStorage.setString(_storageKey, jsonEncode(payload));
      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> delete(String permissionId) async {
    try {
      final currentResult = await loadAll();
      final currentList = currentResult.isSuccess
          ? List<FormLaunchPermissionModel>.from(currentResult.data ?? const [])
          : <FormLaunchPermissionModel>[];

      currentList.removeWhere((item) => item.permissionId == permissionId);
      return saveAll(currentList);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
