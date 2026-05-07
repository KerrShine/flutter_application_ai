part of 'form_condition_field_bloc.dart';

abstract class FormConditionFieldEvent extends Equatable {
  const FormConditionFieldEvent();

  @override
  List<Object?> get props => [];
}

class InitConditionFieldEvent extends FormConditionFieldEvent {
  final String formId;
  final String formName;
  const InitConditionFieldEvent({required this.formId, this.formName = ''});
  @override
  List<Object?> get props => [formId, formName];
}

class AddConditionDefinitionEvent extends FormConditionFieldEvent {
  final ConditionFieldDefinition definition;
  const AddConditionDefinitionEvent(this.definition);
  @override
  List<Object?> get props => [definition];
}

class UpdateConditionDefinitionEvent extends FormConditionFieldEvent {
  final String originalFieldKey;
  final ConditionFieldDefinition definition;
  const UpdateConditionDefinitionEvent(
      this.originalFieldKey, this.definition);
  @override
  List<Object?> get props => [originalFieldKey, definition];
}

class RemoveConditionDefinitionEvent extends FormConditionFieldEvent {
  final String fieldKey;
  const RemoveConditionDefinitionEvent(this.fieldKey);
  @override
  List<Object?> get props => [fieldKey];
}

class SaveConditionDraftEvent extends FormConditionFieldEvent {
  const SaveConditionDraftEvent();
}

class DismissConditionMessageEvent extends FormConditionFieldEvent {
  const DismissConditionMessageEvent();
}
