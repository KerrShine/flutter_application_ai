import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class EmpInfoRepositoryImpl implements EmpInfoRepository {
  static const String _employeesKey = 'employees_key';

  final LocalStorage _localStorage;

  EmpInfoRepositoryImpl(this._localStorage);

  @override
  Future<Result<List<EmployeeModel>>> loadEmployees() async {
    try {
      final raw = _localStorage.getString(_employeesKey);
      if (raw == null || raw.isEmpty) {
        return Result.success([]);
      }

      final list = (jsonDecode(raw) as List)
          .map((item) => EmployeeModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<EmployeeModel?>> loadById(String employeeId) async {
    if (employeeId.isEmpty) return Result.success(null);
    final result = await loadEmployees();
    if (!result.isSuccess) {
      return Result.failure(result.error ?? '讀取員工失敗');
    }
    final found = (result.data ?? const <EmployeeModel>[])
        .cast<EmployeeModel?>()
        .firstWhere(
          (e) => e?.employeeId == employeeId,
          orElse: () => null,
        );
    return Result.success(found);
  }

  @override
  Future<Result<bool>> saveAllEmployees(List<EmployeeModel> employees) async {
    try {
      final payload = employees.map((employee) => employee.toMap()).toList();
      await _localStorage.setString(_employeesKey, jsonEncode(payload));
      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveEmployee(EmployeeModel employee) async {
    try {
      final currentResult = await loadEmployees();
      final currentEmployees = currentResult.isSuccess
          ? List<EmployeeModel>.from(currentResult.data ?? const [])
          : <EmployeeModel>[];

      final index = currentEmployees.indexWhere(
        (item) => item.employeeId == employee.employeeId,
      );

      if (index == -1) {
        currentEmployees.add(employee);
      } else {
        currentEmployees[index] = employee;
      }

      return saveAllEmployees(currentEmployees);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
