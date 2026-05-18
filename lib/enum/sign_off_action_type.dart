/// 簽核者可執行的動作類型。
///
/// 對應 `docs/system_docs/system/sign_off_system.md` 規格章節「動作與軌跡」：
/// 同意 / 拒絕 / 退回 / 補件要求 / 轉派 / 加簽。
enum SignOffActionType {
  /// 同意 — 進入下一節點或結案
  approve,

  /// 拒絕 — 流程終止
  reject,

  /// 退回 — 依規則回到指定節點（申請人 / 上一關 / 指定關卡）
  returnBack,

  /// 補件要求 — 暫停流程，要求申請人補上附件或補充資料
  requestSupplement,

  /// 轉派 — 將當前關卡交給另一位簽核者（發錯人處理）
  transfer,

  /// 加簽 — 在當前節點之後追加額外簽核者，需留痕
  addApprover,

  /// 自動通知 — 系統推進到 notify 知會節點時自動產生的軌跡，
  /// 表示「該節點已通知對應人 + 流程不停直接推進」。非使用者主動動作。
  autoNotify,
}

extension SignOffActionTypeX on SignOffActionType {
  String get code {
    switch (this) {
      case SignOffActionType.approve:
        return 'approve';
      case SignOffActionType.reject:
        return 'reject';
      case SignOffActionType.returnBack:
        return 'return';
      case SignOffActionType.requestSupplement:
        return 'requestSupplement';
      case SignOffActionType.transfer:
        return 'transfer';
      case SignOffActionType.addApprover:
        return 'addApprover';
      case SignOffActionType.autoNotify:
        return 'autoNotify';
    }
  }

  String get label {
    switch (this) {
      case SignOffActionType.approve:
        return '同意';
      case SignOffActionType.reject:
        return '拒絕';
      case SignOffActionType.returnBack:
        return '退回';
      case SignOffActionType.requestSupplement:
        return '補件要求';
      case SignOffActionType.transfer:
        return '轉派';
      case SignOffActionType.addApprover:
        return '加簽';
      case SignOffActionType.autoNotify:
        return '自動通知';
    }
  }

  static SignOffActionType fromCode(String? code) {
    switch (code) {
      case 'reject':
        return SignOffActionType.reject;
      case 'return':
      case 'returnBack':
        return SignOffActionType.returnBack;
      case 'requestSupplement':
        return SignOffActionType.requestSupplement;
      case 'transfer':
        return SignOffActionType.transfer;
      case 'addApprover':
        return SignOffActionType.addApprover;
      case 'autoNotify':
        return SignOffActionType.autoNotify;
      case 'approve':
      default:
        return SignOffActionType.approve;
    }
  }
}
