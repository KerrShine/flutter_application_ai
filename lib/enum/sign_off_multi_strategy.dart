/// 會簽多人策略。
enum SignOffMultiStrategy {
  /// 全部同意（AND）
  all,

  /// 任一同意（OR）
  any,

  /// 依序簽核
  sequential,
}

extension SignOffMultiStrategyX on SignOffMultiStrategy {
  String get code {
    switch (this) {
      case SignOffMultiStrategy.all:
        return 'all';
      case SignOffMultiStrategy.any:
        return 'any';
      case SignOffMultiStrategy.sequential:
        return 'sequential';
    }
  }

  String get label {
    switch (this) {
      case SignOffMultiStrategy.all:
        return '全部同意';
      case SignOffMultiStrategy.any:
        return '任一同意';
      case SignOffMultiStrategy.sequential:
        return '依序簽核';
    }
  }

  static SignOffMultiStrategy fromCode(String? code) {
    switch (code) {
      case 'any':
        return SignOffMultiStrategy.any;
      case 'sequential':
        return SignOffMultiStrategy.sequential;
      case 'all':
      default:
        return SignOffMultiStrategy.all;
    }
  }
}
