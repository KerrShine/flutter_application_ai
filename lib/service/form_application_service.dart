import 'dart:convert';

import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_submission_model.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_launch_permission_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_submission_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class AvailableFormItem {
  final String formId;
  final String formName;
  final String bindingId;
  final String permissionId;

  const AvailableFormItem({
    required this.formId,
    required this.formName,
    required this.bindingId,
    required this.permissionId,
  });
}

class FormApplicationInitialData {
  final List<AvailableFormItem> availableForms;
  final List<FormSubmissionModel> mySubmissions;
  final EmployeeModel currentEmployee;

  const FormApplicationInitialData({
    this.availableForms = const [],
    this.mySubmissions = const [],
    this.currentEmployee = const EmployeeModel(),
  });
}

class FormApplicationService {
  final FormLaunchPermissionRepository _permissionRepository;
  final FormSubmissionRepository _submissionRepository;
  final EmpInfoRepository _empInfoRepository;

  FormApplicationService(
    this._permissionRepository,
    this._submissionRepository,
    this._empInfoRepository,
  );

  Future<Result<FormApplicationInitialData>> initialize(
      String employeeId) async {
    try {
      final empResult = await _empInfoRepository.loadEmployees();
      if (!empResult.isSuccess) {
        return Result.failure(empResult.error ?? '員工資料讀取失敗');
      }

      final employees = empResult.data ?? const <EmployeeModel>[];
      final currentEmployee = employees.cast<EmployeeModel?>().firstWhere(
            (emp) => emp?.employeeId == employeeId,
            orElse: () => null,
          );

      if (currentEmployee == null) {
        return Result.failure('找不到員工資料');
      }

      final permResult = await _permissionRepository.loadAll();
      if (!permResult.isSuccess) {
        return Result.failure(permResult.error ?? '權限資料讀取失敗');
      }

      final permissions = permResult.data ?? const <FormLaunchPermissionModel>[];
      final availableForms = <AvailableFormItem>[];

      for (final perm in permissions) {
        if (!perm.isActive) continue;
        if (_canLaunch(currentEmployee, perm)) {
          availableForms.add(AvailableFormItem(
            formId: perm.formId,
            formName: perm.formName,
            bindingId: perm.bindingId,
            permissionId: perm.permissionId,
          ));
        }
      }

      final submResult =
          await _submissionRepository.loadByApplicantId(employeeId);

      return Result.success(FormApplicationInitialData(
        availableForms: availableForms,
        mySubmissions: submResult.isSuccess
            ? (submResult.data ?? const [])
            : const [],
        currentEmployee: currentEmployee,
      ));
    } catch (ex) {
      return Result.failure('初始化失敗: ${ex.toString()}');
    }
  }

  Future<Result<FormSubmissionModel>> submitForm({
    required String formId,
    required String formName,
    required String bindingId,
    required String applicantId,
    required String applicantName,
    required String departmentId,
    required Map<String, dynamic> fieldValues,
  }) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final submissionId = 'sub_${DateTime.now().microsecondsSinceEpoch}';

      final model = FormSubmissionModel(
        submissionId: submissionId,
        formId: formId,
        formName: formName,
        bindingId: bindingId,
        applicantId: applicantId,
        applicantName: applicantName,
        departmentId: departmentId,
        fieldValues: fieldValues,
        status: 'submitted',
        submittedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await _submissionRepository.save(model);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '送出失敗');
      }

      return Result.success(model);
    } catch (ex) {
      return Result.failure('送出失敗: ${ex.toString()}');
    }
  }

  Future<Result<String>> buildExportJson(String applicantId) async {
    try {
      final result =
          await _submissionRepository.loadByApplicantId(applicantId);
      if (!result.isSuccess) {
        return Result.failure(result.error ?? '讀取失敗');
      }

      final payload = {
        'table': 'form_submission',
        'applicant_id': applicantId,
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

  bool _canLaunch(
      EmployeeModel emp, FormLaunchPermissionModel permission) {
    if (permission.requireActiveStatus && !emp.isActive) return false;
    if (permission.requireManagerRole && !emp.isManagerLevel) return false;

    if (permission.allowedRoleIds.isNotEmpty &&
        !permission.allowedRoleIds.contains(emp.roleId)) {
      return false;
    }

    if (permission.allowedDepartmentIds.isNotEmpty &&
        !permission.allowedDepartmentIds.contains(emp.departmentId)) {
      return false;
    }

    return true;
  }
}
