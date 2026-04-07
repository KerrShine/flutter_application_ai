import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/theme/dynamic_form_field_theme.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';
import 'package:flutter_application_ai/unit/color_hex_utils.dart';

class DesignerItemRowWidget extends StatelessWidget {
  final DesignerItem item;
  final int index;
  final bool isSelected;

  const DesignerItemRowWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;
    final borderColor =
        isSelected ? themeColors.selectedBorder : themeColors.border;
    final borderWidth = isSelected ? 2.0 : 1.0;

    return InkWell(
      onTap: () => context.read<FormSectionDesignBloc>().add(
            SelectDesignerItemEvent(item.id),
          ),
      child: Container(
        padding: EdgeInsets.all(item.padding),
        alignment: item.alignment.value,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(6),
          color: isSelected ? themeColors.selectedFill : themeColors.surface,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? themeColors.selectedShadow
                  : themeColors.panelShadow,
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;
    final placeholder = item.placeholder.trim();
    final maxLength = item.maxLength <= 0 ? null : item.maxLength;
    switch (item.type) {
      case DesignerItemType.label:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.label_outline, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: item.fontSize,
                  fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.drag_handle, color: themeColors.dragHandle),
          ],
        );
      case DesignerItemType.textField:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 34),
              child: Icon(Icons.text_fields, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DynamicFormFieldTheme.buildFieldShell(
                context: context,
                item: item,
                child: TextField(
                  enabled: false,
                  maxLength: maxLength,
                  style: DynamicFormFieldTheme.inputTextStyle(context, item),
                  decoration: DynamicFormFieldTheme.decoration(
                    context: context,
                    item: item,
                    hintText: placeholder.isEmpty ? null : placeholder,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 34),
              child: Icon(Icons.drag_handle, color: themeColors.dragHandle),
            ),
          ],
        );
      case DesignerItemType.textArea:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.notes, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DynamicFormFieldTheme.buildFieldShell(
                context: context,
                item: item,
                child: SizedBox(
                  height: item.textAreaHeight,
                  child: TextField(
                    enabled: false,
                    maxLength: maxLength,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: DynamicFormFieldTheme.inputTextStyle(context, item),
                    decoration: DynamicFormFieldTheme.decoration(
                      context: context,
                      item: item,
                      hintText: placeholder.isNotEmpty
                          ? placeholder
                          : (item.fieldName.isEmpty ? null : item.fieldName),
                      isMultiline: true,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.drag_handle, color: themeColors.dragHandle),
            ),
          ],
        );
      case DesignerItemType.radio:
        return _buildChoiceRow(context, isRadio: true);
      case DesignerItemType.checkbox:
        return _buildChoiceRow(context, isRadio: false);
      case DesignerItemType.dropdown:
        return _buildDropdownRow(context);
      case DesignerItemType.datePicker:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 34),
              child: Icon(Icons.calendar_today, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DynamicFormFieldTheme.buildFieldShell(
                context: context,
                item: item,
                child: TextField(
                  enabled: false,
                  style: DynamicFormFieldTheme.inputTextStyle(context, item),
                  decoration: DynamicFormFieldTheme.decoration(
                    context: context,
                    item: item,
                    hintText:
                        placeholder.isNotEmpty ? placeholder : item.dateFormat,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 34),
              child: Icon(Icons.drag_handle, color: themeColors.dragHandle),
            ),
          ],
        );
      case DesignerItemType.fileUpload:
        return _buildFileUploadRow(context);
      case DesignerItemType.button:
        return _buildButtonRow(context);
    }
  }

  Widget _buildDropdownRow(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;
    final placeholder = item.placeholder.trim();
    final optionLabels = item.options.isEmpty ? const ['選項1'] : item.options;
    final hasRemoteSource = item.dataSourceUrl.trim().isNotEmpty;
    final hintParts = <String>[];

    if (hasRemoteSource) {
      hintParts.add('來源: API');
    }
    if (item.dataSourceKey.trim().isNotEmpty) {
      hintParts.add('鍵: ${item.dataSourceKey.trim()}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 34),
              child: Icon(Icons.arrow_drop_down_circle_outlined, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DynamicFormFieldTheme.buildFieldShell(
                context: context,
                item: item,
                child: DropdownButtonFormField<String>(
                  value: null,
                  items: optionLabels
                      .map(
                        (label) => DropdownMenuItem<String>(
                          value: label,
                          child: Text(
                            label,
                            style: DynamicFormFieldTheme.inputTextStyle(
                              context,
                              item,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: null,
                  style: DynamicFormFieldTheme.inputTextStyle(context, item),
                  decoration: DynamicFormFieldTheme.decoration(
                    context: context,
                    item: item,
                    hintText: placeholder.isNotEmpty
                        ? placeholder
                        : (hasRemoteSource ? '將由遠端資料載入' : null),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 34),
              child: Icon(Icons.drag_handle, color: themeColors.dragHandle),
            ),
          ],
        ),
        if (hintParts.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            hintParts.join(' | '),
            style: DynamicFormFieldTheme.metaTextStyle(context, item),
          ),
        ],
      ],
    );
  }

  Widget _buildFileUploadRow(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;
    final normalizedTypes = item.allowedTypes
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    final hintParts = <String>[];
    if (normalizedTypes.isNotEmpty) {
      hintParts.add('格式: $normalizedTypes');
    }
    if (item.maxSize > 0) {
      hintParts.add('上限: ${item.maxSize}MB');
    }
    final hintText = hintParts.join(' | ');

    final uploadButton = OutlinedButton.icon(
      onPressed: null,
      icon: const Icon(Icons.attach_file, size: 16),
      label: Text(item.fieldName.isEmpty ? '選擇檔案' : item.fieldName),
      style: DynamicFormFieldTheme.uploadButtonStyle(context, item),
    );

    final buttonWidget = item.buttonWidthMode == ButtonWidthMode.fill
        ? SizedBox(width: double.infinity, child: uploadButton)
        : SizedBox(width: item.buttonWidth, child: uploadButton);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: item.buttonWidthMode == ButtonWidthMode.fill
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 34),
              child: Icon(Icons.upload_file, size: 18),
            ),
            const SizedBox(width: 8),
            if (item.buttonWidthMode == ButtonWidthMode.fill)
              Expanded(
                child: DynamicFormFieldTheme.buildFieldShell(
                  context: context,
                  item: item,
                  child: buttonWidget,
                ),
              )
            else
              Flexible(
                child: DynamicFormFieldTheme.buildFieldShell(
                  context: context,
                  item: item,
                  child: buttonWidget,
                ),
              ),
            const SizedBox(width: 8),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 34),
              child: Icon(Icons.drag_handle, color: themeColors.dragHandle),
            ),
          ],
        ),
        if (hintText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            hintText,
            style: DynamicFormFieldTheme.metaTextStyle(context, item),
          ),
        ],
      ],
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;
    final buttonBackgroundColor = ColorHexUtils.parse(item.buttonColorHex);
    final buttonForegroundColor = ColorHexUtils.parse(item.buttonTextColorHex);
    final button = ElevatedButton(
      onPressed: () {},
      child: Text(item.text),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBackgroundColor,
        foregroundColor: buttonForegroundColor,
        textStyle: TextStyle(fontSize: item.fontSize),
      ),
    );

    final buttonWidget = item.buttonWidthMode == ButtonWidthMode.fill
        ? SizedBox(width: double.infinity, child: button)
        : SizedBox(width: item.buttonWidth, child: button);

    return Row(
      mainAxisSize: item.buttonWidthMode == ButtonWidthMode.fill
          ? MainAxisSize.max
          : MainAxisSize.min,
      children: [
        const Icon(Icons.touch_app, size: 18),
        const SizedBox(width: 8),
        if (item.buttonWidthMode == ButtonWidthMode.fill)
          Expanded(child: IgnorePointer(child: buttonWidget))
        else
          IgnorePointer(child: buttonWidget),
        const SizedBox(width: 8),
        Icon(Icons.drag_handle, color: themeColors.dragHandle),
      ],
    );
  }

  Widget _buildChoiceRow(BuildContext context, {required bool isRadio}) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            isRadio ? Icons.radio_button_checked : Icons.check_box_outlined,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildChoiceContent(isRadio: isRadio)),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.drag_handle, color: themeColors.dragHandle),
        ),
      ],
    );
  }

  Widget _buildChoiceContent({required bool isRadio}) {
    final optionLabels = item.isGrouped ? item.options : [item.text];
    final title = item.isGrouped && item.text.isNotEmpty ? item.text : '';
    final optionSpacing = item.optionSpacing;
    final children = optionLabels
        .map((label) => _buildChoiceOption(label: label, isRadio: isRadio))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style:
                TextStyle(fontSize: item.fontSize, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        if (item.isGrouped &&
            item.optionLayout == DesignerItemOptionLayout.horizontal)
          Wrap(
            spacing: optionSpacing,
            runSpacing: optionSpacing,
            children: children,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map(
                  (child) => Padding(
                    padding: EdgeInsets.only(bottom: optionSpacing),
                    child: child,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildChoiceOption({
    required String label,
    required bool isRadio,
  }) {
    if (isRadio) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<int>(
            value: 0,
            groupValue: 0,
            onChanged: null,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(label, style: TextStyle(fontSize: item.fontSize)),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: false,
          onChanged: null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: TextStyle(fontSize: item.fontSize)),
      ],
    );
  }
}
