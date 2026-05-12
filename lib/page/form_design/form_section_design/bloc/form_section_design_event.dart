part of 'form_section_design_bloc.dart';

class FormSectionDesignEvent extends Equatable {
  const FormSectionDesignEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends FormSectionDesignEvent {
  final String sectionId;
  final String formId;

  const InitEvent({this.sectionId = '', this.formId = ''});

  @override
  List<Object> get props => [sectionId, formId];
}

class AddDesignerItemEvent extends FormSectionDesignEvent {
  final DesignerItemType type;
  final int targetRowIndex;

  const AddDesignerItemEvent(this.type, {this.targetRowIndex = -1});

  @override
  List<Object> get props => [type, targetRowIndex];
}

class AddRowEvent extends FormSectionDesignEvent {
  const AddRowEvent();
}

class MoveItemToRowEvent extends FormSectionDesignEvent {
  final String itemId;
  final int targetRowIndex;

  const MoveItemToRowEvent(this.itemId, this.targetRowIndex);

  @override
  List<Object> get props => [itemId, targetRowIndex];
}

class DeleteRowEvent extends FormSectionDesignEvent {
  final int rowIndex;

  const DeleteRowEvent(this.rowIndex);

  @override
  List<Object> get props => [rowIndex];
}

class InsertDesignerItemEvent extends FormSectionDesignEvent {
  final DesignerItemType type;
  final int index;

  const InsertDesignerItemEvent(this.type, this.index);

  @override
  List<Object> get props => [type, index];
}

class MoveDesignerItemEvent extends FormSectionDesignEvent {
  final String id;
  final int newIndex;

  const MoveDesignerItemEvent(this.id, this.newIndex);

  @override
  List<Object> get props => [id, newIndex];
}

class ReorderDesignerItemEvent extends FormSectionDesignEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderDesignerItemEvent(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}

class ClearDesignerItemsEvent extends FormSectionDesignEvent {
  const ClearDesignerItemsEvent();
}

class DeleteDesignerItemEvent extends FormSectionDesignEvent {
  final String id;

  const DeleteDesignerItemEvent(this.id);

  @override
  List<Object> get props => [id];
}

class AddMultipleDesignerItemsEvent extends FormSectionDesignEvent {
  final List<DesignerItem> items;

  const AddMultipleDesignerItemsEvent(this.items);

  @override
  List<Object> get props => [items];
}

class ExportFormEvent extends FormSectionDesignEvent {
  const ExportFormEvent();
}

class SelectDesignerItemEvent extends FormSectionDesignEvent {
  final String id;

  const SelectDesignerItemEvent(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateDesignerItemTextEvent extends FormSectionDesignEvent {
  final String id;
  final String text;

  const UpdateDesignerItemTextEvent(this.id, this.text);

  @override
  List<Object> get props => [id, text];
}

class UpdateDesignerItemFieldNameEvent extends FormSectionDesignEvent {
  final String id;
  final String fieldName;

  const UpdateDesignerItemFieldNameEvent(this.id, this.fieldName);

  @override
  List<Object> get props => [id, fieldName];
}

class UpdateDesignerItemPlaceholderEvent extends FormSectionDesignEvent {
  final String id;
  final String placeholder;

  const UpdateDesignerItemPlaceholderEvent(this.id, this.placeholder);

  @override
  List<Object> get props => [id, placeholder];
}

class UpdateDesignerItemMaxLengthEvent extends FormSectionDesignEvent {
  final String id;
  final int maxLength;

  const UpdateDesignerItemMaxLengthEvent(this.id, this.maxLength);

  @override
  List<Object> get props => [id, maxLength];
}

class UpdateDesignerItemWidthEvent extends FormSectionDesignEvent {
  final String id;
  final double widthPercentage;

  const UpdateDesignerItemWidthEvent(this.id, this.widthPercentage);

  @override
  List<Object> get props => [id, widthPercentage];
}

class UpdateDesignerItemAlignmentEvent extends FormSectionDesignEvent {
  final String id;
  final DesignerItemAlignment alignment;

  const UpdateDesignerItemAlignmentEvent(this.id, this.alignment);

  @override
  List<Object> get props => [id, alignment];
}

class UpdateDesignerItemPaddingEvent extends FormSectionDesignEvent {
  final String id;
  final double padding;

  const UpdateDesignerItemPaddingEvent(this.id, this.padding);

  @override
  List<Object> get props => [id, padding];
}

class UpdateDesignerItemButtonWidthModeEvent extends FormSectionDesignEvent {
  final String id;
  final ButtonWidthMode buttonWidthMode;

  const UpdateDesignerItemButtonWidthModeEvent(this.id, this.buttonWidthMode);

  @override
  List<Object> get props => [id, buttonWidthMode];
}

class UpdateDesignerItemButtonWidthEvent extends FormSectionDesignEvent {
  final String id;
  final double buttonWidth;

  const UpdateDesignerItemButtonWidthEvent(this.id, this.buttonWidth);

  @override
  List<Object> get props => [id, buttonWidth];
}

class UpdateDesignerItemButtonColorEvent extends FormSectionDesignEvent {
  final String id;
  final String buttonColorHex;

  const UpdateDesignerItemButtonColorEvent(this.id, this.buttonColorHex);

  @override
  List<Object> get props => [id, buttonColorHex];
}

class UpdateDesignerItemButtonTextColorEvent extends FormSectionDesignEvent {
  final String id;
  final String buttonTextColorHex;

  const UpdateDesignerItemButtonTextColorEvent(
    this.id,
    this.buttonTextColorHex,
  );

  @override
  List<Object> get props => [id, buttonTextColorHex];
}

class UpdateDesignerItemTextAreaHeightEvent extends FormSectionDesignEvent {
  final String id;
  final double textAreaHeight;

  const UpdateDesignerItemTextAreaHeightEvent(this.id, this.textAreaHeight);

  @override
  List<Object> get props => [id, textAreaHeight];
}

class UpdateDesignerItemGroupedEvent extends FormSectionDesignEvent {
  final String id;
  final bool isGrouped;

  const UpdateDesignerItemGroupedEvent(this.id, this.isGrouped);

  @override
  List<Object> get props => [id, isGrouped];
}

class UpdateDesignerItemOptionsTextEvent extends FormSectionDesignEvent {
  final String id;
  final String optionsText;

  const UpdateDesignerItemOptionsTextEvent(this.id, this.optionsText);

  @override
  List<Object> get props => [id, optionsText];
}

class UpdateDesignerItemOptionLayoutEvent extends FormSectionDesignEvent {
  final String id;
  final DesignerItemOptionLayout optionLayout;

  const UpdateDesignerItemOptionLayoutEvent(this.id, this.optionLayout);

  @override
  List<Object> get props => [id, optionLayout];
}

class UpdateDesignerItemOptionSpacingEvent extends FormSectionDesignEvent {
  final String id;
  final double optionSpacing;

  const UpdateDesignerItemOptionSpacingEvent(this.id, this.optionSpacing);

  @override
  List<Object> get props => [id, optionSpacing];
}

class UpdateDesignerItemDateFormatEvent extends FormSectionDesignEvent {
  final String id;
  final String dateFormat;

  const UpdateDesignerItemDateFormatEvent(this.id, this.dateFormat);

  @override
  List<Object> get props => [id, dateFormat];
}

class UpdateDesignerItemFontSizeEvent extends FormSectionDesignEvent {
  final String id;
  final double fontSize;

  const UpdateDesignerItemFontSizeEvent(this.id, this.fontSize);

  @override
  List<Object> get props => [id, fontSize];
}

class UpdateDesignerItemBoldEvent extends FormSectionDesignEvent {
  final String id;
  final bool isBold;

  const UpdateDesignerItemBoldEvent(this.id, this.isBold);

  @override
  List<Object> get props => [id, isBold];
}

class UpdateDesignerItemAllowedTypesEvent extends FormSectionDesignEvent {
  final String id;
  final String allowedTypes;

  const UpdateDesignerItemAllowedTypesEvent(this.id, this.allowedTypes);

  @override
  List<Object> get props => [id, allowedTypes];
}

class UpdateDesignerItemMaxSizeEvent extends FormSectionDesignEvent {
  final String id;
  final int maxSize;

  const UpdateDesignerItemMaxSizeEvent(this.id, this.maxSize);

  @override
  List<Object> get props => [id, maxSize];
}

class SaveDraftEvent extends FormSectionDesignEvent {
  const SaveDraftEvent();
}

class SubmitSaveDraftEvent extends FormSectionDesignEvent {
  final String formName;
  final String description;

  const SubmitSaveDraftEvent(this.formName, this.description);

  @override
  List<Object> get props => [formName, description];
}

class CompleteSaveDraftPromptEvent extends FormSectionDesignEvent {
  const CompleteSaveDraftPromptEvent();
}

class UpdateDesignerItemRequiredEvent extends FormSectionDesignEvent {
  final String id;
  final bool required;

  const UpdateDesignerItemRequiredEvent(this.id, this.required);

  @override
  List<Object> get props => [id, required];
}

class UpdateDesignerItemReadonlyEvent extends FormSectionDesignEvent {
  final String id;
  final bool readonly;

  const UpdateDesignerItemReadonlyEvent(this.id, this.readonly);

  @override
  List<Object> get props => [id, readonly];
}

class UpdateDesignerItemInputTypeEvent extends FormSectionDesignEvent {
  final String id;
  final TextInputTypeMode inputType;

  const UpdateDesignerItemInputTypeEvent(this.id, this.inputType);

  @override
  List<Object> get props => [id, inputType];
}

class UpdateDesignerItemDataSourceUrlEvent extends FormSectionDesignEvent {
  final String id;
  final String dataSourceUrl;

  const UpdateDesignerItemDataSourceUrlEvent(this.id, this.dataSourceUrl);

  @override
  List<Object> get props => [id, dataSourceUrl];
}

class UpdateDesignerItemDataSourceKeyEvent extends FormSectionDesignEvent {
  final String id;
  final String dataSourceKey;

  const UpdateDesignerItemDataSourceKeyEvent(this.id, this.dataSourceKey);

  @override
  List<Object> get props => [id, dataSourceKey];
}

class UpdateDesignerItemComputedFieldKeyEvent extends FormSectionDesignEvent {
  final String id;
  final String computedFieldKey;

  const UpdateDesignerItemComputedFieldKeyEvent(
    this.id,
    this.computedFieldKey,
  );

  @override
  List<Object> get props => [id, computedFieldKey];
}
