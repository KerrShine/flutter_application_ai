import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/leave_sign_off_status.dart';
import 'package:flutter_application_ai/model/sign_off_action_record.dart';

export 'package:flutter_application_ai/enum/leave_sign_off_status.dart';
export 'package:flutter_application_ai/model/sign_off_action_record.dart';

/// 請假簽核資料模型。
///
/// 由 [FormSubmissionModel] 衍生，攜帶完整 form 資料與簽核流程狀態，
/// 供「待我簽核」/「我的申請」/「簽核軌跡」等簽核相關頁面共用。
class LeaveSignOffModel extends Equatable {
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

  // === 簽核狀態 ===
  final LeaveSignOffStatus status;
  final String currentApproverId;
  final String currentApproverName;
  final String latestComment;

  /// 簽核軌跡 — 按時間順序追加，最新一筆在最後。
  final List<SignOffActionRecord> actionHistory;

  // === 時間 ===
  final String submittedAt;
  final String updatedAt;

  const LeaveSignOffModel({
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
    this.status = LeaveSignOffStatus.pending,
    this.currentApproverId = '',
    this.currentApproverName = '',
    this.latestComment = '',
    this.actionHistory = const [],
    this.submittedAt = '',
    this.updatedAt = '',
  });

  LeaveSignOffModel copyWith({
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
    LeaveSignOffStatus? status,
    String? currentApproverId,
    String? currentApproverName,
    String? latestComment,
    List<SignOffActionRecord>? actionHistory,
    String? submittedAt,
    String? updatedAt,
  }) {
    return LeaveSignOffModel(
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
      status: status ?? this.status,
      currentApproverId: currentApproverId ?? this.currentApproverId,
      currentApproverName: currentApproverName ?? this.currentApproverName,
      latestComment: latestComment ?? this.latestComment,
      actionHistory: actionHistory ?? this.actionHistory,
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
      'status': status.code,
      'current_approver_id': currentApproverId,
      'current_approver_name': currentApproverName,
      'latest_comment': latestComment,
      'action_history': actionHistory.map((r) => r.toMap()).toList(),
      'submitted_at': submittedAt,
      'updated_at': updatedAt,
    };
  }

  factory LeaveSignOffModel.fromMap(Map<String, dynamic> map) {
    return LeaveSignOffModel(
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
      status: LeaveSignOffStatusX.fromCode(map['status']?.toString()),
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
        status,
        currentApproverId,
        currentApproverName,
        latestComment,
        actionHistory,
        submittedAt,
        updatedAt,
      ];
}
