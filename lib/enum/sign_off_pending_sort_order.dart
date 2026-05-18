enum SignOffPendingSortOrder {
  submittedAtDesc,
  submittedAtAsc,
  updatedAtDesc,
  updatedAtAsc,
}

extension SignOffPendingSortOrderX on SignOffPendingSortOrder {
  String get label {
    switch (this) {
      case SignOffPendingSortOrder.submittedAtDesc:
        return '送出時間 新→舊';
      case SignOffPendingSortOrder.submittedAtAsc:
        return '送出時間 舊→新';
      case SignOffPendingSortOrder.updatedAtDesc:
        return '更新時間 新→舊';
      case SignOffPendingSortOrder.updatedAtAsc:
        return '更新時間 舊→新';
    }
  }
}
