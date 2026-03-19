/// 按鈕元件的寬度模式。
/// 用於 [DesignerItem.buttonWidthMode]，控制按鈕在列中的寬度行為。
enum ButtonWidthMode {
  /// 撐滿整個欄位寬度
  fill,

  /// 依按鈕內容自適應寬度，並可透過 [DesignerItem.buttonWidth] 自訂固定寬度
  hug,
}
