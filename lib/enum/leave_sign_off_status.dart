/// 請假簽核狀態。
enum LeaveSignOffStatus {
  /// 待簽核 — 已送出但尚未進入任何簽核者
  pending,

  /// 簽核中 — 流程進行中，等待當前關卡決策
  inReview,

  /// 已通過 — 全部關卡完成且皆同意
  approved,

  /// 已拒絕 — 任一關卡拒絕，流程終止
  rejected,

  /// 已撤回 — 申請人主動撤回
  withdrawn,
}

extension LeaveSignOffStatusX on LeaveSignOffStatus {
  String get code {
    switch (this) {
      case LeaveSignOffStatus.pending:
        return 'pending';
      case LeaveSignOffStatus.inReview:
        return 'inReview';
      case LeaveSignOffStatus.approved:
        return 'approved';
      case LeaveSignOffStatus.rejected:
        return 'rejected';
      case LeaveSignOffStatus.withdrawn:
        return 'withdrawn';
    }
  }

  String get label {
    switch (this) {
      case LeaveSignOffStatus.pending:
        return '待簽核';
      case LeaveSignOffStatus.inReview:
        return '簽核中';
      case LeaveSignOffStatus.approved:
        return '已通過';
      case LeaveSignOffStatus.rejected:
        return '已拒絕';
      case LeaveSignOffStatus.withdrawn:
        return '已撤回';
    }
  }

  static LeaveSignOffStatus fromCode(String? code) {
    switch (code) {
      case 'inReview':
        return LeaveSignOffStatus.inReview;
      case 'approved':
        return LeaveSignOffStatus.approved;
      case 'rejected':
        return LeaveSignOffStatus.rejected;
      case 'withdrawn':
        return LeaveSignOffStatus.withdrawn;
      case 'pending':
      default:
        return LeaveSignOffStatus.pending;
    }
  }
}
