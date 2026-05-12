import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/sign_off_action_type.dart';

export 'package:flutter_application_ai/enum/sign_off_action_type.dart';

/// 單筆簽核動作軌跡。
///
/// 每當簽核者執行 [SignOffActionType] 中任一動作，即追加一筆 [SignOffActionRecord]
/// 至 LeaveSignOffModel.actionHistory，供「我的申請 / 待我簽核 / 簽核軌跡」檢視。
class SignOffActionRecord extends Equatable {
  final String recordId;
  final SignOffActionType actionType;
  final String approverId;
  final String approverName;

  /// 簽核者填寫的意見/說明。
  final String comment;

  /// 動作執行時間（ISO 8601 字串）。
  final String actionAt;

  /// 若 actionType 為 returnBack / transfer / addApprover，記錄目標對象 ID。
  ///
  /// 退回 → 目標節點 nodeId；轉派 / 加簽 → 目標簽核者 employeeId。
  /// 其他動作此欄位為空。
  final String targetRef;

  const SignOffActionRecord({
    this.recordId = '',
    this.actionType = SignOffActionType.approve,
    this.approverId = '',
    this.approverName = '',
    this.comment = '',
    this.actionAt = '',
    this.targetRef = '',
  });

  SignOffActionRecord copyWith({
    String? recordId,
    SignOffActionType? actionType,
    String? approverId,
    String? approverName,
    String? comment,
    String? actionAt,
    String? targetRef,
  }) {
    return SignOffActionRecord(
      recordId: recordId ?? this.recordId,
      actionType: actionType ?? this.actionType,
      approverId: approverId ?? this.approverId,
      approverName: approverName ?? this.approverName,
      comment: comment ?? this.comment,
      actionAt: actionAt ?? this.actionAt,
      targetRef: targetRef ?? this.targetRef,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'record_id': recordId,
      'action_type': actionType.code,
      'approver_id': approverId,
      'approver_name': approverName,
      'comment': comment,
      'action_at': actionAt,
      'target_ref': targetRef,
    };
  }

  factory SignOffActionRecord.fromMap(Map<String, dynamic> map) {
    return SignOffActionRecord(
      recordId:
          map['record_id']?.toString() ?? map['recordId']?.toString() ?? '',
      actionType: SignOffActionTypeX.fromCode(
        map['action_type']?.toString() ?? map['actionType']?.toString(),
      ),
      approverId: map['approver_id']?.toString() ??
          map['approverId']?.toString() ??
          '',
      approverName: map['approver_name']?.toString() ??
          map['approverName']?.toString() ??
          '',
      comment: map['comment']?.toString() ?? '',
      actionAt:
          map['action_at']?.toString() ?? map['actionAt']?.toString() ?? '',
      targetRef:
          map['target_ref']?.toString() ?? map['targetRef']?.toString() ?? '',
    );
  }

  @override
  List<Object> get props => [
        recordId,
        actionType,
        approverId,
        approverName,
        comment,
        actionAt,
        targetRef,
      ];
}
