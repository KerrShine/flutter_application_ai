import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/canvas_row_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/empty_drop_zone_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/palette_item_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/properties_panel_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/panel_header_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/trailing_drop_zone_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/theme/form_section_design_page_theme.dart';
import 'package:flutter_application_ai/service/form_section_design_service.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';
import 'package:go_router/go_router.dart';

class FormSectionDesignPage extends StatefulWidget {
  final String returnFormId;
  final String editSectionId;

  const FormSectionDesignPage({
    super.key,
    this.returnFormId = '',
    this.editSectionId = '',
  });

  @override
  State<FormSectionDesignPage> createState() => _FormSectionDesignPageState();
}

class _FormSectionDesignPageState extends State<FormSectionDesignPage> {
  late final FormSectionDesignBloc _bloc;
  final TextEditingController _draftNameController = TextEditingController();

  @override
  void initState() {
    _bloc = FormSectionDesignBloc(sl<FormSectionDesignService>());
    _bloc.add(InitEvent(sectionId: widget.editSectionId));
    super.initState();
  }

  @override
  void dispose() {
    _draftNameController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);

    return Theme(
        data: FormSectionDesignPageTheme.resolve(baseTheme),
        child: BlocProvider.value(
          value: _bloc,
          child: MultiBlocListener(
            listeners: [
              BlocListener<FormSectionDesignBloc, FormSectionDesignState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status,
                listener: (context, state) {
                  if (state.status == FormSectionDesignStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  } else if (state.status ==
                      FormSectionDesignStatus.exportSuccess) {
                    showScrollableMessageDialog(
                      context: context,
                      title: '匯出JSON',
                      child: SelectableText(state.exportedJson),
                    );
                  } else if (state.status ==
                      FormSectionDesignStatus.promptDraftName) {
                    _draftNameController.text = state.draftName;
                    showTextInputDialog(
                      context: context,
                      title: '輸入表單名稱',
                      controller: _draftNameController,
                      labelText: '表單名稱',
                      onCancel: () {
                        _bloc.add(const CompleteSaveDraftPromptEvent());
                      },
                      onConfirm: (value) {
                        _bloc.add(SubmitSaveDraftEvent(value));
                      },
                    );
                  } else if (state.status ==
                      FormSectionDesignStatus.savedDraft) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已保存草稿：${state.draftName}')),
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<FormSectionDesignBloc, FormSectionDesignState>(
              builder: (context, state) {
                final themeColors = Theme.of(context)
                    .extension<FormSectionDesignThemeColors>()!;

                return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (widget.returnFormId.isNotEmpty) {
                          context.go(
                            RouteName.formDesignPage,
                            extra: widget.returnFormId,
                          );
                        } else {
                          context.go(RouteName.formManagePage);
                        }
                      },
                    ),
                    title: const Text('表單欄位設計'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 216,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: themeColors.paletteBackground,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: themeColors.panelBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColors.panelShadow,
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PanelHeaderWidget(
                                  icon: Icons.widgets_outlined,
                                  title: '元件庫',
                                  subtitle: '拖曳到畫布快速組裝',
                                  backgroundColor:
                                      themeColors.paletteHeaderBackground,
                                  foregroundColor: themeColors.textPrimary,
                                ),
                                const SizedBox(height: 12),
                                const Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        PaletteItemWidget(
                                          title: 'Label',
                                          icon: Icons.label_outline,
                                          data: DesignerItemType.label,
                                        ),
                                        SizedBox(height: 10),
                                        PaletteItemWidget(
                                          title: 'TextField',
                                          icon: Icons.text_fields,
                                          data: DesignerItemType.textField,
                                        ),
                                        SizedBox(height: 10),
                                        PaletteItemWidget(
                                          title: 'TextArea',
                                          icon: Icons.notes,
                                          data: DesignerItemType.textArea,
                                        ),
                                        SizedBox(height: 10),
                                        PaletteItemWidget(
                                          title: 'Radio',
                                          icon: Icons.radio_button_checked,
                                          data: DesignerItemType.radio,
                                        ),
                                        SizedBox(height: 10),
                                        PaletteItemWidget(
                                          title: 'Checkbox',
                                          icon: Icons.check_box_outlined,
                                          data: DesignerItemType.checkbox,
                                        ),
                                        SizedBox(height: 10),
                                        PaletteItemWidget(
                                          title: 'Dropdown',
                                          icon: Icons.arrow_drop_down,
                                          data: DesignerItemType.dropdown,
                                        ),
                                        SizedBox(height: 10),
                                        PaletteItemWidget(
                                          title: 'DatePicker',
                                          icon: Icons.calendar_today,
                                          data: DesignerItemType.datePicker,
                                        ),
                                        SizedBox(height: 10),
                                        PaletteItemWidget(
                                          title: 'FileUpload',
                                          icon: Icons.upload_file,
                                          data: DesignerItemType.fileUpload,
                                        ),
                                        SizedBox(height: 10),
                                        PaletteItemWidget(
                                          title: 'Button',
                                          icon: Icons.touch_app,
                                          data: DesignerItemType.button,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: themeColors.emptyStateBackground,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: themeColors.panelBorder),
                                  ),
                                  child: Text(
                                    '提示：\n1) 拖曳項目到畫布\n2) 使用句柄重新排序',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeColors.textMuted,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: themeColors.canvasBackground,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: themeColors.panelBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColors.panelShadow,
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: PanelHeaderWidget(
                                        icon: Icons.space_dashboard_outlined,
                                        title: '畫布',
                                        subtitle: '調整列與欄位版型',
                                        backgroundColor:
                                            themeColors.canvasHeaderBackground,
                                        foregroundColor:
                                            themeColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: themeColors.actionBarBackground,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: themeColors.panelBorder,
                                        ),
                                      ),
                                      child: Text(
                                        '${state.rowCount} 列 / ${state.items.length} 項目',
                                        style: TextStyle(
                                          color: themeColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (state.items.isEmpty &&
                                            state.rowCount <= 1)
                                          const EmptyDropZoneWidget()
                                        else
                                          ...List.generate(
                                            state.rowCount,
                                            (rowIdx) => CanvasRowWidget(
                                              rowIndex: rowIdx,
                                              items: state.items
                                                  .where(
                                                    (e) => e.rowIndex == rowIdx,
                                                  )
                                                  .toList(),
                                              selectedItemId:
                                                  state.selectedItemId,
                                            ),
                                          ),
                                        TrailingDropZoneWidget(
                                          rowCount: state.rowCount,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: themeColors.actionBarBackground,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: themeColors.panelBorder),
                                  ),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _bloc.add(const AddRowEvent()),
                                        icon: const Icon(Icons.add),
                                        label: const Text('新增列'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _bloc.add(const SaveDraftEvent()),
                                        icon: const Icon(Icons.save_outlined),
                                        label: const Text('保存草稿'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          _bloc.add(
                                            const ClearDesignerItemsEvent(),
                                          );
                                        },
                                        child: const Text('清空'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          _bloc.add(const ExportFormEvent());
                                        },
                                        child: const Text('匯出JSON'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 320,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: themeColors.propertiesBackground,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: themeColors.panelBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColors.panelShadow,
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: PropertiesPanelWidget(state: state),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

}
