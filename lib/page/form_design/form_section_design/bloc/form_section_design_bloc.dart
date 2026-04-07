import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/service/form_section_design_service.dart';

part 'form_section_design_event.dart';
part 'form_section_design_state.dart';

class FormSectionDesignBloc
    extends Bloc<FormSectionDesignEvent, FormSectionDesignState> {
  static const int sectionDescriptionMaxLength = 50;

  final FormSectionDesignService formSectionDesignService;

  FormSectionDesignBloc(this.formSectionDesignService)
      : super(const FormSectionDesignState()) {
    on<InitEvent>(_onInitEvent);
    on<AddDesignerItemEvent>(_onAddDesignerItemEvent);
    on<InsertDesignerItemEvent>(_onInsertDesignerItemEvent);
    on<ReorderDesignerItemEvent>(_onReorderDesignerItemEvent);
    on<MoveDesignerItemEvent>(_onMoveDesignerItemEvent);
    on<DeleteDesignerItemEvent>(_onDeleteDesignerItemEvent);
    on<ClearDesignerItemsEvent>(_onClearDesignerItemsEvent);
    on<AddMultipleDesignerItemsEvent>(_onAddMultipleDesignerItemsEvent);
    on<ExportFormEvent>(_onExportFormEvent);
    on<SelectDesignerItemEvent>(_onSelectDesignerItemEvent);
    on<UpdateDesignerItemTextEvent>(_onUpdateDesignerItemTextEvent);
    on<UpdateDesignerItemFieldNameEvent>(_onUpdateDesignerItemFieldNameEvent);
    on<UpdateDesignerItemPlaceholderEvent>(
      _onUpdateDesignerItemPlaceholderEvent,
    );
    on<UpdateDesignerItemMaxLengthEvent>(
      _onUpdateDesignerItemMaxLengthEvent,
    );
    on<UpdateDesignerItemWidthEvent>(_onUpdateDesignerItemWidthEvent);
    on<UpdateDesignerItemAlignmentEvent>(_onUpdateDesignerItemAlignmentEvent);
    on<UpdateDesignerItemPaddingEvent>(_onUpdateDesignerItemPaddingEvent);
    on<UpdateDesignerItemButtonWidthModeEvent>(
      _onUpdateDesignerItemButtonWidthModeEvent,
    );
    on<UpdateDesignerItemButtonWidthEvent>(
        _onUpdateDesignerItemButtonWidthEvent);
    on<UpdateDesignerItemButtonColorEvent>(
      _onUpdateDesignerItemButtonColorEvent,
    );
    on<UpdateDesignerItemButtonTextColorEvent>(
      _onUpdateDesignerItemButtonTextColorEvent,
    );
    on<UpdateDesignerItemTextAreaHeightEvent>(
      _onUpdateDesignerItemTextAreaHeightEvent,
    );
    on<UpdateDesignerItemGroupedEvent>(_onUpdateDesignerItemGroupedEvent);
    on<UpdateDesignerItemOptionsTextEvent>(
        _onUpdateDesignerItemOptionsTextEvent);
    on<UpdateDesignerItemOptionLayoutEvent>(
      _onUpdateDesignerItemOptionLayoutEvent,
    );
    on<UpdateDesignerItemOptionSpacingEvent>(
      _onUpdateDesignerItemOptionSpacingEvent,
    );
    on<UpdateDesignerItemDateFormatEvent>(
      _onUpdateDesignerItemDateFormatEvent,
    );
    on<UpdateDesignerItemFontSizeEvent>(
      _onUpdateDesignerItemFontSizeEvent,
    );
    on<UpdateDesignerItemBoldEvent>(
      _onUpdateDesignerItemBoldEvent,
    );
    on<UpdateDesignerItemAllowedTypesEvent>(
      _onUpdateDesignerItemAllowedTypesEvent,
    );
    on<UpdateDesignerItemMaxSizeEvent>(
      _onUpdateDesignerItemMaxSizeEvent,
    );
    on<AddRowEvent>(_onAddRowEvent);
    on<MoveItemToRowEvent>(_onMoveItemToRowEvent);
    on<DeleteRowEvent>(_onDeleteRowEvent);
    on<SaveDraftEvent>(_onSaveDraftEvent);
    on<SubmitSaveDraftEvent>(_onSubmitSaveDraftEvent);
    on<CompleteSaveDraftPromptEvent>(_onCompleteSaveDraftPromptEvent);
    on<UpdateDesignerItemRequiredEvent>(_onUpdateDesignerItemRequiredEvent);
    on<UpdateDesignerItemReadonlyEvent>(_onUpdateDesignerItemReadonlyEvent);
    on<UpdateDesignerItemInputTypeEvent>(_onUpdateDesignerItemInputTypeEvent);
    on<UpdateDesignerItemDataSourceUrlEvent>(
        _onUpdateDesignerItemDataSourceUrlEvent);
    on<UpdateDesignerItemDataSourceKeyEvent>(
        _onUpdateDesignerItemDataSourceKeyEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<FormSectionDesignState> emit,
  ) async {
    emit(state.copyWith(status: FormSectionDesignStatus.loading));

    if (event.sectionId.isEmpty) {
      emit(const FormSectionDesignState(
        status: FormSectionDesignStatus.success,
      ));
      return;
    }

    final draftResult =
        await formSectionDesignService.loadDraft(event.sectionId);
    if (!draftResult.isSuccess) {
      emit(state.copyWith(
        status: FormSectionDesignStatus.failure,
        message: draftResult.error ?? 'Read draft failed',
      ));
      return;
    }

    final draft = draftResult.data;
    if (draft != null) {
      emit(state.copyWith(
        status: FormSectionDesignStatus.success,
        items: draft.items,
        rowCount: draft.rowCount < 1 ? 1 : draft.rowCount,
        draftName: draft.formName,
        draftDescription: draft.description,
        editingSectionId: draft.sectionId,
      ));
      return;
    }

    final result = await formSectionDesignService.loadSection(event.sectionId);
    if (!result.isSuccess || result.data == null) {
      emit(state.copyWith(
        status: FormSectionDesignStatus.failure,
        message: result.error ?? 'Read section failed',
      ));
      return;
    }

    final section = result.data!;
    final maxRow = section.items.isEmpty
        ? 0
        : section.items
            .map((item) => item.rowIndex)
            .reduce((current, next) => current > next ? current : next);

    emit(state.copyWith(
      status: FormSectionDesignStatus.success,
      items: section.items,
      rowCount: maxRow + 1,
      draftName: section.name,
      draftDescription: section.description,
      editingSectionId: section.id,
    ));
  }

  int _seq = 0;

  String _newId() => 'i_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  void _onAddDesignerItemEvent(
    AddDesignerItemEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final targetRow = event.targetRowIndex != -1
        ? event.targetRowIndex
        : (state.items.isEmpty
            ? 0
            : state.items
                .map((e) => e.rowIndex)
                .reduce((a, b) => a > b ? a : b));

    final newItem = DesignerItem(
      id: _newId(),
      type: event.type,
      text: _defaultTextForType(event.type),
      rowIndex: targetRow,
      isGrouped: _supportsGroupedOptions(event.type),
      options: _defaultOptionsForType(event.type),
      optionLayout: DesignerItemOptionLayout.vertical,
    );
    final updatedList = List<DesignerItem>.from(state.items)..add(newItem);
    final newRowCount =
        targetRow + 1 > state.rowCount ? targetRow + 1 : state.rowCount;
    emit(state.copyWith(items: updatedList, rowCount: newRowCount));
  }

  void _onInsertDesignerItemEvent(
    InsertDesignerItemEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final newItem = DesignerItem(
      id: _newId(),
      type: event.type,
      text: _defaultTextForType(event.type),
      isGrouped: _supportsGroupedOptions(event.type),
      options: _defaultOptionsForType(event.type),
      optionLayout: DesignerItemOptionLayout.vertical,
    );
    final updatedList = List<DesignerItem>.from(state.items);
    var insertIndex = event.index;
    if (insertIndex < 0) {
      insertIndex = 0;
    }
    if (insertIndex > updatedList.length) {
      insertIndex = updatedList.length;
    }

    updatedList.insert(insertIndex, newItem);
    emit(state.copyWith(items: updatedList));
  }

  void _onReorderDesignerItemEvent(
    ReorderDesignerItemEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    var newIndex = event.newIndex;
    final oldIndex = event.oldIndex;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedList = List<DesignerItem>.from(state.items);
    final moved = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, moved);
    emit(state.copyWith(items: updatedList));
  }

  void _onMoveDesignerItemEvent(
    MoveDesignerItemEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedList = List<DesignerItem>.from(state.items);
    final oldIndex = updatedList.indexWhere((item) => item.id == event.id);
    if (oldIndex == -1) {
      return;
    }

    final moved = updatedList.removeAt(oldIndex);
    var newIndex = event.newIndex;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (newIndex < 0) {
      newIndex = 0;
    }
    if (newIndex > updatedList.length) {
      newIndex = updatedList.length;
    }

    updatedList.insert(newIndex, moved);
    emit(state.copyWith(items: updatedList));
  }

  void _onDeleteDesignerItemEvent(
    DeleteDesignerItemEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedList = List<DesignerItem>.from(state.items)
      ..removeWhere((item) => item.id == event.id);

    emit(state.copyWith(
      items: updatedList,
      selectedItemId:
          state.selectedItemId == event.id ? '' : state.selectedItemId,
    ));
  }

  void _onClearDesignerItemsEvent(
    ClearDesignerItemsEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(items: const [], selectedItemId: '', rowCount: 1));
  }

  void _onAddMultipleDesignerItemsEvent(
    AddMultipleDesignerItemsEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedList = List<DesignerItem>.from(state.items)
      ..addAll(event.items);
    final maxRow = updatedList.isEmpty
        ? 0
        : updatedList.map((e) => e.rowIndex).reduce((a, b) => a > b ? a : b);
    final newRowCount =
        maxRow + 1 > state.rowCount ? maxRow + 1 : state.rowCount;
    emit(state.copyWith(items: updatedList, rowCount: newRowCount));
  }

  void _onExportFormEvent(
    ExportFormEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final listMap = state.items.map((e) => e.toMap()).toList();
    final jsonStr = jsonEncode(listMap);
    emit(state.copyWith(
      status: FormSectionDesignStatus.exportSuccess,
      exportedJson: jsonStr,
    ));
    emit(state.copyWith(status: FormSectionDesignStatus.success));
  }

  void _onSelectDesignerItemEvent(
    SelectDesignerItemEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(selectedItemId: event.id));
  }

  void _onUpdateDesignerItemTextEvent(
    UpdateDesignerItemTextEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(text: event.text);
    })));
  }

  void _onUpdateDesignerItemFieldNameEvent(
    UpdateDesignerItemFieldNameEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(fieldName: event.fieldName);
    })));
  }

  void _onUpdateDesignerItemPlaceholderEvent(
    UpdateDesignerItemPlaceholderEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(placeholder: event.placeholder);
    })));
  }

  void _onUpdateDesignerItemMaxLengthEvent(
    UpdateDesignerItemMaxLengthEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(maxLength: event.maxLength);
    })));
  }

  void _onUpdateDesignerItemWidthEvent(
    UpdateDesignerItemWidthEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(widthPercentage: event.widthPercentage);
    })));
  }

  void _onUpdateDesignerItemAlignmentEvent(
    UpdateDesignerItemAlignmentEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(alignment: event.alignment);
    })));
  }

  void _onUpdateDesignerItemPaddingEvent(
    UpdateDesignerItemPaddingEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(padding: event.padding);
    })));
  }

  void _onUpdateDesignerItemButtonWidthModeEvent(
    UpdateDesignerItemButtonWidthModeEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(buttonWidthMode: event.buttonWidthMode);
    })));
  }

  void _onUpdateDesignerItemButtonWidthEvent(
    UpdateDesignerItemButtonWidthEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(buttonWidth: event.buttonWidth);
    })));
  }

  void _onUpdateDesignerItemButtonColorEvent(
    UpdateDesignerItemButtonColorEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(buttonColorHex: event.buttonColorHex.trim());
    })));
  }

  void _onUpdateDesignerItemButtonTextColorEvent(
    UpdateDesignerItemButtonTextColorEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(
        buttonTextColorHex: event.buttonTextColorHex.trim(),
      );
    })));
  }

  void _onUpdateDesignerItemTextAreaHeightEvent(
    UpdateDesignerItemTextAreaHeightEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(textAreaHeight: event.textAreaHeight);
    })));
  }

  void _onUpdateDesignerItemGroupedEvent(
    UpdateDesignerItemGroupedEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(isGrouped: event.isGrouped);
    })));
  }

  void _onUpdateDesignerItemOptionsTextEvent(
    UpdateDesignerItemOptionsTextEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final normalized = event.optionsText
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final options = normalized.isEmpty ? const ['Option 1'] : normalized;

    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(options: options);
    })));
  }

  void _onUpdateDesignerItemOptionLayoutEvent(
    UpdateDesignerItemOptionLayoutEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(optionLayout: event.optionLayout);
    })));
  }

  void _onUpdateDesignerItemOptionSpacingEvent(
    UpdateDesignerItemOptionSpacingEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(optionSpacing: event.optionSpacing);
    })));
  }

  void _onUpdateDesignerItemDateFormatEvent(
    UpdateDesignerItemDateFormatEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(dateFormat: event.dateFormat);
    })));
  }

  void _onUpdateDesignerItemFontSizeEvent(
    UpdateDesignerItemFontSizeEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(fontSize: event.fontSize);
    })));
  }

  void _onUpdateDesignerItemBoldEvent(
    UpdateDesignerItemBoldEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(isBold: event.isBold);
    })));
  }

  void _onUpdateDesignerItemAllowedTypesEvent(
    UpdateDesignerItemAllowedTypesEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(allowedTypes: event.allowedTypes);
    })));
  }

  void _onUpdateDesignerItemMaxSizeEvent(
    UpdateDesignerItemMaxSizeEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(
        items: _updateItem(event.id, (item) {
      return item.copyWith(maxSize: event.maxSize);
    })));
  }

  void _onAddRowEvent(
    AddRowEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(rowCount: state.rowCount + 1));
  }

  void _onMoveItemToRowEvent(
    MoveItemToRowEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final idx = state.items.indexWhere((i) => i.id == event.itemId);
    if (idx == -1) {
      return;
    }
    final updatedList = List<DesignerItem>.from(state.items);
    final item = updatedList.removeAt(idx);
    updatedList.add(item.copyWith(rowIndex: event.targetRowIndex));
    final maxRow =
        updatedList.map((e) => e.rowIndex).reduce((a, b) => a > b ? a : b);
    final newRowCount =
        maxRow + 1 > state.rowCount ? maxRow + 1 : state.rowCount;
    emit(state.copyWith(items: updatedList, rowCount: newRowCount));
  }

  void _onDeleteRowEvent(
    DeleteRowEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedList = state.items
        .where((i) => i.rowIndex != event.rowIndex)
        .map((i) => i.rowIndex > event.rowIndex
            ? i.copyWith(rowIndex: i.rowIndex - 1)
            : i)
        .toList();
    final newRowCount = (state.rowCount - 1).clamp(1, state.rowCount);
    final selectedStillExists =
        updatedList.any((i) => i.id == state.selectedItemId);
    emit(state.copyWith(
      items: updatedList,
      rowCount: newRowCount,
      selectedItemId: selectedStillExists ? state.selectedItemId : '',
    ));
  }

  void _onSaveDraftEvent(
    SaveDraftEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(status: FormSectionDesignStatus.promptDraftName));
  }

  Future<void> _onSubmitSaveDraftEvent(
    SubmitSaveDraftEvent event,
    Emitter<FormSectionDesignState> emit,
  ) async {
    final formName = event.formName.trim();
    final description = event.description.trim();
    if (formName.isEmpty) {
      emit(state.copyWith(
        status: FormSectionDesignStatus.failure,
        message: '請輸入欄位名稱',
      ));
      return;
    }

    if (description.length > sectionDescriptionMaxLength) {
      emit(state.copyWith(
        status: FormSectionDesignStatus.failure,
        message: '欄位介紹最多只能輸入 $sectionDescriptionMaxLength 個字',
      ));
      return;
    }

    final result = await formSectionDesignService.saveDraft(
      state.editingSectionId,
      formName,
      description,
      state.items,
      state.rowCount,
    );
    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormSectionDesignStatus.savedDraft,
        draftName: formName,
        draftDescription: description,
        editingSectionId: state.editingSectionId,
      ));
      emit(state.copyWith(status: FormSectionDesignStatus.success));
    } else {
      emit(state.copyWith(
        status: FormSectionDesignStatus.failure,
        message: result.error ?? 'Save draft failed',
      ));
    }
  }

  void _onCompleteSaveDraftPromptEvent(
    CompleteSaveDraftPromptEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    emit(state.copyWith(status: FormSectionDesignStatus.success));
  }

  void _onUpdateDesignerItemRequiredEvent(
    UpdateDesignerItemRequiredEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedItems = _updateItem(event.id, (item) {
      return item.copyWith(required: event.required);
    });
    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateDesignerItemReadonlyEvent(
    UpdateDesignerItemReadonlyEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedItems = _updateItem(event.id, (item) {
      return item.copyWith(readonly: event.readonly);
    });
    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateDesignerItemInputTypeEvent(
    UpdateDesignerItemInputTypeEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedItems = _updateItem(event.id, (item) {
      return item.copyWith(inputType: event.inputType);
    });
    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateDesignerItemDataSourceUrlEvent(
    UpdateDesignerItemDataSourceUrlEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedItems = _updateItem(event.id, (item) {
      return item.copyWith(dataSourceUrl: event.dataSourceUrl);
    });
    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateDesignerItemDataSourceKeyEvent(
    UpdateDesignerItemDataSourceKeyEvent event,
    Emitter<FormSectionDesignState> emit,
  ) {
    final updatedItems = _updateItem(event.id, (item) {
      return item.copyWith(dataSourceKey: event.dataSourceKey);
    });
    emit(state.copyWith(items: updatedItems));
  }

  List<DesignerItem> _updateItem(
    String id,
    DesignerItem Function(DesignerItem item) builder,
  ) {
    return state.items.map((item) {
      if (item.id == id) {
        return builder(item);
      }
      return item;
    }).toList();
  }

  String _defaultTextForType(DesignerItemType type) {
    switch (type) {
      case DesignerItemType.label:
        return '標籤';
      case DesignerItemType.textField:
        return '文字欄';
      case DesignerItemType.textArea:
        return '文字區';
      case DesignerItemType.radio:
        return '單選群組';
      case DesignerItemType.checkbox:
        return '複選群組';
      case DesignerItemType.dropdown:
        return '下拉選擇器';
      case DesignerItemType.button:
        return '按鈕';
      case DesignerItemType.datePicker:
        return '日期選擇';
      case DesignerItemType.fileUpload:
        return '檔案上傳';
    }
  }

  bool _supportsGroupedOptions(DesignerItemType type) {
    return type == DesignerItemType.radio ||
        type == DesignerItemType.checkbox ||
        type == DesignerItemType.dropdown;
  }

  List<String> _defaultOptionsForType(DesignerItemType type) {
    if (_supportsGroupedOptions(type)) {
      return const ['選項1', '選項2'];
    }
    return const ['選項1'];
  }
}
