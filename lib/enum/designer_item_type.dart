/// 表單設計器中可拖曳放置的元件種類。
/// 用於 [DesignerItem.type]，決定畫布上每個欄位的呈現方式。
enum DesignerItemType {
  /// 純文字標籤（不可輸入）
  label,

  /// 單行文字輸入欄
  textField,

  /// 多行文字輸入區域
  textArea,

  /// 單選按鈕（Radio Button）
  radio,

  /// 多選核取方塊（Checkbox）
  checkbox,

  /// 下拉選擇器
  dropdown,

  /// 操作按鈕
  button,

  /// 日期選擇器
  datePicker,

  /// 檔案上傳元件
  fileUpload,
}
