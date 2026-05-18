import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/enum/sign_off_multi_strategy.dart';
import 'package:flutter_application_ai/enum/sign_off_node_type.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_submission_model.dart';
import 'package:flutter_application_ai/model/sign_off_instance.dart';
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
  /// 優先採用 `signOff.resolvedChainSnapshot`（送出時 snapshot 的鏈）。
  /// 舊資料無 snapshot 時 fallback 現算 — 從 templateId 取模板餵
  /// `SignOffService.resolveApproverChain`。
  Future<Result<List<ResolvedApprover>>> resolveSignOffChain(
      SignOffInstance signOff) async {
    try {
      // 1. snapshot 路徑（流程定義已凍結）
      if (signOff.resolvedChainSnapshot.isNotEmpty) {
        final chain = signOff.resolvedChainSnapshot
            .map((m) => ResolvedApprover.fromMap(m))
            .toList();
        return Result.success(chain);
      }
      // 2. fallback 現算（舊資料相容）
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

  /// 計算指定關卡的「合格簽核者集合」= 主簽核者集合 ∪ 代理人（若允許）。
  Set<String> _eligibleSigners(ResolvedApprover approver) {
    final s = <String>{...approver.approverEmployeeIds};
    if (approver.allowAgentFallback && approver.agentEmployeeId.isNotEmpty) {
      s.add(approver.agentEmployeeId);
    }
    return s;
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

  /// 依 signOffId 取單筆 [SignOffInstance]（給 submission_view_page 用）。
  Future<Result<SignOffInstance>> loadSignOffById(String signOffId) async {
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
          .map((m) => SignOffInstance.fromMap(Map<String, dynamic>.from(m)))
          .cast<SignOffInstance?>()
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

  /// 載入「測試寫入」產出的 SignOffInstance 清單（給「我的申請」頁用）。
  ///
  /// 從 LocalStorage key `form_run_test_write_log` 讀累積 list，逐筆 parse 為
  /// [SignOffInstance]，**嚴格按 applicantId == employeeId 過濾**，最新一筆放最前。
  /// 確保使用者只看到屬於自己的申請紀錄；切換登入者後不會看到他人資料。
  ///
  /// 注意：舊版測試寫入 applicantId 為空字串的資料將被排除，
  /// 需重新觸發測試寫入以產生帶當前登入者 ID 的紀錄。
  Future<Result<List<SignOffInstance>>> loadMySignOffs(
      String employeeId) async {
    try {
      if (employeeId.isEmpty) {
        return Result.success(const []);
      }
      final all = _loadAllSignOffsFromStorage();
      final filtered = all
          .where((m) => m.applicantId == employeeId)
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return Result.success(filtered);
    } catch (ex) {
      return Result.failure('我的申請讀取失敗: ${ex.toString()}');
    }
  }

  /// 載入「目前簽核者為 [approverEmployeeId]」的 signOff 清單（給待我簽核頁用）。
  ///
  /// 規則：
  /// - status 必須為 pending 或 inReview
  /// - currentStepIndex >= 0（負值表示申請人手上或結案）
  /// - 解析鏈後 chain 過濾掉申請起點，取 approvers[currentStepIndex]
  /// - 該節點的 approverEmployeeIds 包含 [approverEmployeeId] 即列入
  Future<Result<List<SignOffInstance>>> loadPendingForApprover(
      String approverEmployeeId) async {
    try {
      if (approverEmployeeId.isEmpty) return Result.success(const []);
      final all = _loadAllSignOffsFromStorage();
      final pending = <SignOffInstance>[];
      for (final model in all) {
        if (model.status != LeaveSignOffStatus.pending &&
            model.status != LeaveSignOffStatus.inReview) {
          continue;
        }
        if (model.currentStepIndex < 0) continue; // 結案或在申請人手上
        final chainResult = await resolveSignOffChain(model);
        if (!chainResult.isSuccess) continue;
        final chain = chainResult.data ?? const <ResolvedApprover>[];
        final approvers =
            chain.where((r) => r.description != '申請起點').toList();
        if (approvers.isEmpty) continue;
        if (model.currentStepIndex >= approvers.length) continue;
        final current = approvers[model.currentStepIndex];
        // A2 保險：notify 節點不該停在 currentStep（applyLeadingNotifySkip
        // / _executeAction 已處理），但加雙重保險避免特殊情況下被列入待簽
        if (current.nodeType == SignOffNodeType.notify) continue;
        if (_eligibleSigners(current).contains(approverEmployeeId)) {
          pending.add(model);
        }
      }
      pending.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return Result.success(pending);
    } catch (ex) {
      return Result.failure('待我簽核讀取失敗: ${ex.toString()}');
    }
  }

  /// 通用 storage 讀取 — 從 LocalStorage 取所有 SignOffInstance。
  List<SignOffInstance> _loadAllSignOffsFromStorage() {
    final raw = _localStorage.getString(_signOffStorageKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((m) => SignOffInstance.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// 簽核動作執行 — 通用實作。
  ///
  /// 1. 找到對應 signOffId 的 model
  /// 2. Append 一筆 SignOffActionRecord 到 actionHistory
  /// 3. 依 [actionType] 更新 status / currentStepIndex / currentApprover 欄位
  /// 4. 寫回 LocalStorage
  Future<Result<SignOffInstance>> _executeAction({
    required String signOffId,
    required String approverId,
    required String approverName,
    required SignOffActionType actionType,
    required String comment,
  }) async {
    try {
      final all = _loadAllSignOffsFromStorage();
      final index = all.indexWhere((m) => m.signOffId == signOffId);
      if (index < 0) {
        return Result.failure('找不到 signOffId「$signOffId」對應的申請');
      }
      final original = all[index];

      // 權限驗證：解析鏈、找出當前關卡，檢查 approverId 是否在合格集合內
      final chainResult = await resolveSignOffChain(original);
      final chain = chainResult.isSuccess
          ? (chainResult.data ?? const <ResolvedApprover>[])
          : const <ResolvedApprover>[];
      final approvers =
          chain.where((r) => r.description != '申請起點').toList();
      if (approvers.isEmpty ||
          original.currentStepIndex < 0 ||
          original.currentStepIndex >= approvers.length) {
        return Result.failure('當前無待簽關卡');
      }
      final currentApprover = approvers[original.currentStepIndex];
      final eligible = _eligibleSigners(currentApprover);
      if (!eligible.contains(approverId)) {
        return Result.failure('您不是此關卡的合格簽核者');
      }
      // 是否代簽：當登入者是代理人但非主簽核者集合內 → 帶上 principal
      final isAgentActing =
          !currentApprover.approverEmployeeIds.contains(approverId) &&
              currentApprover.allowAgentFallback &&
              currentApprover.agentEmployeeId == approverId;
      final principalApproverId = isAgentActing
          ? (currentApprover.approverEmployeeIds.isNotEmpty
              ? currentApprover.approverEmployeeIds.first
              : '')
          : '';

      // Append actionRecord
      final now = DateTime.now().toUtc().toIso8601String();
      final record = SignOffActionRecord(
        recordId: 'act_${DateTime.now().microsecondsSinceEpoch}',
        actionType: actionType,
        approverId: approverId,
        approverName: approverName,
        comment: comment,
        actionAt: now,
        principalApproverId: principalApproverId,
      );
      final newHistory =
          List<SignOffActionRecord>.from(original.actionHistory)..add(record);

      // 依動作類型決定 status / stepIndex / currentApprover
      LeaveSignOffStatus newStatus = original.status;
      int newStepIndex = original.currentStepIndex;
      String newCurrentApproverId = '';
      String newCurrentApproverName = '';

      // A1 多人會簽收斂：取/建當前節點 NodeApprovalState
      final newNodeStates =
          Map<String, NodeApprovalState>.from(original.nodeStates);
      final currentNodeId = currentApprover.nodeId;
      final currentNodeState = newNodeStates[currentNodeId] ??
          NodeApprovalState(nodeId: currentNodeId);

      switch (actionType) {
        case SignOffActionType.approve:
          // 把 approverId 加進 approvedBy（代簽時記主簽核者 ID 以維持節點視角一致）
          final signerId = isAgentActing ? principalApproverId : approverId;
          final newApprovedBy = signerId.isNotEmpty &&
                  !currentNodeState.approvedBy.contains(signerId)
              ? ([...currentNodeState.approvedBy, signerId])
              : currentNodeState.approvedBy;
          newNodeStates[currentNodeId] = currentNodeState.copyWith(
            approvedBy: newApprovedBy,
          );

          // 依 multiStrategy 判定是否推進該節點
          final shouldAdvance = _shouldAdvanceOnApprove(
            strategy: currentApprover.multiStrategy,
            approverEmployeeIds: currentApprover.approverEmployeeIds,
            approvedBy: newApprovedBy,
          );

          if (!shouldAdvance) {
            // 節點內未收斂 — 停留原關卡，currentApproverId 指向下一位尚未簽且未拒絕者
            newStatus = LeaveSignOffStatus.inReview;
            newStepIndex = original.currentStepIndex;
            final nextSigner = _nextPendingSignerInNode(
              strategy: currentApprover.multiStrategy,
              approverEmployeeIds: currentApprover.approverEmployeeIds,
              approvedBy: newApprovedBy,
              rejectedBy: currentNodeState.rejectedBy,
            );
            newCurrentApproverId = nextSigner ?? '';
            newCurrentApproverName = currentApprover.approverName;
            break;
          }

          // 推進至下一節點（A2：連續 notify 自動 skip）
          final nextIndex = _appendAutoNotifyAndAdvance(
            approvers: approvers,
            fromIndex: original.currentStepIndex + 1,
            historyMutable: newHistory,
            now: now,
          );
          if (nextIndex >= approvers.length) {
            newStatus = LeaveSignOffStatus.approved;
            newStepIndex = -1;
          } else {
            newStatus = LeaveSignOffStatus.inReview;
            newStepIndex = nextIndex;
            final nextApprover = approvers[nextIndex];
            if (nextApprover.approverEmployeeIds.isNotEmpty) {
              // 下一節點若為 sequential，首位簽核者為 approverEmployeeIds[0]
              newCurrentApproverId = nextApprover.approverEmployeeIds.first;
            }
            newCurrentApproverName = nextApprover.approverName;
          }
          break;
        case SignOffActionType.reject:
          // 任一拒絕視為否決 — 終止整個流程（all/any/sequential 一致）
          newNodeStates[currentNodeId] = currentNodeState.copyWith(
            rejectedBy: [...currentNodeState.rejectedBy, approverId],
          );
          newStatus = LeaveSignOffStatus.rejected;
          newStepIndex = -1;
          break;
        case SignOffActionType.returnBack:
          // 退回 — 流程回到申請人，清除當前節點的多人狀態（重啟簽核時重算）
          newNodeStates.remove(currentNodeId);
          newStatus = LeaveSignOffStatus.pending;
          newStepIndex = -1;
          break;
        case SignOffActionType.requestSupplement:
          // 補件 — 流程暫停在當前關卡，等申請人補完重送
          // nodeStates / status / stepIndex / currentApprover* 都維持
          newStatus = original.status;
          newStepIndex = original.currentStepIndex;
          newCurrentApproverId = original.currentApproverId;
          newCurrentApproverName = original.currentApproverName;
          break;
        default:
          return Result.failure('v1 不支援此簽核動作：${actionType.label}');
      }

      final updated = original.copyWith(
        status: newStatus,
        currentStepIndex: newStepIndex,
        currentApproverId: newCurrentApproverId,
        currentApproverName: newCurrentApproverName,
        latestComment: comment,
        actionHistory: newHistory,
        nodeStates: newNodeStates,
        updatedAt: now,
      );

      all[index] = updated;
      await _localStorage.setString(
        _signOffStorageKey,
        jsonEncode(all.map((m) => m.toMap()).toList()),
      );
      return Result.success(updated);
    } catch (ex) {
      return Result.failure('簽核動作執行失敗：${ex.toString()}');
    }
  }

  /// 依 multiStrategy 判斷當前節點是否已收斂可推進。
  ///
  /// - all：approverEmployeeIds 全部都在 approvedBy 內才推進
  /// - any：任一人簽完即推進
  /// - sequential：approvedBy 必須完整且依序對應 approverEmployeeIds
  ///
  /// 單人節點（approverEmployeeIds.length == 1）下三策略結果等價（首人簽完即推）。
  bool _shouldAdvanceOnApprove({
    required SignOffMultiStrategy strategy,
    required List<String> approverEmployeeIds,
    required List<String> approvedBy,
  }) {
    if (approverEmployeeIds.isEmpty) return true;
    if (approverEmployeeIds.length == 1) return true;
    switch (strategy) {
      case SignOffMultiStrategy.any:
        return approvedBy.isNotEmpty;
      case SignOffMultiStrategy.all:
        final approvedSet = approvedBy.toSet();
        return approverEmployeeIds.every(approvedSet.contains);
      case SignOffMultiStrategy.sequential:
        if (approvedBy.length != approverEmployeeIds.length) return false;
        for (var i = 0; i < approverEmployeeIds.length; i++) {
          if (approvedBy[i] != approverEmployeeIds[i]) return false;
        }
        return true;
    }
  }

  /// 節點未收斂時，找下一位該簽的人（給 currentApproverId 顯示用）。
  ///
  /// - sequential：approverEmployeeIds 中第 N+1 位（N = approvedBy.length）
  /// - all / any：approverEmployeeIds 中首位「未簽且未拒絕」者
  /// 找不到時回 null（理論上 shouldAdvance=false 時必有下一位）。
  String? _nextPendingSignerInNode({
    required SignOffMultiStrategy strategy,
    required List<String> approverEmployeeIds,
    required List<String> approvedBy,
    required List<String> rejectedBy,
  }) {
    if (approverEmployeeIds.isEmpty) return null;
    if (strategy == SignOffMultiStrategy.sequential) {
      final nextIdx = approvedBy.length;
      if (nextIdx < approverEmployeeIds.length) {
        return approverEmployeeIds[nextIdx];
      }
      return null;
    }
    final approvedSet = approvedBy.toSet();
    final rejectedSet = rejectedBy.toSet();
    for (final id in approverEmployeeIds) {
      if (!approvedSet.contains(id) && !rejectedSet.contains(id)) {
        return id;
      }
    }
    return null;
  }

  /// A2：從 fromIndex 開始連續跳過 notify 節點，每跳一個 append 一筆
  /// `SignOffActionRecord(actionType: autoNotify)` 至 historyMutable。
  ///
  /// 回傳：第一個非 notify 節點的 index；若全部跳完則 = approvers.length（呼叫端視為結案）。
  /// 用於：approve 推進 / 建單時 head notify 跳過 (applyLeadingNotifySkip)。
  int _appendAutoNotifyAndAdvance({
    required List<ResolvedApprover> approvers,
    required int fromIndex,
    required List<SignOffActionRecord> historyMutable,
    required String now,
  }) {
    var idx = fromIndex;
    while (idx < approvers.length &&
        approvers[idx].nodeType == SignOffNodeType.notify) {
      final notifyNode = approvers[idx];
      final approverId = notifyNode.approverEmployeeIds.isNotEmpty
          ? notifyNode.approverEmployeeIds.first
          : '';
      final approverName = notifyNode.resolved
          ? notifyNode.approverName
          : '未能通知：${notifyNode.unresolvedReason}';
      historyMutable.add(SignOffActionRecord(
        recordId:
            'auto_${DateTime.now().microsecondsSinceEpoch}_${idx.toString()}',
        actionType: SignOffActionType.autoNotify,
        approverId: approverId,
        approverName: approverName,
        comment: '系統自動通知',
        actionAt: now,
      ));
      idx++;
    }
    return idx;
  }

  Future<Result<SignOffInstance>> approveSignOff({
    required String signOffId,
    required String approverId,
    required String approverName,
    String comment = '',
  }) {
    return _executeAction(
      signOffId: signOffId,
      approverId: approverId,
      approverName: approverName,
      actionType: SignOffActionType.approve,
      comment: comment,
    );
  }

  Future<Result<SignOffInstance>> rejectSignOff({
    required String signOffId,
    required String approverId,
    required String approverName,
    required String comment,
  }) {
    return _executeAction(
      signOffId: signOffId,
      approverId: approverId,
      approverName: approverName,
      actionType: SignOffActionType.reject,
      comment: comment,
    );
  }

  /// 補件 — 簽核者要求申請人補資料。
  /// 流程暫停在當前關卡，補件原因記入 comment（必填）。
  /// 申請人在「我的申請」可編輯重送（透過 isEditableByApplicant getter）。
  Future<Result<SignOffInstance>> requestSupplementSignOff({
    required String signOffId,
    required String approverId,
    required String approverName,
    required String comment,
  }) {
    if (comment.trim().isEmpty) {
      return Future.value(Result.failure('補件原因為必填'));
    }
    return _executeAction(
      signOffId: signOffId,
      approverId: approverId,
      approverName: approverName,
      actionType: SignOffActionType.requestSupplement,
      comment: comment,
    );
  }

  /// 轉派 — 簽核者把當前關卡的簽核權交給其他員工。
  /// 修改 resolvedChainSnapshot 當前關卡的 approverEmployeeIds，stepIndex / status 不變。
  Future<Result<SignOffInstance>> transferSignOff({
    required String signOffId,
    required String approverId,
    required String approverName,
    required String targetEmployeeId,
    required String comment,
  }) async {
    try {
      final all = _loadAllSignOffsFromStorage();
      final index = all.indexWhere((m) => m.signOffId == signOffId);
      if (index < 0) {
        return Result.failure('找不到 signOffId「$signOffId」對應的申請');
      }
      final original = all[index];

      // 驗證權限（與 _executeAction 一致）
      final chainResult = await resolveSignOffChain(original);
      final chain = chainResult.isSuccess
          ? (chainResult.data ?? const <ResolvedApprover>[])
          : const <ResolvedApprover>[];
      final approvers =
          chain.where((r) => r.description != '申請起點').toList();
      if (approvers.isEmpty ||
          original.currentStepIndex < 0 ||
          original.currentStepIndex >= approvers.length) {
        return Result.failure('當前無待簽關卡');
      }
      if (!_eligibleSigners(approvers[original.currentStepIndex])
          .contains(approverId)) {
        return Result.failure('您不是此關卡的合格簽核者');
      }

      // 解出目標員工
      final targetResult = await _resolveEmployee(targetEmployeeId);
      if (!targetResult.isSuccess || targetResult.data == null) {
        return Result.failure(targetResult.error ?? '目標員工不存在');
      }
      final target = targetResult.data!;
      if (!target.isActive) {
        return Result.failure('目標員工目前停用，無法轉派');
      }

      // 改 snapshot 對應 entry
      final newSnapshot = List<Map<String, dynamic>>.from(
        original.resolvedChainSnapshot.map(
          (m) => Map<String, dynamic>.from(m),
        ),
      );
      final entryIdx = _snapshotIndexForCurrentStep(
          newSnapshot, original.currentStepIndex);
      if (entryIdx < 0) {
        return Result.failure('snapshot 找不到當前關卡');
      }
      // 轉派語意：只換「實際簽核者」，不換關卡的角色 / 部門定義。
      // 因此 approverDepartmentId / approverRoleName / description 保留原值，
      // 避免「申請人直屬主管(產品開發組) - 陳煙溪」誤讀為陳煙溪屬於該部門主管。
      final entry = newSnapshot[entryIdx];
      entry['approverEmployeeIds'] = [target.employeeId];
      entry['approverName'] = target.employeeName;
      entry['agentEmployeeId'] = '';
      entry['agentName'] = '';
      entry['resolved'] = true;
      entry['unresolvedReason'] = '';

      // 軌跡
      final now = DateTime.now().toUtc().toIso8601String();
      final record = SignOffActionRecord(
        recordId: 'act_${DateTime.now().microsecondsSinceEpoch}',
        actionType: SignOffActionType.transfer,
        approverId: approverId,
        approverName: approverName,
        comment: comment,
        actionAt: now,
        targetRef: targetEmployeeId,
      );
      final newHistory =
          List<SignOffActionRecord>.from(original.actionHistory)..add(record);

      // 轉派後當前節點換人 — 清掉該節點 nodeStates（原 approver 的 approve/reject 紀錄失效）
      final currentNodeId =
          (newSnapshot[entryIdx]['nodeId'] ?? '').toString();
      final newNodeStates =
          Map<String, NodeApprovalState>.from(original.nodeStates);
      newNodeStates.remove(currentNodeId);

      final updated = original.copyWith(
        resolvedChainSnapshot: newSnapshot,
        currentApproverId: target.employeeId,
        currentApproverName: target.employeeName,
        latestComment: comment,
        actionHistory: newHistory,
        nodeStates: newNodeStates,
        updatedAt: now,
      );

      all[index] = updated;
      await _localStorage.setString(
        _signOffStorageKey,
        jsonEncode(all.map((m) => m.toMap()).toList()),
      );
      return Result.success(updated);
    } catch (ex) {
      return Result.failure('轉派失敗：${ex.toString()}');
    }
  }

  /// 加簽 — 在當前關卡後插入新關卡，由 [addedEmployeeId] 簽。
  /// 視同 A 已 approve 當前關，流程推進到加簽人關卡。
  Future<Result<SignOffInstance>> addApproverSignOff({
    required String signOffId,
    required String approverId,
    required String approverName,
    required String addedEmployeeId,
    required String comment,
  }) async {
    try {
      final all = _loadAllSignOffsFromStorage();
      final index = all.indexWhere((m) => m.signOffId == signOffId);
      if (index < 0) {
        return Result.failure('找不到 signOffId「$signOffId」對應的申請');
      }
      final original = all[index];

      final chainResult = await resolveSignOffChain(original);
      final chain = chainResult.isSuccess
          ? (chainResult.data ?? const <ResolvedApprover>[])
          : const <ResolvedApprover>[];
      final approvers =
          chain.where((r) => r.description != '申請起點').toList();
      if (approvers.isEmpty ||
          original.currentStepIndex < 0 ||
          original.currentStepIndex >= approvers.length) {
        return Result.failure('當前無待簽關卡');
      }
      if (!_eligibleSigners(approvers[original.currentStepIndex])
          .contains(approverId)) {
        return Result.failure('您不是此關卡的合格簽核者');
      }

      // 解目標員工
      final targetResult = await _resolveEmployee(addedEmployeeId);
      if (!targetResult.isSuccess || targetResult.data == null) {
        return Result.failure(targetResult.error ?? '加簽員工不存在');
      }
      final target = targetResult.data!;
      if (!target.isActive) {
        return Result.failure('加簽員工目前停用');
      }

      // snapshot 在當前關卡後插入新 entry
      final newSnapshot = List<Map<String, dynamic>>.from(
        original.resolvedChainSnapshot.map(
          (m) => Map<String, dynamic>.from(m),
        ),
      );
      final entryIdx = _snapshotIndexForCurrentStep(
          newSnapshot, original.currentStepIndex);
      if (entryIdx < 0) {
        return Result.failure('snapshot 找不到當前關卡');
      }
      final newEntry = {
        'nodeId': 'add_${DateTime.now().microsecondsSinceEpoch}',
        'description': '加簽（由 $approverName 加入）',
        'approverName': target.employeeName,
        'approverDepartmentId': target.departmentId,
        'approverRoleName': target.roleName,
        'approverEmployeeIds': [target.employeeId],
        'resolved': true,
        'unresolvedReason': '',
        'allowAgentFallback': false,
        'agentEmployeeId': '',
        'agentName': '',
      };
      newSnapshot.insert(entryIdx + 1, newEntry);

      // 軌跡：A 加簽
      final now = DateTime.now().toUtc().toIso8601String();
      final record = SignOffActionRecord(
        recordId: 'act_${DateTime.now().microsecondsSinceEpoch}',
        actionType: SignOffActionType.addApprover,
        approverId: approverId,
        approverName: approverName,
        comment: comment,
        actionAt: now,
        targetRef: addedEmployeeId,
      );
      final newHistory =
          List<SignOffActionRecord>.from(original.actionHistory)..add(record);

      // 推進 stepIndex +1 → 進加簽人關
      final newStepIndex = original.currentStepIndex + 1;
      final updated = original.copyWith(
        resolvedChainSnapshot: newSnapshot,
        currentStepIndex: newStepIndex,
        currentApproverId: target.employeeId,
        currentApproverName: target.employeeName,
        status: LeaveSignOffStatus.inReview,
        latestComment: comment,
        actionHistory: newHistory,
        updatedAt: now,
      );

      all[index] = updated;
      await _localStorage.setString(
        _signOffStorageKey,
        jsonEncode(all.map((m) => m.toMap()).toList()),
      );
      return Result.success(updated);
    } catch (ex) {
      return Result.failure('加簽失敗：${ex.toString()}');
    }
  }

  /// 從 snapshot 找到「過濾申請起點後第 currentStepIndex 個」entry 的真實 index。
  /// 找不到回 -1。
  int _snapshotIndexForCurrentStep(
      List<Map<String, dynamic>> snapshot, int currentStepIndex) {
    var nonOriginCount = 0;
    for (var i = 0; i < snapshot.length; i++) {
      if (snapshot[i]['description'] == '申請起點') continue;
      if (nonOriginCount == currentStepIndex) return i;
      nonOriginCount++;
    }
    return -1;
  }

  Future<Result<SignOffInstance>> returnBackSignOff({
    required String signOffId,
    required String approverId,
    required String approverName,
    required String comment,
  }) {
    return _executeAction(
      signOffId: signOffId,
      approverId: approverId,
      approverName: approverName,
      actionType: SignOffActionType.returnBack,
      comment: comment,
    );
  }

  /// 載入全部 active 員工 — 給 submission view 內轉派 / 加簽 dialog 員工選擇用。
  Future<Result<List<EmployeeModel>>> loadActiveEmployees() async {
    try {
      final empResult = await _empInfoRepository.loadEmployees();
      if (!empResult.isSuccess) {
        return Result.failure(empResult.error ?? '員工資料讀取失敗');
      }
      final employees = (empResult.data ?? const <EmployeeModel>[])
          .where((e) => e.isActive)
          .toList();
      return Result.success(employees);
    } catch (ex) {
      return Result.failure('員工資料讀取失敗: ${ex.toString()}');
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

/// A2：建單時若 `resolvedChainSnapshot` 首節點是 notify，跳過至第一個非 notify 步驟。
///
/// 每跳一個 notify 節點 append 一筆 `SignOffActionRecord(actionType: autoNotify)`，
/// 並把 `currentStepIndex` / `currentApproverId` / `currentApproverName` 設定到第一個
/// 非 notify 節點。若全部都是 notify → 直接結案（status=approved, stepIndex=-1）。
///
/// 純函式 — 由 form_run_service 在 `executeTestWriteSignOff` / `executeUpdateSignOff`
/// 寫入 LocalStorage 前呼叫一次。
SignOffInstance applyLeadingNotifySkip(SignOffInstance original) {
  if (original.resolvedChainSnapshot.isEmpty) return original;

  final approvers = original.resolvedChainSnapshot
      .map((m) => ResolvedApprover.fromMap(Map<String, dynamic>.from(m)))
      .where((r) => r.description != '申請起點')
      .toList();
  if (approvers.isEmpty) return original;

  final fromIndex = original.currentStepIndex;
  if (fromIndex < 0 || fromIndex >= approvers.length) return original;
  if (approvers[fromIndex].nodeType != SignOffNodeType.notify) {
    return original;
  }

  final now = DateTime.now().toUtc().toIso8601String();
  final newHistory =
      List<SignOffActionRecord>.from(original.actionHistory);
  var idx = fromIndex;
  while (idx < approvers.length &&
      approvers[idx].nodeType == SignOffNodeType.notify) {
    final notifyNode = approvers[idx];
    newHistory.add(SignOffActionRecord(
      recordId: 'auto_${DateTime.now().microsecondsSinceEpoch}_$idx',
      actionType: SignOffActionType.autoNotify,
      approverId: notifyNode.approverEmployeeIds.isNotEmpty
          ? notifyNode.approverEmployeeIds.first
          : '',
      approverName: notifyNode.resolved
          ? notifyNode.approverName
          : '未能通知：${notifyNode.unresolvedReason}',
      comment: '系統自動通知',
      actionAt: now,
    ));
    idx++;
  }

  if (idx >= approvers.length) {
    // 整份模板都是 notify — 直接結案
    return original.copyWith(
      actionHistory: newHistory,
      currentStepIndex: -1,
      currentApproverId: '',
      currentApproverName: '',
      status: LeaveSignOffStatus.approved,
      updatedAt: now,
    );
  }

  final nextApprover = approvers[idx];
  return original.copyWith(
    actionHistory: newHistory,
    currentStepIndex: idx,
    currentApproverId: nextApprover.approverEmployeeIds.isNotEmpty
        ? nextApprover.approverEmployeeIds.first
        : '',
    currentApproverName: nextApprover.approverName,
    updatedAt: now,
  );
}
