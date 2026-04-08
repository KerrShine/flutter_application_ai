import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';

part 'form_data_binding_event.dart';
part 'form_data_binding_state.dart';

class FormDataBindingBloc
    extends Bloc<FormDataBindingEvent, FormDataBindingState> {
  final FormDataBindingService _formDataBindingService;

  FormDataBindingBloc(this._formDataBindingService)
      : super(const FormDataBindingState()) {
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
    on<ExportJsonPreviewEvent>(_onExportJsonPreviewEvent);
    on<InitEvent>(_onInitEvent);
    on<SaveDraftEvent>(_onSaveDraftEvent);
    on<UpdateCustomDefaultValueEvent>(_onUpdateCustomDefaultValueEvent);
    on<UpdateNullStrategyEvent>(_onUpdateNullStrategyEvent);
    on<UpdateOutputKeyEvent>(_onUpdateOutputKeyEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<FormDataBindingState> emit,
  ) async {
    emit(state.copyWith(
      status: FormDataBindingStatus.loading,
      formId: event.formId,
      bindingId: event.bindingId,
      message: '',
    ));

    final result = await _formDataBindingService.initialize(
      event.formId,
      bindingId: event.bindingId,
    );
    if (result.isSuccess) {
      final draft = result.data ?? const FormDataBindingDraft();
      emit(state.copyWith(
        status: FormDataBindingStatus.ready,
        formId: event.formId,
        bindingId: draft.bindingId,
        formName: draft.formName,
        draft: draft,
        fieldErrors: _formDataBindingService.validateDraft(draft),
        message: '',
      ));
      return;
    }

    emit(state.copyWith(
      status: FormDataBindingStatus.failure,
      formId: event.formId,
      bindingId: event.bindingId,
      message: result.error ?? '讀取資料綁定執行設定失敗',
    ));
  }

  void _onCompleteStatusEvent(
    CompleteStatusEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    emit(state.copyWith(
      status: FormDataBindingStatus.ready,
      message: '',
    ));
  }

  void _onExportJsonPreviewEvent(
    ExportJsonPreviewEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    emit(state.copyWith(
      status: FormDataBindingStatus.exportJsonPreview,
      exportedJson: _formDataBindingService.buildExportPreviewJson(state.draft),
      message: '',
    ));
  }

  Future<void> _onSaveDraftEvent(
    SaveDraftEvent event,
    Emitter<FormDataBindingState> emit,
  ) async {
    final errors = _formDataBindingService.validateDraft(state.draft);
    if (errors.isNotEmpty) {
      emit(state.copyWith(
        status: FormDataBindingStatus.failure,
        fieldErrors: errors,
        message: '仍有欄位設定未完成，請先修正後再儲存',
      ));
      return;
    }

    emit(state.copyWith(
      status: FormDataBindingStatus.saving,
      message: '',
    ));

    final now = DateTime.now();
    final draft = state.draft.copyWith(updatedAt: now.toIso8601String());
    final result = await _formDataBindingService.saveDraft(draft);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormDataBindingStatus.saveSuccess,
        draft: draft,
        message: '已暫存到 local storage',
      ));
      return;
    }

    emit(state.copyWith(
      status: FormDataBindingStatus.failure,
      message: result.error ?? '暫存資料綁定設定失敗',
    ));
  }

  void _onUpdateCustomDefaultValueEvent(
    UpdateCustomDefaultValueEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    final draft = state.draft.updateField(
      event.sectionId,
      event.itemId,
      (field) => field.copyWith(customDefaultValue: event.value),
    );
    _emitUpdatedDraft(emit, draft);
  }

  void _onUpdateNullStrategyEvent(
    UpdateNullStrategyEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    final draft = state.draft.updateField(
      event.sectionId,
      event.itemId,
      (field) => field.copyWith(
        nullStrategy: event.nullStrategy,
        customDefaultValue: event.nullStrategy == BindingNullStrategy.skip
            ? ''
            : field.customDefaultValue,
      ),
    );
    _emitUpdatedDraft(emit, draft);
  }

  void _onUpdateOutputKeyEvent(
    UpdateOutputKeyEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    final draft = state.draft.updateField(
      event.sectionId,
      event.itemId,
      (field) => field.copyWith(outputKey: event.outputKey),
    );
    _emitUpdatedDraft(emit, draft);
  }

  void _emitUpdatedDraft(
    Emitter<FormDataBindingState> emit,
    FormDataBindingDraft draft,
  ) {
    emit(state.copyWith(
      status: FormDataBindingStatus.ready,
      draft: draft,
      fieldErrors: _formDataBindingService.validateDraft(draft),
      message: '',
    ));
  }
}
