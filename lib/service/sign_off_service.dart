import 'dart:convert';

import 'package:flutter_application_ai/enum/sign_off_approver_mode.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/enum/sign_off_condition_operator.dart';
import 'package:flutter_application_ai/enum/sign_off_condition_field_status.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_summary.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_choice.dart';
import 'package:flutter_application_ai/model/sign_off_path_condition.dart';
import 'package:flutter_application_ai/model/sign_off_path_rule.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/repositories/interface/emp_info_repository.dart';
import 'package:flutter_application_ai/repositories/interface/emp_role_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_launch_permission_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/repositories/interface/sign_off_repository.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

/// 簽核設定的初始化資料包。
class SignOffInitialData {
  final List<FormModel> forms;
  final List<SignOffTemplateModel> templates;
  final List<FormLaunchPermissionModel> permissions;
  final List<EmpRoleModel> roles;
  final List<OrgDepartmentNode> departments;
  final List<EmployeeModel> employees;

  const SignOffInitialData({
    this.forms = const [],
    this.templates = const [],
    this.permissions = const [],
    this.roles = const [],
    this.departments = const [],
    this.employees = const [],
  });
}

/// 簽核鏈解析結果中的單一簽核人項目。
class ResolvedApprover {
  final String nodeId;
  final String description;
  final String approverName;
  final String approverDepartmentId;
  final String approverRoleName;
  final bool resolved;
  final String unresolvedReason;

  const ResolvedApprover({
    required this.nodeId,
    required this.description,
    this.approverName = '',
    this.approverDepartmentId = '',
    this.approverRoleName = '',
    this.resolved = true,
    this.unresolvedReason = '',
  });
}

class SignOffService {
  final SignOffRepository _signOffRepository;
  final FormRepository _formRepository;
  final FormLaunchPermissionRepository _permissionRepository;
  final EmpRoleRepository _roleRepository;
  final EmpInfoRepository _empInfoRepository;
  final OrgDesignRepository _orgDesignRepository;
  final ConditionFieldService _conditionFieldService;

  SignOffService(
    this._signOffRepository,
    this._formRepository,
    this._permissionRepository,
    this._roleRepository,
    this._empInfoRepository,
    this._orgDesignRepository,
    this._conditionFieldService,
  );

  /// 載入指定表單可作為 path rule 條件的欄位列表。
  ///
  /// 資料來源：**form_condition_field 的 draft**（per-form 至多一筆）。
  /// 與 form_data_binding 解耦 — sign_off 只看條件欄位定義，不關心提交流程。
  ///
  /// 結果為空時可能代表：
  /// - 表單尚未在 form_condition_field 定義任何條件欄位
  /// UI 應顯示「請先到表單條件欄位定義」banner + 跳轉連結。
  Future<Result<List<SignOffConditionFieldChoice>>> loadFormFields(
      String formId) async {
    try {
      if (formId.isEmpty) return Result.success(const []);

      final draftResult = await _conditionFieldService.loadDraft(formId);
      if (!draftResult.isSuccess) {
        return Result.failure(draftResult.error ?? '載入條件欄位失敗');
      }
      final draft = draftResult.data;
      if (draft == null) return Result.success(const []);

      final choices = draft.definitions
          .map((def) => SignOffConditionFieldChoice(
                outputKey: def.fieldKey,
                label: def.label,
                fieldName: def.fieldKey,
                fieldType: def.outputType,
              ))
          .toList();
      return Result.success(choices);
    } catch (ex) {
      return Result.failure('載入條件欄位失敗: ${ex.toString()}');
    }
  }

  /// 批次載入指定 formIds 的條件欄位狀態摘要。
  ///
  /// 用於 sign_off_editor header chip 與表單 dropdown 圖示。
  /// 失敗的 formId 會以 `SignOffConditionFieldSummary.empty`（none 狀態）填補。
  Future<Result<Map<String, SignOffConditionFieldSummary>>>
      loadConditionFieldStatuses(List<String> formIds) async {
    final result = <String, SignOffConditionFieldSummary>{};
    for (final formId in formIds) {
      if (formId.isEmpty) continue;
      try {
        result[formId] = await _computeConditionFieldSummary(formId);
      } catch (_) {
        result[formId] = SignOffConditionFieldSummary.empty;
      }
    }
    return Result.success(result);
  }

  /// 載入單一 formId 的條件欄位狀態摘要（select form 後刷新用）。
  Future<Result<SignOffConditionFieldSummary>> loadConditionFieldStatus(
      String formId) async {
    try {
      if (formId.isEmpty) {
        return Result.success(SignOffConditionFieldSummary.empty);
      }
      return Result.success(await _computeConditionFieldSummary(formId));
    } catch (ex) {
      return Result.failure('載入條件欄位狀態失敗: ${ex.toString()}');
    }
  }

  /// 計算單一 formId 對應的條件欄位狀態摘要。
  Future<SignOffConditionFieldSummary> _computeConditionFieldSummary(
      String formId) async {
    final draftResult = await _conditionFieldService.loadDraft(formId);
    if (!draftResult.isSuccess) return SignOffConditionFieldSummary.empty;
    final draft = draftResult.data;
    if (draft == null || draft.definitions.isEmpty) {
      return SignOffConditionFieldSummary.empty;
    }
    return SignOffConditionFieldSummary(
      status: SignOffConditionFieldStatus.ready,
      definitionCount: draft.definitions.length,
    );
  }

  /// 評估單一 condition 是否成立。純函式，UI 預覽也共用。
  static bool evaluatePathCondition(
    SignOffPathCondition c,
    Map<String, String> formData,
  ) {
    final raw = formData[c.fieldId] ?? '';
    switch (c.operator) {
      case SignOffConditionOperator.equal:
        return raw == c.value;
      case SignOffConditionOperator.notEqual:
        return raw != c.value;
      case SignOffConditionOperator.contains:
        return raw.contains(c.value);
      case SignOffConditionOperator.greaterThan:
        return _compare(raw, c.value, c.fieldType, (a, b) => a > b);
      case SignOffConditionOperator.greaterThanOrEqual:
        return _compare(raw, c.value, c.fieldType, (a, b) => a >= b);
      case SignOffConditionOperator.lessThan:
        return _compare(raw, c.value, c.fieldType, (a, b) => a < b);
      case SignOffConditionOperator.lessThanOrEqual:
        return _compare(raw, c.value, c.fieldType, (a, b) => a <= b);
      case SignOffConditionOperator.between:
        return _compare(raw, c.value, c.fieldType, (a, b) => a >= b) &&
            _compare(raw, c.valueMax, c.fieldType, (a, b) => a <= b);
    }
  }

  /// 數字 / 日期比較統一管道。日期以 lexicographic 比較（ISO 字串可直接比）。
  static bool _compare(
    String left,
    String right,
    ConditionFieldType type,
    bool Function(num l, num r) cmp,
  ) {
    if (type == ConditionFieldType.number) {
      final l = double.tryParse(left.trim());
      final r = double.tryParse(right.trim());
      if (l == null || r == null) return false;
      return cmp(l, r);
    }
    if (type == ConditionFieldType.date) {
      // 日期以字串字典序比，前提是 ISO 格式（YYYY-MM-DD）
      final l = left.trim();
      final r = right.trim();
      if (l.isEmpty || r.isEmpty) return false;
      // 用字串比 — 將比較轉成 0/1 數字傳入 cmp 模擬 ordering
      final ord = l.compareTo(r);
      return cmp(ord.sign.toDouble(), 0);
    }
    return false;
  }

  /// 評估單一 rule 是否命中（null condition 視為 default rule，永遠 true）。
  static bool evaluatePathRule(
    SignOffPathRule rule,
    Map<String, String> formData,
  ) {
    if (rule.condition == null) return true;
    return evaluatePathCondition(rule.condition!, formData);
  }

  /// First-match 解析：依 sortOrder 評估 pathRules，取第一個命中 rule 的 activatedNodeIds。
  /// 無命中或 pathRules 為空 → 回傳所有非 origin 節點 nodeIds（fallback）。
  static Set<String> resolveActivatedNodeIds(
    SignOffTemplateModel template,
    Map<String, String> formData,
  ) {
    final fallback = template.canvasNodes
        .where((n) => !n.isApplicantOrigin)
        .map((n) => n.nodeId)
        .toSet();

    if (template.pathRules.isEmpty) return fallback;

    final rules = List<SignOffPathRule>.from(template.pathRules)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    for (final rule in rules) {
      if (evaluatePathRule(rule, formData)) {
        return rule.activatedNodeIds.toSet();
      }
    }
    return fallback;
  }

  Future<Result<SignOffInitialData>> initialize() async {
    try {
      final formsResult = await _formRepository.loadDraftForms();
      if (!formsResult.isSuccess) {
        return Result.failure(formsResult.error ?? '表單資料讀取失敗');
      }

      final templatesResult = await _signOffRepository.loadAll();
      if (!templatesResult.isSuccess) {
        return Result.failure(templatesResult.error ?? '簽核流程讀取失敗');
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

      final empResult = await _empInfoRepository.loadEmployees();
      final employees = empResult.isSuccess
          ? (empResult.data ?? const <EmployeeModel>[])
          : const <EmployeeModel>[];

      return Result.success(SignOffInitialData(
        forms: formsResult.data ?? const [],
        templates: templatesResult.data ?? const [],
        permissions: permissionsResult.data ?? const [],
        roles: rolesResult.data ?? const [],
        departments: departments,
        employees: employees,
      ));
    } catch (ex) {
      return Result.failure('初始化失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<SignOffTemplateModel>>> saveTemplate(
      SignOffTemplateModel template) async {
    try {
      if (template.formId.isEmpty) {
        return Result.failure('請選擇表單');
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final resolvedId = template.templateId.isEmpty
          ? 'sign_off_${DateTime.now().microsecondsSinceEpoch}'
          : template.templateId;

      final existingResult = await _signOffRepository.loadById(resolvedId);
      final existing = existingResult.isSuccess ? existingResult.data : null;

      final model = template.copyWith(
        templateId: resolvedId,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      final saveResult = await _signOffRepository.save(model);
      if (!saveResult.isSuccess) {
        return Result.failure(saveResult.error ?? '儲存失敗');
      }

      final reloadResult = await _signOffRepository.loadAll();
      return Result.success(reloadResult.data ?? const []);
    } catch (ex) {
      return Result.failure('儲存失敗: ${ex.toString()}');
    }
  }

  Future<Result<List<SignOffTemplateModel>>> deleteTemplate(
      String templateId) async {
    try {
      final deleteResult = await _signOffRepository.delete(templateId);
      if (!deleteResult.isSuccess) {
        return Result.failure(deleteResult.error ?? '刪除失敗');
      }

      final reloadResult = await _signOffRepository.loadAll();
      return Result.success(reloadResult.data ?? const []);
    } catch (ex) {
      return Result.failure('刪除失敗: ${ex.toString()}');
    }
  }

  /// 驗證模板：至少要有一個非申請起點的節點，且不能有同層互簽循環。
  String? validateTemplate(SignOffTemplateModel template) {
    final nodes = template.canvasNodes;
    if (nodes.isEmpty) return '流程至少需要一個節點';

    final approverNodes =
        nodes.where((n) => !n.isApplicantOrigin).toList();
    if (approverNodes.isEmpty) return '至少需要一個簽核節點';

    // 檢查同層互簽是否指向不存在的節點
    final nodeIds = nodes.map((n) => n.nodeId).toSet();
    for (final node in nodes) {
      if (node.isApplicantOrigin) continue;

      // 絕對位置 mode（hierarchyManager）必須綁部門
      if (node.approverMode == SignOffApproverMode.hierarchyManager &&
          node.departmentId.isEmpty) {
        return '節點「${_nodeLabel(node, template)}」未綁定部門';
      }
      if (node.approverMode == SignOffApproverMode.crossLevel) {
        if (node.crossLevelTargetNodeId.isEmpty) {
          return '節點「${_nodeLabel(node, template)}」未設定同層互簽目標';
        }
        if (!nodeIds.contains(node.crossLevelTargetNodeId)) {
          return '節點「${_nodeLabel(node, template)}」的同層互簽目標不存在';
        }
      }
      if (node.approverMode == SignOffApproverMode.designatedRole &&
          node.designatedRoleId.isEmpty) {
        return '節點「${_nodeLabel(node, template)}」未指定角色';
      }
      if (node.approverMode == SignOffApproverMode.designatedEmployee &&
          node.designatedEmployeeId.isEmpty) {
        return '節點「${_nodeLabel(node, template)}」未指定員工';
      }
      if (node.approverMode == SignOffApproverMode.applicantAncestorManager &&
          node.applicantAncestorOffset < 1) {
        return '節點「${_nodeLabel(node, template)}」上層主管層級需 >= 1';
      }
      if (node.approverMode == SignOffApproverMode.applicantManagerAtDepth &&
          node.applicantTargetDepthLevel < 0) {
        return '節點「${_nodeLabel(node, template)}」目標層級不可為負';
      }
    }

    // Path rules 驗證
    final approverNodeIds =
        approverNodes.map((n) => n.nodeId).toSet();
    final ruleIds = <String>{};
    for (final rule in template.pathRules) {
      if (rule.ruleId.isEmpty) {
        return '路徑規則「${rule.name}」缺少 ruleId';
      }
      if (!ruleIds.add(rule.ruleId)) {
        return '路徑規則 ID 重複：${rule.ruleId}';
      }
      // 啟用節點必須存在
      for (final nodeId in rule.activatedNodeIds) {
        if (!approverNodeIds.contains(nodeId)) {
          return '路徑規則「${rule.name.isEmpty ? rule.ruleId : rule.name}」'
              '啟用了不存在的節點 $nodeId（可能已被刪除）';
        }
      }
      // condition 驗證
      final c = rule.condition;
      if (c != null) {
        if (c.fieldId.isEmpty) {
          return '路徑規則「${rule.name.isEmpty ? rule.ruleId : rule.name}」'
              '未指定條件欄位';
        }
        if (c.operator == SignOffConditionOperator.between &&
            c.valueMax.isEmpty) {
          return '路徑規則「${rule.name.isEmpty ? rule.ruleId : rule.name}」'
              '介於 (between) 需要設定上限值';
        }
      }
    }

    return null;
  }

  String _nodeLabel(SignOffCanvasNode node, SignOffTemplateModel template) {
    if (node.isApplicantOrigin) return '申請起點';
    if (node.approverMode == SignOffApproverMode.applicantSelf) {
      return '申請人本人';
    }
    if (node.approverMode == SignOffApproverMode.applicantAncestorManager) {
      return '申請人上 ${node.applicantAncestorOffset} 層主管';
    }
    if (node.approverMode == SignOffApproverMode.applicantManagerAtDepth) {
      return _depthLabel(node.applicantTargetDepthLevel);
    }
    return node.departmentId.isNotEmpty
        ? node.departmentId
        : node.nodeId;
  }

  /// 模擬解析特定申請人的完整簽核鏈。
  ///
  /// 解析依據：
  /// - hierarchyManager: 取得節點所屬部門的 departmentHeadUserId 對應員工
  /// - crossLevel: 解析目標節點的部門主管
  /// - designatedRole: 列出符合 roleId 的所有員工
  /// - designatedEmployee: 直接回傳指定員工
  Future<Result<List<ResolvedApprover>>> resolveApproverChain({
    required SignOffTemplateModel template,
    required String applicantEmployeeId,
    Map<String, String>? applicantFormData,
  }) async {
    try {
      final empResult = await _empInfoRepository.loadEmployees();
      if (!empResult.isSuccess) {
        return Result.failure(empResult.error ?? '員工資料讀取失敗');
      }
      final employees = empResult.data ?? const <EmployeeModel>[];

      final departments = await _loadDepartments();
      final deptById = {for (final d in departments) d.departmentId: d};

      final empById = {for (final e in employees) e.employeeId: e};

      final rolesResult = await _roleRepository.loadRoles();
      final roles = rolesResult.isSuccess
          ? (rolesResult.data ?? const <EmpRoleModel>[])
          : const <EmpRoleModel>[];
      final roleById = {for (final r in roles) r.roleId: r};

      final result = <ResolvedApprover>[];

      // Path rules 過濾：依 form data 決定哪些節點要走
      final activatedSet = resolveActivatedNodeIds(
        template,
        applicantFormData ?? const <String, String>{},
      );

      // 依 sortOrder 排序：申請起點（sortOrder=0）優先，其餘依 sortOrder 遞增
      final sortedNodes = List<SignOffCanvasNode>.from(template.canvasNodes)
        ..sort((a, b) {
          if (a.isApplicantOrigin && !b.isApplicantOrigin) return -1;
          if (!a.isApplicantOrigin && b.isApplicantOrigin) return 1;
          return a.sortOrder.compareTo(b.sortOrder);
        });

      for (final node in sortedNodes) {
        // 過濾：非 origin 節點若不在 activated 集合中，跳過
        if (!node.isApplicantOrigin && !activatedSet.contains(node.nodeId)) {
          continue;
        }
        if (node.isApplicantOrigin) {
          final applicant = empById[applicantEmployeeId];
          result.add(ResolvedApprover(
            nodeId: node.nodeId,
            description: '申請起點',
            approverName: applicant?.employeeName ?? applicantEmployeeId,
            approverDepartmentId: applicant?.departmentId ?? '',
            approverRoleName: applicant?.roleName ?? '',
          ));
          continue;
        }

        switch (node.approverMode) {
          case SignOffApproverMode.hierarchyManager:
            _resolveHierarchyManager(node, deptById, empById, result);
            break;
          case SignOffApproverMode.crossLevel:
            _resolveCrossLevel(
                node, template.canvasNodes, deptById, empById, result);
            break;
          case SignOffApproverMode.designatedRole:
            _resolveDesignatedRole(node, employees, roleById, result);
            break;
          case SignOffApproverMode.designatedEmployee:
            _resolveDesignatedEmployee(node, empById, result);
            break;
          case SignOffApproverMode.applicantSelf:
            _resolveApplicantSelf(
                node, applicantEmployeeId, empById, result);
            break;
          case SignOffApproverMode.applicantAncestorManager:
            _resolveApplicantAncestor(
                node, applicantEmployeeId, deptById, empById, result);
            break;
          case SignOffApproverMode.applicantManagerAtDepth:
            _resolveApplicantManagerAtDepth(
                node, applicantEmployeeId, deptById, empById, result);
            break;
        }
      }

      return Result.success(result);
    } catch (ex) {
      return Result.failure('解析失敗: ${ex.toString()}');
    }
  }

  void _resolveHierarchyManager(
    SignOffCanvasNode node,
    Map<String, OrgDepartmentNode> deptById,
    Map<String, EmployeeModel> empById,
    List<ResolvedApprover> result,
  ) {
    final dept = deptById[node.departmentId];
    if (dept == null) {
      result.add(ResolvedApprover(
        nodeId: node.nodeId,
        description: '部門主管',
        resolved: false,
        unresolvedReason: '部門不存在',
      ));
      return;
    }

    final manager = _resolveDepartmentManager(dept, empById);
    result.add(ResolvedApprover(
      nodeId: node.nodeId,
      description: '${dept.name} 主管',
      approverName: manager?.employeeName ?? '（尚未設定主管）',
      approverDepartmentId: dept.departmentId,
      approverRoleName: manager?.roleName ?? '',
      resolved: manager != null,
      unresolvedReason: manager == null ? '部門未指定主管' : '',
    ));
  }

  /// 解析部門主管 — 兩層 fallback：
  ///
  /// 1. 優先用 `dept.departmentHeadUserId`（組織管理頁明確指定）
  /// 2. 若為空或對應員工不存在 → 找部門內任一 `roleType == 1`（主管級）員工
  ///
  /// 與 emp_dep 頁面判定一致：主管身份由 EmployeeModel.isManagerLevel 決定。
  EmployeeModel? _resolveDepartmentManager(
    OrgDepartmentNode dept,
    Map<String, EmployeeModel> empById,
  ) {
    if (dept.departmentHeadUserId.isNotEmpty) {
      final explicit = empById[dept.departmentHeadUserId];
      if (explicit != null) return explicit;
    }
    for (final emp in empById.values) {
      if (emp.departmentId == dept.departmentId && emp.isManagerLevel) {
        return emp;
      }
    }
    return null;
  }

  void _resolveCrossLevel(
    SignOffCanvasNode node,
    List<SignOffCanvasNode> allNodes,
    Map<String, OrgDepartmentNode> deptById,
    Map<String, EmployeeModel> empById,
    List<ResolvedApprover> result,
  ) {
    final target = allNodes.cast<SignOffCanvasNode?>().firstWhere(
          (n) => n?.nodeId == node.crossLevelTargetNodeId,
          orElse: () => null,
        );
    if (target == null) {
      result.add(ResolvedApprover(
        nodeId: node.nodeId,
        description: '同層互簽',
        resolved: false,
        unresolvedReason: '目標節點不存在',
      ));
      return;
    }

    final dept = deptById[target.departmentId];
    final manager =
        dept != null ? _resolveDepartmentManager(dept, empById) : null;
    result.add(ResolvedApprover(
      nodeId: node.nodeId,
      description: '同層互簽 → ${dept?.name ?? '未知部門'} 主管',
      approverName: manager?.employeeName ?? '（尚未設定主管）',
      approverDepartmentId: dept?.departmentId ?? '',
      approverRoleName: manager?.roleName ?? '',
      resolved: manager != null,
      unresolvedReason: manager == null ? '目標部門未指定主管' : '',
    ));
  }

  void _resolveDesignatedRole(
    SignOffCanvasNode node,
    List<EmployeeModel> employees,
    Map<String, EmpRoleModel> roleById,
    List<ResolvedApprover> result,
  ) {
    final role = roleById[node.designatedRoleId];
    final matched =
        employees.where((e) => e.roleId == node.designatedRoleId).toList();
    if (matched.isEmpty) {
      result.add(ResolvedApprover(
        nodeId: node.nodeId,
        description: '指定角色 → ${role?.roleName ?? node.designatedRoleId}',
        resolved: false,
        unresolvedReason: '無員工符合此角色',
      ));
      return;
    }
    result.add(ResolvedApprover(
      nodeId: node.nodeId,
      description: '指定角色 → ${role?.roleName ?? node.designatedRoleId}',
      approverName: matched.map((e) => e.employeeName).join('、'),
      approverRoleName: role?.roleName ?? '',
    ));
  }

  void _resolveDesignatedEmployee(
    SignOffCanvasNode node,
    Map<String, EmployeeModel> empById,
    List<ResolvedApprover> result,
  ) {
    final emp = empById[node.designatedEmployeeId];
    result.add(ResolvedApprover(
      nodeId: node.nodeId,
      description: '指定員工',
      approverName: emp?.employeeName ?? node.designatedEmployeeId,
      approverDepartmentId: emp?.departmentId ?? '',
      approverRoleName: emp?.roleName ?? '',
      resolved: emp != null,
      unresolvedReason: emp == null ? '指定員工不存在' : '',
    ));
  }

  void _resolveApplicantSelf(
    SignOffCanvasNode node,
    String applicantEmployeeId,
    Map<String, EmployeeModel> empById,
    List<ResolvedApprover> result,
  ) {
    final applicant = empById[applicantEmployeeId];
    result.add(ResolvedApprover(
      nodeId: node.nodeId,
      description: '申請人本人',
      approverName: applicant?.employeeName ?? applicantEmployeeId,
      approverDepartmentId: applicant?.departmentId ?? '',
      approverRoleName: applicant?.roleName ?? '',
      resolved: applicant != null,
      unresolvedReason: applicant == null ? '申請人不存在' : '',
    ));
  }

  void _resolveApplicantAncestor(
    SignOffCanvasNode node,
    String applicantEmployeeId,
    Map<String, OrgDepartmentNode> deptById,
    Map<String, EmployeeModel> empById,
    List<ResolvedApprover> result,
  ) {
    final applicant = empById[applicantEmployeeId];
    if (applicant == null) {
      result.add(ResolvedApprover(
        nodeId: node.nodeId,
        description: '申請人上 ${node.applicantAncestorOffset} 層主管',
        resolved: false,
        unresolvedReason: '申請人不存在',
      ));
      return;
    }

    var dept = deptById[applicant.departmentId];
    if (dept == null) {
      result.add(ResolvedApprover(
        nodeId: node.nodeId,
        description: '申請人上 ${node.applicantAncestorOffset} 層主管',
        resolved: false,
        unresolvedReason: '申請人部門不存在',
      ));
      return;
    }

    // applicantAncestorOffset 語意：1 = 直屬主管（申請人部門的主管）、N = 沿組織樹往上 N 層
    // 從申請人部門出發走 (offset - 1) 步即得目標部門
    for (var step = 1; step < node.applicantAncestorOffset; step++) {
      final parent = deptById[dept!.parentDepartmentId];
      if (parent == null) {
        result.add(ResolvedApprover(
          nodeId: node.nodeId,
          description: '申請人上 ${node.applicantAncestorOffset} 層主管',
          resolved: false,
          unresolvedReason: '組織樹不足 ${node.applicantAncestorOffset} 層',
        ));
        return;
      }
      dept = parent;
    }

    final manager = _resolveDepartmentManager(dept!, empById);
    result.add(ResolvedApprover(
      nodeId: node.nodeId,
      description: node.applicantAncestorOffset <= 1
          ? '申請人直屬主管 (${dept.name})'
          : '申請人上 ${node.applicantAncestorOffset} 層主管 (${dept.name})',
      approverName: manager?.employeeName ?? '（尚未設定主管）',
      approverDepartmentId: dept.departmentId,
      approverRoleName: manager?.roleName ?? '',
      resolved: manager != null,
      unresolvedReason: manager == null ? '部門未指定主管' : '',
    ));
  }

  void _resolveApplicantManagerAtDepth(
    SignOffCanvasNode node,
    String applicantEmployeeId,
    Map<String, OrgDepartmentNode> deptById,
    Map<String, EmployeeModel> empById,
    List<ResolvedApprover> result,
  ) {
    final target = node.applicantTargetDepthLevel;
    final targetLabel = _depthLabel(target);

    final applicant = empById[applicantEmployeeId];
    if (applicant == null) {
      result.add(ResolvedApprover(
        nodeId: node.nodeId,
        description: targetLabel,
        resolved: false,
        unresolvedReason: '申請人不存在',
      ));
      return;
    }

    var dept = deptById[applicant.departmentId];
    if (dept == null) {
      result.add(ResolvedApprover(
        nodeId: node.nodeId,
        description: targetLabel,
        resolved: false,
        unresolvedReason: '申請人部門不存在',
      ));
      return;
    }

    if (dept.depthLevel < target) {
      result.add(ResolvedApprover(
        nodeId: node.nodeId,
        description: targetLabel,
        resolved: false,
        unresolvedReason:
            '申請人部門 (L${dept.depthLevel}) 已在指定層級 (L$target) 之上',
      ));
      return;
    }

    while (dept!.depthLevel > target) {
      final parent = deptById[dept.parentDepartmentId];
      if (parent == null) {
        result.add(ResolvedApprover(
          nodeId: node.nodeId,
          description: targetLabel,
          resolved: false,
          unresolvedReason: '組織樹中斷，未到 L$target',
        ));
        return;
      }
      dept = parent;
    }

    final manager = _resolveDepartmentManager(dept, empById);
    result.add(ResolvedApprover(
      nodeId: node.nodeId,
      description: '$targetLabel (${dept.name})',
      approverName: manager?.employeeName ?? '（尚未設定主管）',
      approverDepartmentId: dept.departmentId,
      approverRoleName: manager?.roleName ?? '',
      resolved: manager != null,
      unresolvedReason: manager == null ? '部門未指定主管' : '',
    ));
  }

  /// 將 depthLevel 轉為通用層級名稱（不依賴特定組織命名慣例）。
  /// 組織命名 / 階層數可任意變動，這裡只回傳 depthLevel 數字 — 對應的「事業群 / BU / 區域」等具體名稱
  /// 由實際解析時的 dept.name 補足。
  static String _depthLabel(int depth) => 'L$depth 主管';

  Future<Result<String>> buildExportJson() async {
    try {
      final result = await _signOffRepository.loadAll();
      if (!result.isSuccess) {
        return Result.failure(result.error ?? '讀取失敗');
      }

      final payload = {
        'table': 'sign_off_template',
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
