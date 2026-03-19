/// 表單建立頁固定常數。
///
/// 目的：集中管理固定下拉選項，避免頁面檔案出現過多硬編碼資料。
class FormCreateConstants {
  const FormCreateConstants._();

  /// 表單尺寸選項
  static const List<String> sizeOptions = [
    'A4',
    'Letter',
    'Mobile Portrait',
    '1920x1080',
    'Custom',
  ];
}
