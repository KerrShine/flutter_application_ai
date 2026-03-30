import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/unit/result.dart';

abstract class EmpInfoRepository {
  Future<Result<List<EmployeeModel>>> loadEmployees();
  Future<Result<bool>> saveEmployee(EmployeeModel employee);
  Future<Result<bool>> saveAllEmployees(List<EmployeeModel> employees);
}
