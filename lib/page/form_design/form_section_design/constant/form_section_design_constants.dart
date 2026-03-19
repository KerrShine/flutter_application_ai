/// 表單欄位設計頁的固定選項常數。
///
/// 目的：集中管理 UI 下拉選單固定資料，減少頁面檔案噪音，提升可讀性。
class FormSectionDesignConstants {
  const FormSectionDesignConstants._();

  /// 基本屬性：文字大小選項（px）
  static const List<double> fontSizeOptions = [
    12.0,
    14.0,
    16.0,
    18.0,
    20.0,
    24.0,
    28.0,
    32.0,
  ];

  /// 基本屬性：欄位寬度比例
  static const List<double> widthPercentageOptions = [
    1.0,
    0.75,
    0.5,
    0.25,
  ];

  /// 基本屬性：最大字數選項（0 代表不限制）
  static const List<int> maxLengthOptions = [
    0,
    20,
    50,
    100,
    200,
    500,
    1000,
  ];

  /// 基本屬性：檔案單檔大小上限（MB，0 代表不限制）
  static const List<int> fileMaxSizeOptions = [
    0,
    1,
    2,
    5,
    10,
    20,
    50,
    100,
  ];

  /// 排版設定：內距（px）
  static const List<double> paddingOptions = [
    0,
    4,
    8,
    12,
    16,
    20,
    24,
    32,
  ];

  /// 排版設定：按鈕寬度（px）
  static const List<double> buttonWidthOptions = [
    80,
    100,
    120,
    140,
    160,
    180,
    200,
    240,
    280,
  ];

  /// 排版設定：文字區高度（px）
  static const List<double> textAreaHeightOptions = [
    80,
    120,
    160,
    200,
    240,
  ];

  /// 排版設定：群組選項間距（px）
  static const List<double> optionSpacingOptions = [
    0,
    4,
    8,
    12,
    16,
    20,
    24,
    32,
  ];

  /// 正規化文字大小：若值不存在於可選清單，回退至 14。
  static double normalizeFontSize(double fontSize) {
    if (fontSizeOptions.contains(fontSize)) {
      return fontSize;
    }
    return 14;
  }

  /// 正規化內距：若值不存在於可選清單，回退至 8。
  static double normalizePadding(double padding) {
    if (paddingOptions.contains(padding)) {
      return padding;
    }
    return 8;
  }

  /// 正規化按鈕寬度：若值不存在於可選清單，回退至 160。
  static double normalizeButtonWidth(double width) {
    if (buttonWidthOptions.contains(width)) {
      return width;
    }
    return 160;
  }

  /// 正規化文字區高度：若值不存在於可選清單，回退至 120。
  static double normalizeTextAreaHeight(double height) {
    if (textAreaHeightOptions.contains(height)) {
      return height;
    }
    return 120;
  }

  /// 正規化群組選項間距：若值不存在於可選清單，回退至 8。
  static double normalizeOptionSpacing(double spacing) {
    if (optionSpacingOptions.contains(spacing)) {
      return spacing;
    }
    return 8;
  }

  /// 正規化最大字數：若值不存在於可選清單，回退至 0（不限制）。
  static int normalizeMaxLength(int maxLength) {
    if (maxLengthOptions.contains(maxLength)) {
      return maxLength;
    }
    return 0;
  }

  /// 正規化檔案大小上限：若值不存在於可選清單，回退至 0（不限制）。
  static int normalizeFileMaxSize(int maxSize) {
    if (fileMaxSizeOptions.contains(maxSize)) {
      return maxSize;
    }
    return 0;
  }
}
