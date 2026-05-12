import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/theme/dynamic_form_field_theme.dart';

/// 通用唯讀欄位工廠 — 任何已送出的表單資料皆可透過此工廠渲染為唯讀檢視。
///
/// 與 form_run / form_browse 的工廠不同：
/// - form_run：可互動，readonly 旗標僅影響部分欄位
/// - form_browse：設計時預覽，TextField 仍可點擊（並非真唯讀）
/// - **本工廠：真正唯讀，所有欄位不接互動回呼，純呈現已存值**
///
/// 渲染策略：
/// - textField / textArea / datePicker → `TextField(readOnly: true, enabled: false)` 包 fieldShell
/// - dropdown / radio → 純文字顯示已選值
/// - checkbox → 顯示已勾選 options（逗號串接）
/// - label → 純文字（支援 computedFieldKey 取代）
/// - button → 隱藏
/// - fileUpload → 顯示「已上傳 N 個檔案」+ 檔名列表
class ReadOnlyFieldWidgetFactory {
  static Widget buildReadOnlyField({
    required BuildContext context,
    required DesignerItem item,
    required String value,
    Map<String, String> computedValues = const {},
  }) {
    return Container(
      padding: EdgeInsets.all(item.padding),
      alignment: item.alignment.value,
      child: _buildContent(context, item, value, computedValues),
    );
  }

  static Widget _buildContent(
    BuildContext context,
    DesignerItem item,
    String value,
    Map<String, String> computedValues,
  ) {
    final theme = Theme.of(context);
    final primaryTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.black87;

    switch (item.type) {
      case DesignerItemType.label:
        return _buildLabel(item, primaryTextColor, computedValues);

      case DesignerItemType.textField:
        return DynamicFormFieldTheme.buildFieldShell(
          context: context,
          item: item,
          child: _buildValueDisplay(context, item, value),
        );

      case DesignerItemType.textArea:
        return DynamicFormFieldTheme.buildFieldShell(
          context: context,
          item: item,
          child: _buildValueDisplay(
            context,
            item,
            value,
            minHeight: item.textAreaHeight,
            isMultiline: true,
          ),
        );

      case DesignerItemType.dropdown:
        return DynamicFormFieldTheme.buildFieldShell(
          context: context,
          item: item,
          child: _buildValueDisplay(context, item, value),
        );

      case DesignerItemType.datePicker:
        return DynamicFormFieldTheme.buildFieldShell(
          context: context,
          item: item,
          child: _buildValueDisplay(context, item, value),
        );

      case DesignerItemType.radio:
        return _buildRadioReadOnly(item, value, primaryTextColor);

      case DesignerItemType.checkbox:
        return _buildCheckboxReadOnly(item, value, primaryTextColor);

      case DesignerItemType.button:
        // 唯讀檢視不顯示按鈕（按鈕在唯讀模式無意義）
        return const SizedBox.shrink();

      case DesignerItemType.fileUpload:
        return _buildFileUploadReadOnly(context, item, value);
    }
  }

  // ── label 渲染 ──────────────────────────────────────────────
  static Widget _buildLabel(
    DesignerItem item,
    Color textColor,
    Map<String, String> computedValues,
  ) {
    // 與 form_run_widget_factory 同步邏輯：computedFieldKey 非空時，
    // - 若 item.text 含 `{value}` 占位符 → 用計算結果取代占位符
    //   （例如「共 {value} 天」→「共 -1 天」，保留前後說明文字）
    // - 否則 fallback 為純值顯示
    String displayText = item.text;
    if (item.computedFieldKey.isNotEmpty) {
      final value = computedValues[item.computedFieldKey] ?? '';
      displayText = item.text.contains('{value}')
          ? item.text.replaceAll('{value}', value)
          : value;
    }
    return Text(
      displayText,
      style: TextStyle(
        fontSize: item.fontSize,
        fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
        color: textColor,
      ),
      textAlign: _toTextAlign(item.alignment),
    );
  }

  // ── 統一值顯示元件：textField / textArea / dropdown / datePicker 共用 ──
  static Widget _buildValueDisplay(
    BuildContext context,
    DesignerItem item,
    String value, {
    double? minHeight,
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);
    final isEmpty = value.isEmpty;
    // 注意：不要對 Text 設 TextStyle.height — 它與 Flutter 的 intrinsic height
    // 計算不一致，會造成「BOTTOM OVERFLOWED BY N PIXELS」溢出（已驗證 4px）。
    final content = Text(
      isEmpty ? '(未填寫)' : value,
      style: TextStyle(
        fontSize: item.fontSize,
        color: isEmpty
            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
            : theme.colorScheme.onSurface,
      ),
      maxLines: isMultiline ? null : 1,
      overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
    );
    return Container(
      width: double.infinity,
      constraints: minHeight != null
          ? BoxConstraints(minHeight: minHeight)
          : null,
      padding: DynamicFormFieldTheme.fieldContentPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius:
            BorderRadius.circular(DynamicFormFieldTheme.fieldRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      alignment: isMultiline ? Alignment.topLeft : Alignment.centerLeft,
      child: content,
    );
  }

  // ── Radio：顯示已選 option + ✓ 前綴 ───────────────────────
  static Widget _buildRadioReadOnly(
    DesignerItem item,
    String value,
    Color textColor,
  ) {
    final title = item.isGrouped && item.text.isNotEmpty ? item.text : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: item.fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (value.isEmpty)
          Text(
            '(未選擇)',
            style: TextStyle(
              fontSize: item.fontSize,
              color: textColor.withValues(alpha: 0.4),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 18, color: textColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(fontSize: item.fontSize, color: textColor),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ── Checkbox：顯示已勾選 options（逗號串接） ─────────────
  static Widget _buildCheckboxReadOnly(
    DesignerItem item,
    String value,
    Color textColor,
  ) {
    final title = item.isGrouped && item.text.isNotEmpty ? item.text : '';
    // value 預期是逗號分隔字串（form_run 寫入習慣）。也容忍其他分隔。
    final selected = value
        .split(RegExp(r'[,，;|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: item.fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (selected.isEmpty)
          Text(
            '(未勾選)',
            style: TextStyle(
              fontSize: item.fontSize,
              color: textColor.withValues(alpha: 0.4),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: selected
                .map(
                  (label) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_box, size: 18, color: textColor),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: item.fontSize,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  // ── FileUpload：顯示「已上傳 N 個檔案」+ 檔名列表 ────────
  static Widget _buildFileUploadReadOnly(
    BuildContext context,
    DesignerItem item,
    String value,
  ) {
    final theme = Theme.of(context);
    // value 預期為逗號分隔的檔名清單；空字串視為未上傳
    final files = value
        .split(RegExp(r'[,;|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return DynamicFormFieldTheme.buildFieldShell(
      context: context,
      item: item,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                files.isEmpty ? Icons.upload_file : Icons.attach_file,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                files.isEmpty ? '(未上傳檔案)' : '已上傳 ${files.length} 個檔案',
                style: TextStyle(
                  fontSize: item.fontSize,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: files.isEmpty ? 0.4 : 0.8),
                ),
              ),
            ],
          ),
          if (files.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...files.map(
              (name) => Padding(
                padding: const EdgeInsets.only(left: 22, top: 2),
                child: Text(
                  '• $name',
                  style: TextStyle(
                    fontSize: item.fontSize - 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static TextAlign _toTextAlign(DesignerItemAlignment alignment) {
    switch (alignment) {
      case DesignerItemAlignment.topLeft:
      case DesignerItemAlignment.centerLeft:
      case DesignerItemAlignment.bottomLeft:
        return TextAlign.left;
      case DesignerItemAlignment.topCenter:
      case DesignerItemAlignment.center:
      case DesignerItemAlignment.bottomCenter:
        return TextAlign.center;
      case DesignerItemAlignment.topRight:
      case DesignerItemAlignment.centerRight:
      case DesignerItemAlignment.bottomRight:
        return TextAlign.right;
    }
  }
}
