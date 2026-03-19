/// 單選／複選選項的排列方向。
/// 用於 [DesignerItem.optionLayout]，決定選項清單以水平或垂直方式呈現。
enum DesignerItemOptionLayout {
  /// 選項橫向並排（Wrap 排列）
  horizontal,

  /// 選項縱向堆疊（每選項占一列）
  vertical,
}
