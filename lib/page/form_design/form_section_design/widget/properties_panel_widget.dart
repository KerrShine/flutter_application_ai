import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/constant/form_section_design_constants.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/constant/form_section_design_label_mapper.dart';

class PropertiesPanelWidget extends StatelessWidget {
  final FormSectionDesignState state;

  const PropertiesPanelWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.selectedItemId.isEmpty) {
      return const Center(
        child: Text(
          '請先選擇項目',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final selectedItemIndex =
        state.items.indexWhere((e) => e.id == state.selectedItemId);
    if (selectedItemIndex == -1) {
      return const Center(child: Text('未找到選定的項目'));
    }

    final selectedItem = state.items[selectedItemIndex];

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '屬性檢查',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '識別碼: ${selectedItem.id}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Text(
            '類型: ${selectedItem.type.name}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          TabBar(
            labelPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.grey.shade300,
            tabs: const [
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('基本屬性'),
                ),
              ),
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('排版設定'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _PropertiesTab(selectedItem: selectedItem),
                _LayoutTab(selectedItem: selectedItem),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertiesTab extends StatelessWidget {
  final DesignerItem selectedItem;

  const _PropertiesTab({
    required this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    final isChoiceItem = selectedItem.type == DesignerItemType.radio ||
        selectedItem.type == DesignerItemType.checkbox ||
        selectedItem.type == DesignerItemType.dropdown;
    final isDropdownItem = selectedItem.type == DesignerItemType.dropdown;
    final isLabelItem = selectedItem.type == DesignerItemType.label;
    final isFileUploadItem = selectedItem.type == DesignerItemType.fileUpload;
    final isDatePicker = selectedItem.type == DesignerItemType.datePicker;
    final isButtonItem = selectedItem.type == DesignerItemType.button;
    final isMaxLengthItem = selectedItem.type == DesignerItemType.textField ||
        selectedItem.type == DesignerItemType.textArea;
    final isPlaceholderItem = selectedItem.type == DesignerItemType.textField ||
        selectedItem.type == DesignerItemType.textArea ||
        selectedItem.type == DesignerItemType.datePicker;
    final isInputItem = !isLabelItem && !isButtonItem;
    final isEditableItem = selectedItem.type == DesignerItemType.textField ||
        selectedItem.type == DesignerItemType.textArea;
    final isTextFieldItem = selectedItem.type == DesignerItemType.textField;

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      children: [
        TextFormField(
          key: ValueKey('${selectedItem.id}_text'),
          initialValue: selectedItem.text,
          decoration: const InputDecoration(
            labelText: '文字',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            context.read<FormSectionDesignBloc>().add(
                  UpdateDesignerItemTextEvent(selectedItem.id, val),
                );
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: ValueKey('${selectedItem.id}_field_name'),
          initialValue: selectedItem.fieldName,
          decoration: const InputDecoration(
            labelText: '欄位名稱',
            border: OutlineInputBorder(),
            hintText: 'apiKey / fieldName',
          ),
          onChanged: (val) {
            context.read<FormSectionDesignBloc>().add(
                  UpdateDesignerItemFieldNameEvent(selectedItem.id, val),
                );
          },
        ),
        if (isPlaceholderItem) ...[
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('${selectedItem.id}_placeholder'),
            initialValue: selectedItem.placeholder,
            decoration: const InputDecoration(
              labelText: 'Placeholder',
              border: OutlineInputBorder(),
              hintText: '請輸入提示文字',
            ),
            onChanged: (val) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemPlaceholderEvent(selectedItem.id, val),
                  );
            },
          ),
        ],
        if (isMaxLengthItem) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('${selectedItem.id}_max_length'),
            value: FormSectionDesignConstants.normalizeMaxLength(
              selectedItem.maxLength,
            ),
            decoration: const InputDecoration(
              labelText: '最大字數',
              border: OutlineInputBorder(),
            ),
            items: FormSectionDesignConstants.maxLengthOptions
                .map(
                  (maxLength) => DropdownMenuItem(
                    value: maxLength,
                    child: Text(maxLength == 0 ? '不限制' : '$maxLength'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemMaxLengthEvent(selectedItem.id, val),
                    );
              }
            },
          ),
        ],
        const SizedBox(height: 12),
        DropdownButtonFormField<double>(
          key: ValueKey('${selectedItem.id}_font_size'),
          value: FormSectionDesignConstants.normalizeFontSize(
            selectedItem.fontSize,
          ),
          decoration: const InputDecoration(
            labelText: '文字大小',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: FormSectionDesignConstants.fontSizeOptions
              .map(
                (size) => DropdownMenuItem(
                  value: size,
                  child: Text('${size.toInt()} px'),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemFontSizeEvent(selectedItem.id, val),
                  );
            }
          },
        ),
        if (isLabelItem) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<bool>(
            key: ValueKey('${selectedItem.id}_font_weight'),
            value: selectedItem.isBold,
            decoration: const InputDecoration(
              labelText: '字形',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: false, child: Text('一般')),
              DropdownMenuItem(value: true, child: Text('粗體')),
            ],
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemBoldEvent(selectedItem.id, val),
                    );
              }
            },
          ),
        ],
        if (isDatePicker) ...[
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('${selectedItem.id}_date_format'),
            initialValue: selectedItem.dateFormat,
            decoration: const InputDecoration(
              labelText: '日期格式',
              border: OutlineInputBorder(),
              hintText: 'yyyy-MM-dd',
            ),
            onChanged: (val) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemDateFormatEvent(selectedItem.id, val),
                  );
            },
          ),
        ],
        if (isFileUploadItem) ...[
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('${selectedItem.id}_allowed_types'),
            initialValue: selectedItem.allowedTypes,
            decoration: const InputDecoration(
              labelText: '允許檔案格式',
              border: OutlineInputBorder(),
              hintText: 'jpg,png,pdf',
            ),
            onChanged: (val) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemAllowedTypesEvent(selectedItem.id, val),
                  );
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('${selectedItem.id}_max_size'),
            value: FormSectionDesignConstants.normalizeFileMaxSize(
              selectedItem.maxSize,
            ),
            decoration: const InputDecoration(
              labelText: '單檔大小上限 (MB)',
              border: OutlineInputBorder(),
            ),
            items: FormSectionDesignConstants.fileMaxSizeOptions
                .map(
                  (size) => DropdownMenuItem(
                    value: size,
                    child: Text(size == 0 ? '不限制' : '$size MB'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemMaxSizeEvent(selectedItem.id, val),
                    );
              }
            },
          ),
        ],
        const SizedBox(height: 12),
        DropdownButtonFormField<double>(
          key: ValueKey('${selectedItem.id}_width'),
          value: selectedItem.widthPercentage,
          decoration: const InputDecoration(
            labelText: '寬度',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: FormSectionDesignConstants.widthPercentageOptions
              .map(
                (width) => DropdownMenuItem(
                  value: width,
                  child: Text('${(width * 100).toInt()}%'),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemWidthEvent(selectedItem.id, val),
                  );
            }
          },
        ),
        if (isChoiceItem) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<bool>(
            key: ValueKey('${selectedItem.id}_is_grouped'),
            value: selectedItem.isGrouped,
            decoration: const InputDecoration(
              labelText: '選擇模式',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: false, child: Text('單選')),
              DropdownMenuItem(value: true, child: Text('多選')),
            ],
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemGroupedEvent(selectedItem.id, val),
                    );
              }
            },
          ),
        ],
        if (isChoiceItem && selectedItem.isGrouped) ...[
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('${selectedItem.id}_options'),
            initialValue: selectedItem.options.join('\n'),
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: '選項',
              hintText: '每行一個選項',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemOptionsTextEvent(selectedItem.id, val),
                  );
            },
          ),
        ],
        if (isDropdownItem) ...[
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('${selectedItem.id}_data_source_url'),
            initialValue: selectedItem.dataSourceUrl,
            decoration: const InputDecoration(
              labelText: '資料來源 URL',
              border: OutlineInputBorder(),
              hintText: 'https://api.example.com/dropdown',
            ),
            onChanged: (val) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemDataSourceUrlEvent(selectedItem.id, val),
                  );
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('${selectedItem.id}_data_source_key'),
            initialValue: selectedItem.dataSourceKey,
            decoration: const InputDecoration(
              labelText: '資料提取鍵',
              border: OutlineInputBorder(),
              hintText: 'data / items',
            ),
            onChanged: (val) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemDataSourceKeyEvent(selectedItem.id, val),
                  );
            },
          ),
        ],
        if (isInputItem) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<bool>(
            key: ValueKey('${selectedItem.id}_required'),
            value: selectedItem.required,
            decoration: const InputDecoration(
              labelText: '是否必填',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: false, child: Text('非必填')),
              DropdownMenuItem(value: true, child: Text('必填')),
            ],
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemRequiredEvent(selectedItem.id, val),
                    );
              }
            },
          ),
        ],
        if (isEditableItem) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<bool>(
            key: ValueKey('${selectedItem.id}_readonly'),
            value: selectedItem.readonly,
            decoration: const InputDecoration(
              labelText: '是否唯讀',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: false, child: Text('可編輯')),
              DropdownMenuItem(value: true, child: Text('唯讀')),
            ],
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemReadonlyEvent(selectedItem.id, val),
                    );
              }
            },
          ),
        ],
        if (isTextFieldItem) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<TextInputTypeMode>(
            key: ValueKey('${selectedItem.id}_input_type'),
            value: selectedItem.inputType,
            decoration: const InputDecoration(
              labelText: '輸入模式',
              border: OutlineInputBorder(),
            ),
            items: TextInputTypeMode.values
                .map(
                  (mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(_inputTypeLabel(mode)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemInputTypeEvent(selectedItem.id, val),
                    );
              }
            },
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            context.read<FormSectionDesignBloc>().add(
                  DeleteDesignerItemEvent(selectedItem.id),
                );
          },
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text(
            '刪除項目',
            style: TextStyle(color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
          ),
        )
      ],
    );
  }

  String _inputTypeLabel(TextInputTypeMode mode) {
    switch (mode) {
      case TextInputTypeMode.text:
        return '一般文字';
      case TextInputTypeMode.number:
        return '數字';
      case TextInputTypeMode.email:
        return '電子郵件';
      case TextInputTypeMode.phone:
        return '電話號碼';
    }
  }
}

class _LayoutTab extends StatelessWidget {
  final DesignerItem selectedItem;

  const _LayoutTab({
    required this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    final isChoiceItem = selectedItem.type == DesignerItemType.radio ||
        selectedItem.type == DesignerItemType.checkbox ||
        selectedItem.type == DesignerItemType.dropdown;

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      children: [
        DropdownButtonFormField<DesignerItemAlignment>(
          key: ValueKey('${selectedItem.id}_alignment'),
          value: selectedItem.alignment,
          decoration: const InputDecoration(
            labelText: '對齊',
            border: OutlineInputBorder(),
          ),
          items: DesignerItemAlignment.values
              .map(
                (alignment) => DropdownMenuItem(
                  value: alignment,
                  child: Text(
                      FormSectionDesignLabelMapper.alignmentLabel(alignment)),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemAlignmentEvent(selectedItem.id, val),
                  );
            }
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<double>(
          key: ValueKey('${selectedItem.id}_padding'),
          value: FormSectionDesignConstants.normalizePadding(
            selectedItem.padding,
          ),
          decoration: const InputDecoration(
            labelText: '內距',
            border: OutlineInputBorder(),
          ),
          items: FormSectionDesignConstants.paddingOptions
              .map(
                (padding) => DropdownMenuItem(
                  value: padding,
                  child: Text('${padding.toInt()} px'),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              context.read<FormSectionDesignBloc>().add(
                    UpdateDesignerItemPaddingEvent(selectedItem.id, val),
                  );
            }
          },
        ),
        if (selectedItem.type == DesignerItemType.textArea) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            key: ValueKey('${selectedItem.id}_text_area_height'),
            value: FormSectionDesignConstants.normalizeTextAreaHeight(
              selectedItem.textAreaHeight,
            ),
            decoration: const InputDecoration(
              labelText: 'TextArea 高度',
              border: OutlineInputBorder(),
            ),
            items: FormSectionDesignConstants.textAreaHeightOptions
                .map(
                  (height) => DropdownMenuItem(
                    value: height,
                    child: Text('${height.toInt()} px'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemTextAreaHeightEvent(
                        selectedItem.id,
                        val,
                      ),
                    );
              }
            },
          ),
        ],
        if (isChoiceItem) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<DesignerItemOptionLayout>(
            key: ValueKey('${selectedItem.id}_option_layout'),
            value: selectedItem.optionLayout,
            decoration: const InputDecoration(
              labelText: '選項佈局',
              border: OutlineInputBorder(),
            ),
            items: DesignerItemOptionLayout.values
                .map(
                  (layout) => DropdownMenuItem(
                    value: layout,
                    child: Text(
                        FormSectionDesignLabelMapper.optionLayoutLabel(layout)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemOptionLayoutEvent(
                        selectedItem.id,
                        val,
                      ),
                    );
              }
            },
          ),
        ],
        if (isChoiceItem && selectedItem.isGrouped) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            key: ValueKey('${selectedItem.id}_option_spacing'),
            value: FormSectionDesignConstants.normalizeOptionSpacing(
              selectedItem.optionSpacing,
            ),
            decoration: const InputDecoration(
              labelText: 'Group option 間距',
              border: OutlineInputBorder(),
            ),
            items: FormSectionDesignConstants.optionSpacingOptions
                .map(
                  (spacing) => DropdownMenuItem(
                    value: spacing,
                    child: Text('${spacing.toInt()} px'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemOptionSpacingEvent(
                        selectedItem.id,
                        val,
                      ),
                    );
              }
            },
          ),
        ],
        if (selectedItem.type == DesignerItemType.button ||
            selectedItem.type == DesignerItemType.fileUpload) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<ButtonWidthMode>(
            key: ValueKey('${selectedItem.id}_button_width_mode'),
            value: selectedItem.buttonWidthMode,
            decoration: const InputDecoration(
              labelText: '寬度模式',
              border: OutlineInputBorder(),
            ),
            items: ButtonWidthMode.values
                .map(
                  (mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(
                        FormSectionDesignLabelMapper.buttonWidthModeLabel(
                            mode)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemButtonWidthModeEvent(
                        selectedItem.id,
                        val,
                      ),
                    );
              }
            },
          ),
        ],
        if ((selectedItem.type == DesignerItemType.button ||
                selectedItem.type == DesignerItemType.fileUpload) &&
            selectedItem.buttonWidthMode == ButtonWidthMode.hug) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            key: ValueKey('${selectedItem.id}_button_width'),
            value: FormSectionDesignConstants.normalizeButtonWidth(
              selectedItem.buttonWidth,
            ),
            decoration: const InputDecoration(
              labelText: '按鈕寬度',
              border: OutlineInputBorder(),
            ),
            items: FormSectionDesignConstants.buttonWidthOptions
                .map(
                  (width) => DropdownMenuItem(
                    value: width,
                    child: Text('${width.toInt()} px'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FormSectionDesignBloc>().add(
                      UpdateDesignerItemButtonWidthEvent(
                        selectedItem.id,
                        val,
                      ),
                    );
              }
            },
          ),
        ],
      ],
    );
  }
}
