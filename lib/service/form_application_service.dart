import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_submission_model.dart';
import 'package:flutter_application_ai/model/leave_sign_off_model.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_launch_permission_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_submission_repository.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/repositories/interface/sign_off_repository.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
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

class FormApplicationService {
  final FormLaunchPermissionRepository _permissionRepository;
  final FormSubmissionRepository _submissionRepository;
  final EmpInfoRepository _empInfoRepository;
  final OrgDesignRepository _orgDesignRepository;
  final SignOffRepository _signOffRepository;
  final SignOffService _signOffService;
  final LocalStorage _localStorage;

  /// 「測試寫入」累積簽核資料的 LocalStorage key（與 form_button_action_api_sample.json
  /// 內 `test_write_to_storage_api` 的 path 一致）。
  static const String _signOffStorageKey = 'form_run_test_write_log';

  FormApplicationService(
    this._permissionRepository,
    this._submissionRepository,
    this._empInfoRepository,
    this._orgDesignRepository,
    this._signOffRepository,
    this._signOffService,
    this._localStorage,
  );

  /// 依 templateId 載入簽核流程模板。
  Future<Result<SignOffTemplateModel?>> loadSignOffTemplateById(
      String templateId) async {
    if (templateId.isEmpty) return Result.success(null);
    return _signOffRepository.loadById(templateId);
  }

  /// 解析 signOff 對應的完整簽核鏈。
  ///
  /// 從 signOff.templateId 取得模板，把 computedFields 當作 formData 餵入
  /// `SignOffService.resolveApproverChain`，回傳排序後的簽核人列表。
  /// templateId 為空或模板不存在 → 回空 list（非 failure）。
  Future<Result<List<ResolvedApprover>>> resolveSignOffChain(
      LeaveSignOffModel signOff) async {
    try {
      if (signOff.templateId.isEmpty) return Result.success(const []);
      final tplResult = await _signOffRepository.loadById(signOff.templateId);
      if (!tplResult.isSuccess || tplResult.data == null) {
        return Result.success(const []);
      }
      return _signOffService.resolveApproverChain(
        template: tplResult.data!,
        applicantEmployeeId: signOff.applicantId,
        applicantFormData: signOff.computedFields,
      );
    } catch (ex) {
      return Result.failure('解析簽核鏈失敗: ${ex.toString()}');
    }
  }

  /// 載入指定員工**可發起**的表單清單（給「新增申請」頁用）。
  ///
  /// 走完整 launch_permission 過濾（active / role / dept / 總管理 bypass）。
  Future<Result<List<AvailableFormItem>>> loadAvailableForms(
      String employeeId) async {
    try {
      final empResult = await _resolveEmployee(employeeId);
      if (!empResult.isSuccess) {
        return Result.failure(empResult.error ?? '員工資料讀取失敗');
      }
      final currentEmployee = empResult.data!;

      final permResult = await _permissionRepository.loadAll();
      if (!permResult.isSuccess) {
        return Result.failure(permResult.error ?? '權限資料讀取失敗');
      }
      final permissions =
          permResult.data ?? const <FormLaunchPermissionModel>[];

      final topLevelDeptIds = await _loadTopLevelDepartmentIds();
      final result = <AvailableFormItem>[];
      for (final perm in permissions) {
        if (!perm.isActive) continue;
        if (_canLaunch(currentEmployee, perm, topLevelDeptIds)) {
          result.add(AvailableFormItem(
            formId: perm.formId,
            formName: perm.formName,
            bindingId: perm.bindingId,
            permissionId: perm.permissionId,
          ));
        }
      }
      return Result.success(result);
    } catch (ex) {
      return Result.failure('載入可申請表單失敗: ${ex.toString()}');
    }
  }

  /// 載入指定員工**送出過**的 submission 清單（給「我的申請」頁用）。
  Future<Result<List<FormSubmissionModel>>> loadMySubmissions(
      String employeeId) async {
    try {
      final result = await _submissionRepository.loadByApplicantId(employeeId);
      if (!result.isSuccess) {
        return Result.failure(result.error ?? '我的申請讀取失敗');
      }
      return Result.success(result.data ?? const []);
    } catch (ex) {
      return Result.failure('我的申請讀取失敗: ${ex.toString()}');
    }
  }

  /// 依 signOffId 取單筆 [LeaveSignOffModel]（給 submission_view_page 用）。
  Future<Result<LeaveSignOffModel>> loadSignOffById(String signOffId) async {
    try {
      final raw = _localStorage.getString(_signOffStorageKey);
      if (raw == null || raw.isEmpty) {
        return Result.failure('找不到該筆申請（storage 為空）');
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return Result.failure('儲存格式錯誤');
      }
      final match = decoded
          .whereType<Map>()
          .map((m) => LeaveSignOffModel.fromMap(Map<String, dynamic>.from(m)))
          .cast<LeaveSignOffModel?>()
          .firstWhere(
            (m) => m?.signOffId == signOffId,
            orElse: () => null,
          );
      if (match == null) {
        return Result.failure('找不到 signOffId「$signOffId」對應的申請');
      }
      return Result.success(match);
    } catch (ex) {
      return Result.failure('讀取申請詳情失敗: ${ex.toString()}');
    }
  }

  /// 載入「測試寫入」產出的 LeaveSignOffModel 清單（給「我的申請」頁用）。
  ///
  /// 從 LocalStorage key `form_run_test_write_log` 讀累積 list，逐筆 parse 為
  /// [LeaveSignOffModel]，**嚴格按 applicantId == employeeId 過濾**，最新一筆放最前。
  /// 確保使用者只看到屬於自己的申請紀錄；切換登入者後不會看到他人資料。
  ///
  /// 注意：舊版測試寫入 applicantId 為空字串的資料將被排除，
  /// 需重新觸發測試寫入以產生帶當前登入者 ID 的紀錄。
  Future<Result<List<LeaveSignOffModel>>> loadMySignOffs(
      String employeeId) async {
    try {
      if (employeeId.isEmpty) {
        return Result.success(const []);
      }
      final raw = _localStorage.getString(_signOffStorageKey);
      if (raw == null || raw.isEmpty) {
        return Result.success(const []);
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return Result.success(const []);
      }
      final all = decoded
          .whereType<Map>()
          .map((m) =>
              LeaveSignOffModel.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      final filtered = all
          .where((m) => m.applicantId == employeeId)
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return Result.success(filtered);
    } catch (ex) {
      return Result.failure('我的申請讀取失敗: ${ex.toString()}');
    }
  }

  /// 解析 employeeId 為 EmployeeModel；找不到回 failure。
  Future<Result<EmployeeModel>> _resolveEmployee(String employeeId) async {
    final empResult = await _empInfoRepository.loadEmployees();
    if (!empResult.isSuccess) {
      return Result.failure(empResult.error ?? '員工資料讀取失敗');
    }
    final employees = empResult.data ?? const <EmployeeModel>[];
    final found = employees.cast<EmployeeModel?>().firstWhere(
          (emp) => emp?.employeeId == employeeId,
          orElse: () => null,
        );
    if (found == null) {
      return Result.failure('找不到員工資料');
    }
    return Result.success(found);
  }

  Future<Result<FormSubmissionModel>> submitForm({
    required String formId,
    required String formName,
    required String bindingId,
    required String applicantId,
    required String applicantName,
    required String departmentId,
    required Map<String, dynamic> fieldValues,
    Map<String, String> computedFields = const {},
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
        computedFields: computedFields,
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

    // 部門檢查：總管理（depthLevel == 0）員工 bypass — 對應 launch_permission
    // 編輯器將總管理排除於可選清單外的設計意圖（總管理預設享有所有發起權限）。
    final isTopLevelEmp = topLevelDeptIds.contains(emp.departmentId);
    if (!isTopLevelEmp &&
        permission.allowedDepartmentIds.isNotEmpty &&
        !permission.allowedDepartmentIds.contains(emp.departmentId)) {
      return false;
    }

    return true;
  }

  /// 從組織設定取出 depthLevel == 0 的部門 ID 集合（通常是「總管理」單一筆）。
  Future<Set<String>> _loadTopLevelDepartmentIds() async {
    try {
      final result = await _orgDesignRepository.loadConfig();
      if (!result.isSuccess || result.data == null) return const <String>{};
      return result.data!.departmentNodes
          .where((d) => d.depthLevel == 0)
          .map((d) => d.departmentId)
          .toSet();
    } catch (_) {
      return const <String>{};
    }
  }
}
