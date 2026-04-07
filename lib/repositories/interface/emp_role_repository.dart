import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class EmpRoleRepository {
  Future<Result<List<EmpRoleModel>>> loadRoles();
  Future<Result<bool>> saveRole(EmpRoleModel role);
  Future<Result<bool>> saveAllRoles(List<EmpRoleModel> roles);
  Future<Result<EmpRoleModel?>> loadRoleById(String roleId);
}
