import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';
import 'package:flutter_application_ai/model/condition_field_draft.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';

part 'form_condition_field_event.dart';
part 'form_condition_field_state.dart';

class FormConditionFieldBloc
    extends Bloc<FormConditionFieldEvent, FormConditionFieldState> {
  final ConditionFieldService _service;

  FormConditionFieldBloc(this._service)
      : super(const FormConditionFieldState()) {
    on<InitConditionFieldEvent>(_onInit);
    on<AddConditionDefinitionEvent>(_onAddDefinition);
    on<UpdateConditionDefinitionEvent>(_onUpdateDefinition);
    on<RemoveConditionDefinitionEvent>(_onRemoveDefinition);
    on<SaveConditionDraftEvent>(_onSaveDraft);
    on<DismissConditionMessageEvent>(_onDismissMessage);
  }

  Future<void> _onInit(
    InitConditionFieldEvent event,
    Emitter<FormConditionFieldState> emit,
  ) async {
    emit(state.copyWith(
      status: FormConditionFieldStatus.loading,
      formId: event.formId,
      message: '',
    ));

    final draftResult = await _service.loadDraft(event.formId);
    final itemsResult = await _service.loadFormItems(event.formId);

    if (!draftResult.isSuccess || !itemsResult.isSuccess) {
      emit(state.copyWith(
        status: FormConditionFieldStatus.failure,
        message: draftResult.error ?? itemsResult.error ?? '載入失敗',
      ));
      return;
    }

    final draft = draftResult.data ??
        ConditionFieldDraft(
          formId: event.formId,
          formName: event.formName,
        );
    final normalizedDraft = draft.copyWith(
      formName: event.formName.isNotEmpty ? event.formName : draft.formName,
    );

    emit(state.copyWith(
      status: FormConditionFieldStatus.ready,
      formId: event.formId,
      draft: normalizedDraft,
      availableItems: itemsResult.data ?? const [],
      isDirty: false,
      message: '',
    ));
  }

  void _onAddDefinition(
    AddConditionDefinitionEvent event,
    Emitter<FormConditionFieldState> emit,
  ) {
    final updated = List<ConditionFieldDefinition>.from(state.draft.definitions)
      ..add(event.definition);
    emit(state.copyWith(
      draft: state.draft.copyWith(definitions: updated),
      isDirty: true,
      message: '',
    ));
  }

  void _onUpdateDefinition(
    UpdateConditionDefinitionEvent event,
    Emitter<FormConditionFieldState> emit,
  ) {
    final updated = state.draft.definitions
        .map((d) =>
            d.fieldKey == event.originalFieldKey ? event.definition : d)
        .toList();
    emit(state.copyWith(
      draft: state.draft.copyWith(definitions: updated),
      isDirty: true,
      message: '',
    ));
  }

  void _onRemoveDefinition(
    RemoveConditionDefinitionEvent event,
    Emitter<FormConditionFieldState> emit,
  ) {
    final updated = state.draft.definitions
        .where((d) => d.fieldKey != event.fieldKey)
        .toList();
    emit(state.copyWith(
      draft: state.draft.copyWith(definitions: updated),
      isDirty: true,
      message: '',
    ));
  }

  Future<void> _onSaveDraft(
    SaveConditionDraftEvent event,
    Emitter<FormConditionFieldState> emit,
  ) async {
    emit(state.copyWith(status: FormConditionFieldStatus.saving));
    final result = await _service.saveDraft(state.draft);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormConditionFieldStatus.saved,
        isDirty: false,
        message: '已儲存條件欄位設定',
      ));
    } else {
      emit(state.copyWith(
        status: FormConditionFieldStatus.failure,
        message: result.error ?? '儲存失敗',
      ));
    }
  }

  void _onDismissMessage(
    DismissConditionMessageEvent event,
    Emitter<FormConditionFieldState> emit,
  ) {
    emit(state.copyWith(
      status: FormConditionFieldStatus.ready,
      message: '',
    ));
  }
}
