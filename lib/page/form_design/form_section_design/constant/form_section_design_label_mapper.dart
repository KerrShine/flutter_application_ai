import 'package:flutter_application_ai/model/designer_item.dart';

/// 表單欄位設計頁的顯示文字轉換工具。
///
/// 作用：將 enum 值轉換成 UI 顯示文字，避免各 widget 重複撰寫 switch。
class FormSectionDesignLabelMapper {
  const FormSectionDesignLabelMapper._();

  /// 將 [DesignerItemAlignment] 轉為對齊顯示文字。
  static String alignmentLabel(DesignerItemAlignment alignment) {
    switch (alignment) {
      case DesignerItemAlignment.topLeft:
        return 'Top Left';
      case DesignerItemAlignment.topCenter:
        return 'Top Center';
      case DesignerItemAlignment.topRight:
        return 'Top Right';
      case DesignerItemAlignment.centerLeft:
        return 'Center Left';
      case DesignerItemAlignment.center:
        return 'Center';
      case DesignerItemAlignment.centerRight:
        return 'Center Right';
      case DesignerItemAlignment.bottomLeft:
        return 'Bottom Left';
      case DesignerItemAlignment.bottomCenter:
        return 'Bottom Center';
      case DesignerItemAlignment.bottomRight:
        return 'Bottom Right';
    }
  }

  /// 將 [DesignerItemOptionLayout] 轉為選項布局顯示文字。
  static String optionLayoutLabel(DesignerItemOptionLayout layout) {
    switch (layout) {
      case DesignerItemOptionLayout.horizontal:
        return '水平';
      case DesignerItemOptionLayout.vertical:
        return '垂直';
    }
  }

  /// 將 [ButtonWidthMode] 轉為寬度模式顯示文字。
  static String buttonWidthModeLabel(ButtonWidthMode mode) {
    switch (mode) {
      case ButtonWidthMode.fill:
        return 'Fill';
      case ButtonWidthMode.hug:
        return 'Hug';
    }
  }
}
