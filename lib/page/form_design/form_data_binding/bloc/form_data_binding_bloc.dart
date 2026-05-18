import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';

part 'form_data_binding_event.dart';
part 'form_data_binding_state.dart';

class FormDataBindingBloc
    extends Bloc<FormDataBindingEvent, FormDataBindingState> {
  final FormDataBindingService _formDataBindingService;

  FormDataBindingBloc(this._formDataBindingService)
      : super(const FormDataBindingState()) {
    on<CompleteNavigationEvent>(_onCompleteNavigationEvent);
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
    on<ConfirmSaveDraftEvent>(_onConfirmSaveDraftEvent);
    on<ExportJsonPreviewEvent>(_onExportJsonPreviewEvent);
    on<InitEvent>(_onInitEvent);
    on<RequestNavigateToActionBindingEvent>(_onRequestNavigateToActionBinding);
    on<RequestSaveDraftEvent>(_onRequestSaveDraftEvent);
    on<UpdateBindingEnabledEvent>(_onUpdateBindingEnabledEvent);
    on<UpdateCustomDefaultValueEvent>(_onUpdateCustomDefaultValueEvent);
    on<UpdateNullStrategyEvent>(_onUpdateNullStrategyEvent);
    on<UpdateProvidedDataKeyEvent>(_onUpdateProvidedDataKeyEvent);
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
        pendingBindingName: '',
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
      pendingBindingName: '',
      message: '',
    ));
  }

  void _onCompleteNavigationEvent(
    CompleteNavigationEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    emit(state.copyWith(
      status: FormDataBindingStatus.ready,
      navigateFormId: '',
      navigateBindingId: '',
      navigateSourceItemId: '',
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

  void _onRequestSaveDraftEvent(
    RequestSaveDraftEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
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
      status: FormDataBindingStatus.confirmBindingName,
      pendingBindingName: state.draft.bindingName,
      fieldErrors: errors,
      message: '',
    ));
  }

  void _onRequestNavigateToActionBinding(
    RequestNavigateToActionBindingEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    emit(state.copyWith(
      status: FormDataBindingStatus.navigateToActionBinding,
      navigateFormId: state.formId,
      navigateBindingId: state.bindingId,
      navigateSourceItemId: event.sourceItemId,
      message: '',
    ));
  }

  Future<void> _onConfirmSaveDraftEvent(
    ConfirmSaveDraftEvent event,
    Emitter<FormDataBindingState> emit,
  ) async {
    final normalizedBindingName = event.bindingName.trim();
    if (normalizedBindingName.isEmpty) {
      emit(state.copyWith(
        status: FormDataBindingStatus.failure,
        message: '請輸入綁定名稱',
      ));
      return;
    }

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
      pendingBindingName: '',
      message: '',
    ));

    final now = DateTime.now();
    final draft = state.draft.copyWith(
      bindingName: normalizedBindingName,
      updatedAt: now.toIso8601String(),
    );
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
        // 切到非 custom 時清空 customDefaultValue
        customDefaultValue: event.nullStrategy == BindingNullStrategy.custom
            ? field.customDefaultValue
            : '',
        // 切到非 injected 時清空 providedDataKey
        providedDataKey: event.nullStrategy == BindingNullStrategy.injected
            ? field.providedDataKey
            : '',
      ),
    );
    _emitUpdatedDraft(emit, draft);
  }

  void _onUpdateProvidedDataKeyEvent(
    UpdateProvidedDataKeyEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    final draft = state.draft.updateField(
      event.sectionId,
      event.itemId,
      (field) => field.copyWith(providedDataKey: event.providedDataKey),
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

  void _onUpdateBindingEnabledEvent(
    UpdateBindingEnabledEvent event,
    Emitter<FormDataBindingState> emit,
  ) {
    final draft = state.draft.copyWith(isEnabled: event.isEnabled);
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
      pendingBindingName: '',
      message: '',
    ));
  }
}
