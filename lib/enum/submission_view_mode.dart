/// 申請詳情頁的顯示模式 — 區分申請人檢視 vs 簽核者審核。
enum SubmissionViewMode {
  /// 申請人視角 — 從「我的申請」進來，可看編輯按鈕（依 isEditableByApplicant）。
  viewer,

  /// 簽核者視角 — 從「待我簽核」進來，顯示動作面板（同意 / 拒絕 / 退回）。
  reviewer,
}

extension SubmissionViewModeX on SubmissionViewMode {
  String get code {
    switch (this) {
      case SubmissionViewMode.viewer:
        return 'viewer';
      case SubmissionViewMode.reviewer:
        return 'reviewer';
    }
  }

  static SubmissionViewMode fromCode(String? code) {
    switch (code) {
      case 'reviewer':
        return SubmissionViewMode.reviewer;
      case 'viewer':
      default:
        return SubmissionViewMode.viewer;
    }
  }
}
