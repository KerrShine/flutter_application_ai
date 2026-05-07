import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class FormLaunchPermissionRepository {
  Future<Result<List<FormLaunchPermissionModel>>> loadAll();
  Future<Result<List<FormLaunchPermissionModel>>> loadByFormId(String formId);
  Future<Result<FormLaunchPermissionModel?>> loadById(String permissionId);
  Future<Result<bool>> save(FormLaunchPermissionModel permission);
  Future<Result<bool>> saveAll(List<FormLaunchPermissionModel> permissions);
  Future<Result<bool>> delete(String permissionId);
}
