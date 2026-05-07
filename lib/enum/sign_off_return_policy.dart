/// 簽核退回策略。
enum SignOffReturnPolicy {
  /// 退回申請人
  toApplicant,

  /// 退回上一關
  toPrevious,

  /// 退回指定關卡（搭配 returnTargetNodeId）
  toSpecific,
}

extension SignOffReturnPolicyX on SignOffReturnPolicy {
  String get code {
    switch (this) {
      case SignOffReturnPolicy.toApplicant:
        return 'toApplicant';
      case SignOffReturnPolicy.toPrevious:
        return 'toPrevious';
      case SignOffReturnPolicy.toSpecific:
        return 'toSpecific';
    }
  }

  String get label {
    switch (this) {
      case SignOffReturnPolicy.toApplicant:
        return '退回申請人';
      case SignOffReturnPolicy.toPrevious:
        return '退回上一關';
      case SignOffReturnPolicy.toSpecific:
        return '退回指定關卡';
    }
  }

  static SignOffReturnPolicy fromCode(String? code) {
    switch (code) {
      case 'toPrevious':
        return SignOffReturnPolicy.toPrevious;
      case 'toSpecific':
        return SignOffReturnPolicy.toSpecific;
      case 'toApplicant':
      default:
        return SignOffReturnPolicy.toApplicant;
    }
  }
}
