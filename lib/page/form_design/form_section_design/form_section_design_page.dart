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
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/trailing_drop_zone_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_section_design_service.dart';
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
    return BlocProvider.value(
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
              } else if (state.status == FormSectionDesignStatus.savedDraft) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已保存草稿：${state.draftName}')),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<FormSectionDesignBloc, FormSectionDesignState>(
          builder: (context, state) {
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
              body: Row(
                children: [
                  Container(
                    width: 180,
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(12),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('元件庫', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PaletteItemWidget(
                                  title: 'Label',
                                  icon: Icons.label_outline,
                                  data: DesignerItemType.label,
                                ),
                                SizedBox(height: 8),
                                PaletteItemWidget(
                                  title: 'TextField',
                                  icon: Icons.text_fields,
                                  data: DesignerItemType.textField,
                                ),
                                SizedBox(height: 8),
                                PaletteItemWidget(
                                  title: 'TextArea',
                                  icon: Icons.notes,
                                  data: DesignerItemType.textArea,
                                ),
                                SizedBox(height: 8),
                                PaletteItemWidget(
                                  title: 'Radio',
                                  icon: Icons.radio_button_checked,
                                  data: DesignerItemType.radio,
                                ),
                                SizedBox(height: 8),
                                PaletteItemWidget(
                                  title: 'Checkbox',
                                  icon: Icons.check_box_outlined,
                                  data: DesignerItemType.checkbox,
                                ),
                                SizedBox(height: 8),
                                PaletteItemWidget(
                                  title: 'Dropdown',
                                  icon: Icons.arrow_drop_down,
                                  data: DesignerItemType.dropdown,
                                ),
                                SizedBox(height: 8),
                                PaletteItemWidget(
                                  title: 'DatePicker',
                                  icon: Icons.calendar_today,
                                  data: DesignerItemType.datePicker,
                                ),
                                SizedBox(height: 8),
                                PaletteItemWidget(
                                  title: 'FileUpload',
                                  icon: Icons.upload_file,
                                  data: DesignerItemType.fileUpload,
                                ),
                                SizedBox(height: 8),
                                PaletteItemWidget(
                                  title: 'Button',
                                  icon: Icons.touch_app,
                                  data: DesignerItemType.button,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '提示：\n1) 拖曳項目到畫布\n2) 使用句柄重新排序',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '畫布',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Text(
                                '${state.rowCount} 列 / ${state.items.length} 項目',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                            .where((e) => e.rowIndex == rowIdx)
                                            .toList(),
                                        selectedItemId: state.selectedItemId,
                                      ),
                                    ),
                                  TrailingDropZoneWidget(
                                    rowCount: state.rowCount,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _bloc.add(const AddRowEvent()),
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
                                  _bloc.add(const ClearDesignerItemsEvent());
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
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 300,
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.all(16),
                    child: PropertiesPanelWidget(state: state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
