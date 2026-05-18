import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/leave_sign_off_status.dart';
import 'package:flutter_application_ai/model/node_approval_state.dart';
import 'package:flutter_application_ai/model/sign_off_action_record.dart';

export 'package:flutter_application_ai/enum/leave_sign_off_status.dart';
export 'package:flutter_application_ai/model/node_approval_state.dart';
export 'package:flutter_application_ai/model/sign_off_action_record.dart';

/// 簽核任務實例（單一申請從送出到結案的執行體）。
///
/// 由 [FormSubmissionModel] 衍生，攜帶完整 form 資料與簽核流程狀態。
/// 供「待我簽核」/「我的申請」/「簽核軌跡」等簽核相關頁面共用。
///
/// 本 class 原名為 `LeaveSignOffModel`（v1 以請假為唯一情境命名），
/// 隨簽核引擎泛化為所有表單共用，於 A7 重構時更名為 `SignOffInstance`。
class SignOffInstance extends Equatable {
  // === 識別 ===
  final String signOffId;
  final String submissionId;

  /// 簽核流程模板 ID（對應 SignOffTemplateModel.templateId）。
  /// 非空時 ApplicationSubmissionViewPage 會用此 id 載入模板並解析完整簽核鏈。
  final String templateId;

  // === Form 資料 ===
  final String formId;
  final String formName;
  final String applicantId;
  final String applicantName;
  final String departmentId;
  final Map<String, dynamic> fieldValues;
  final Map<String, String> computedFields;

  /// 送出當下的 sections 結構快照（序列化自 List<SectionModel> via toMap()）。
  ///
  /// 用於 submission_view_page 渲染時，即使表單設計後續被改動，
  /// 舊申請仍能呈現送出當下的完整欄位結構。
  final List<Map<String, dynamic>> sectionsSnapshot;

  /// 送出當下的簽核鏈快照（序列化自 List<ResolvedApprover> via toMap()）。
  ///
  /// 包含每一關的 approverEmployeeIds / allowAgentFallback / agentEmployeeId
  /// / multiStrategy 等 runtime 權限判定與會簽收斂所需資訊。
  /// 模板於送出後被改動時，此 snapshot 仍代表流程定義。
  /// 空 list = 舊資料相容（fallback 改現算）。
  final List<Map<String, dynamic>> resolvedChainSnapshot;

  // === 簽核狀態 ===
  final LeaveSignOffStatus status;

  /// 當前簽核步驟（0-based，對應 resolvedChain 過濾掉申請起點後的 index）。
  /// - 0 = 等待第一個簽核者
  /// - N = 等待第 N+1 個簽核者
  /// - -1 = 結案（approved/rejected/withdrawn）或在申請人手上（returnBack）
  final int currentStepIndex;

  final String currentApproverId;
  final String currentApproverName;
  final String latestComment;

  /// 簽核軌跡 — 按時間順序追加，最新一筆在最後。
  final List<SignOffActionRecord> actionHistory;

  /// 會簽節點內部多人簽核狀態（A1 多人會簽收斂用）。
  /// key = nodeId（對應 ResolvedApprover.nodeId）。
  /// 推進時依該節點的 multiStrategy 判定 all / any / sequential 是否收斂。
  final Map<String, NodeApprovalState> nodeStates;

  // === 時間 ===
  final String submittedAt;
  final String updatedAt;

  const SignOffInstance({
    this.signOffId = '',
    this.submissionId = '',
    this.templateId = '',
    this.formId = '',
    this.formName = '',
    this.applicantId = '',
    this.applicantName = '',
    this.departmentId = '',
    this.fieldValues = const {},
    this.computedFields = const {},
    this.sectionsSnapshot = const [],
    this.resolvedChainSnapshot = const [],
    this.status = LeaveSignOffStatus.pending,
    this.currentStepIndex = 0,
    this.currentApproverId = '',
    this.currentApproverName = '',
    this.latestComment = '',
    this.actionHistory = const [],
    this.nodeStates = const {},
    this.submittedAt = '',
    this.updatedAt = '',
  });

  /// 申請人是否可編輯此 signOff。
  ///
  /// 規則：status == pending 且（無任何簽核動作 OR 最後動作為退回 / 補件）。
  /// - 從未被任何簽核者動過 → 可編輯
  /// - 被退回原申請人 → 可編輯（重跑流程）
  /// - 被要求補件 → 可編輯（流程暫停在原關卡等補完）
  /// - 簽核者已同意 / 拒絕 → 不可編輯（即使 status 還是 pending）
  bool get isEditableByApplicant {
    if (status != LeaveSignOffStatus.pending) return false;
    if (actionHistory.isEmpty) return true;
    final last = actionHistory.last.actionType;
    return last == SignOffActionType.returnBack ||
        last == SignOffActionType.requestSupplement;
  }

  SignOffInstance copyWith({
    String? signOffId,
    String? submissionId,
    String? templateId,
    String? formId,
    String? formName,
    String? applicantId,
    String? applicantName,
    String? departmentId,
    Map<String, dynamic>? fieldValues,
    Map<String, String>? computedFields,
    List<Map<String, dynamic>>? sectionsSnapshot,
    List<Map<String, dynamic>>? resolvedChainSnapshot,
    LeaveSignOffStatus? status,
    int? currentStepIndex,
    String? currentApproverId,
    String? currentApproverName,
    String? latestComment,
    List<SignOffActionRecord>? actionHistory,
    Map<String, NodeApprovalState>? nodeStates,
    String? submittedAt,
    String? updatedAt,
  }) {
    return SignOffInstance(
      signOffId: signOffId ?? this.signOffId,
      submissionId: submissionId ?? this.submissionId,
      templateId: templateId ?? this.templateId,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      departmentId: departmentId ?? this.departmentId,
      fieldValues: fieldValues ?? this.fieldValues,
      computedFields: computedFields ?? this.computedFields,
      sectionsSnapshot: sectionsSnapshot ?? this.sectionsSnapshot,
      resolvedChainSnapshot:
          resolvedChainSnapshot ?? this.resolvedChainSnapshot,
      status: status ?? this.status,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      currentApproverId: currentApproverId ?? this.currentApproverId,
      currentApproverName: currentApproverName ?? this.currentApproverName,
      latestComment: latestComment ?? this.latestComment,
      actionHistory: actionHistory ?? this.actionHistory,
      nodeStates: nodeStates ?? this.nodeStates,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sign_off_id': signOffId,
      'submission_id': submissionId,
      'template_id': templateId,
      'form_id': formId,
      'form_name': formName,
      'applicant_id': applicantId,
      'applicant_name': applicantName,
      'department_id': departmentId,
      'field_values': fieldValues,
      'computed_fields': computedFields,
      'sections_snapshot': sectionsSnapshot,
      'resolved_chain_snapshot': resolvedChainSnapshot,
      'status': status.code,
      'current_step_index': currentStepIndex,
      'current_approver_id': currentApproverId,
      'current_approver_name': currentApproverName,
      'latest_comment': latestComment,
      'action_history': actionHistory.map((r) => r.toMap()).toList(),
      'node_states': nodeStates.map((k, v) => MapEntry(k, v.toMap())),
      'submitted_at': submittedAt,
      'updated_at': updatedAt,
    };
  }

  factory SignOffInstance.fromMap(Map<String, dynamic> map) {
    return SignOffInstance(
      signOffId: map['sign_off_id']?.toString() ??
          map['signOffId']?.toString() ??
          '',
      submissionId: map['submission_id']?.toString() ??
          map['submissionId']?.toString() ??
          '',
      templateId: map['template_id']?.toString() ??
          map['templateId']?.toString() ??
          '',
      formId: map['form_id']?.toString() ?? map['formId']?.toString() ?? '',
      formName:
          map['form_name']?.toString() ?? map['formName']?.toString() ?? '',
      applicantId: map['applicant_id']?.toString() ??
          map['applicantId']?.toString() ??
          '',
      applicantName: map['applicant_name']?.toString() ??
          map['applicantName']?.toString() ??
          '',
      departmentId: map['department_id']?.toString() ??
          map['departmentId']?.toString() ??
          '',
      fieldValues: _parseMap(map['field_values'] ?? map['fieldValues']),
      computedFields:
          _parseStringMap(map['computed_fields'] ?? map['computedFields']),
      sectionsSnapshot: _parseSectionsSnapshot(
        map['sections_snapshot'] ?? map['sectionsSnapshot'],
      ),
      resolvedChainSnapshot: _parseSectionsSnapshot(
        map['resolved_chain_snapshot'] ?? map['resolvedChainSnapshot'],
      ),
      status: LeaveSignOffStatusX.fromCode(map['status']?.toString()),
      currentStepIndex: (map['current_step_index'] as num?)?.toInt() ??
          (map['currentStepIndex'] as num?)?.toInt() ??
          0,
      currentApproverId: map['current_approver_id']?.toString() ??
          map['currentApproverId']?.toString() ??
          '',
      currentApproverName: map['current_approver_name']?.toString() ??
          map['currentApproverName']?.toString() ??
          '',
      latestComment: map['latest_comment']?.toString() ??
          map['latestComment']?.toString() ??
          '',
      actionHistory: _parseActionHistory(
        map['action_history'] ?? map['actionHistory'],
      ),
      nodeStates: _parseNodeStates(
        map['node_states'] ?? map['nodeStates'],
      ),
      submittedAt: map['submitted_at']?.toString() ??
          map['submittedAt']?.toString() ??
          '',
      updatedAt: map['updated_at']?.toString() ??
          map['updatedAt']?.toString() ??
          '',
    );
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return const {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static Map<String, String> _parseStringMap(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      return value
          .map((k, v) => MapEntry(k.toString(), (v ?? '').toString()));
    }
    return const {};
  }

  static List<Map<String, dynamic>> _parseSectionsSnapshot(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }
    return const [];
  }

  static List<SignOffActionRecord> _parseActionHistory(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => SignOffActionRecord.fromMap(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    }
    return const [];
  }

  static Map<String, NodeApprovalState> _parseNodeStates(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      final result = <String, NodeApprovalState>{};
      value.forEach((k, v) {
        if (v is Map) {
          result[k.toString()] =
              NodeApprovalState.fromMap(Map<String, dynamic>.from(v));
        }
      });
      return result;
    }
    return const {};
  }

  @override
  List<Object> get props => [
        signOffId,
        submissionId,
        templateId,
        formId,
        formName,
        applicantId,
        applicantName,
        departmentId,
        fieldValues,
        computedFields,
        sectionsSnapshot,
        resolvedChainSnapshot,
        status,
        currentStepIndex,
        currentApproverId,
        currentApproverName,
        latestComment,
        actionHistory,
        nodeStates,
        submittedAt,
        updatedAt,
      ];
}
