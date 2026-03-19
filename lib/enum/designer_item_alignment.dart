import 'package:flutter/material.dart';

/// 元件在欄位內的對齊方式（九宮格）。
/// 用於 [DesignerItem.alignment]，控制元件內容在容器中的位置。
enum DesignerItemAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// 將 [DesignerItemAlignment] 轉換為 Flutter [Alignment]
extension DesignerItemAlignmentExtension on DesignerItemAlignment {
  Alignment get value {
    switch (this) {
      case DesignerItemAlignment.topLeft:
        return Alignment.topLeft;
      case DesignerItemAlignment.topCenter:
        return Alignment.topCenter;
      case DesignerItemAlignment.topRight:
        return Alignment.topRight;
      case DesignerItemAlignment.centerLeft:
        return Alignment.centerLeft;
      case DesignerItemAlignment.center:
        return Alignment.center;
      case DesignerItemAlignment.centerRight:
        return Alignment.centerRight;
      case DesignerItemAlignment.bottomLeft:
        return Alignment.bottomLeft;
      case DesignerItemAlignment.bottomCenter:
        return Alignment.bottomCenter;
      case DesignerItemAlignment.bottomRight:
        return Alignment.bottomRight;
    }
  }
}
