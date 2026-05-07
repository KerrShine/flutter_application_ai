/// 簽核節點類型。
enum SignOffNodeType {
  /// 審核 — 單一節點，一人決策（同意/拒絕/退回）
  approve,

  /// 會簽 — 多人決策，依 multiStrategy 收斂
  countersign,

  /// 知會 — 只通知不影響流程，留痕
  notify,
}

extension SignOffNodeTypeX on SignOffNodeType {
  String get code {
    switch (this) {
      case SignOffNodeType.approve:
        return 'approve';
      case SignOffNodeType.countersign:
        return 'countersign';
      case SignOffNodeType.notify:
        return 'notify';
    }
  }

  String get label {
    switch (this) {
      case SignOffNodeType.approve:
        return '審核';
      case SignOffNodeType.countersign:
        return '會簽';
      case SignOffNodeType.notify:
        return '知會';
    }
  }

  static SignOffNodeType fromCode(String? code) {
    switch (code) {
      case 'countersign':
        return SignOffNodeType.countersign;
      case 'notify':
        return SignOffNodeType.notify;
      case 'approve':
      default:
        return SignOffNodeType.approve;
    }
  }
}
