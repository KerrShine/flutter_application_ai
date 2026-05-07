part of 'form_condition_field_bloc.dart';

enum FormConditionFieldStatus { initial, loading, ready, saving, saved, failure }

class FormConditionFieldState extends Equatable {
  final FormConditionFieldStatus status;
  final String formId;
  final ConditionFieldDraft draft;
  final List<ConditionArgItemChoice> availableItems;
  final bool isDirty;
  final String message;

  const FormConditionFieldState({
    this.status = FormConditionFieldStatus.initial,
    this.formId = '',
    this.draft = const ConditionFieldDraft(formId: ''),
    this.availableItems = const [],
    this.isDirty = false,
    this.message = '',
  });

  FormConditionFieldState copyWith({
    FormConditionFieldStatus? status,
    String? formId,
    ConditionFieldDraft? draft,
    List<ConditionArgItemChoice>? availableItems,
    bool? isDirty,
    String? message,
  }) {
    return FormConditionFieldState(
      status: status ?? this.status,
      formId: formId ?? this.formId,
      draft: draft ?? this.draft,
      availableItems: availableItems ?? this.availableItems,
      isDirty: isDirty ?? this.isDirty,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [status, formId, draft, availableItems, isDirty, message];
}
