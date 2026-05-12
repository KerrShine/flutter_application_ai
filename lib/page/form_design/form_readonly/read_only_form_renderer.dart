import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_readonly/read_only_section_widget.dart';

/// 通用「已送出表單」唯讀渲染容器。
///
/// 給定 sections 結構（通常來自 submission 的 sectionsSnapshot 反序列化）
/// 與 fieldValues / computedFields，輸出完整唯讀表單 UI。
///
/// 使用情境：
/// - 我的申請 — 點開 submission 看自己送出內容
/// - 待我簽核 — 簽核者檢視待簽 submission
/// - 簽核軌跡 — 已結案 submission 的歷史檢視
///
/// 設計原則：
/// - **無 BLoC、無事件**：純展示元件，呼叫端決定資料來源
/// - **與表單種類解耦**：給定 sections + values 即可渲染，不論請假/報帳/簽呈
/// - **欄位型別擴展點集中於 factory**：未來新增 designer item type 只改
///   [ReadOnlyFieldWidgetFactory] 一處
class ReadOnlyFormRenderer extends StatelessWidget {
  final List<SectionModel> sections;
  final Map<String, dynamic> fieldValues;
  final Map<String, String> computedFields;
  final EdgeInsets padding;

  const ReadOnlyFormRenderer({
    super.key,
    required this.sections,
    required this.fieldValues,
    this.computedFields = const {},
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Padding(
        padding: padding,
        child: Text(
          '無表單內容可顯示',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: sections
            .map(
              (section) => ReadOnlySectionWidget(
                section: section,
                fieldValues: fieldValues,
                computedValues: computedFields,
              ),
            )
            .toList(),
      ),
    );
  }
}
