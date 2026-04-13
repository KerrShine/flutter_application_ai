import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';

part 'form_action_binding_event.dart';
part 'form_action_binding_state.dart';

class FormActionBindingBloc
    extends Bloc<FormActionBindingEvent, FormActionBindingState> {
  final FormActionBindingService _formActionBindingService;

  FormActionBindingBloc(this._formActionBindingService)
      : super(const FormActionBindingState()) {
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
    on<InitEvent>(_onInitEvent);
    on<RequestExportPreviewEvent>(_onRequestExportPreviewEvent);
    on<SaveActionSettingsEvent>(_onSaveActionSettingsEvent);
    on<SelectActionEvent>(_onSelectActionEvent);
    on<SelectSourceItemEvent>(_onSelectSourceItemEvent);
    on<SelectTriggerEvent>(_onSelectTriggerEvent);
    on<UpdateSearchKeywordEvent>(_onUpdateSearchKeywordEvent);
  }

  void _onCompleteStatusEvent(
    CompleteStatusEvent event,
    Emitter<FormActionBindingState> emit,
  ) {
    emit(state.copyWith(
      status: FormActionBindingStatus.ready,
      message: '',
    ));
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<FormActionBindingState> emit,
  ) async {
    emit(state.copyWith(
      status: FormActionBindingStatus.loading,
      formId: event.formId,
      bindingId: event.bindingId,
      message: '',
    ));

    final result = await _formActionBindingService.initialize(
      event.formId,
      bindingId: event.bindingId,
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        status: FormActionBindingStatus.failure,
        formId: event.formId,
        bindingId: event.bindingId,
        message: result.error ?? '讀取動作綁定資料失敗',
      ));
      return;
    }

    final data = result.data;
    final draft = data?.draft;
    final sourceItems = data?.actionSources ?? const <FormActionSourceItem>[];
    final selectedSourceItemId = sourceItems.any(
      (item) => item.itemId == event.initialSourceItemId,
    )
        ? event.initialSourceItemId
        : (sourceItems.isEmpty ? '' : sourceItems.first.itemId);
    final selectedSourceItem = sourceItems.where(
      (item) => item.itemId == selectedSourceItemId,
    );
    final selectedTrigger = selectedSourceItem.isEmpty
        ? ''
        : (selectedSourceItem.first.availableTriggers.isEmpty
            ? ''
            : selectedSourceItem.first.availableTriggers.first);

    emit(state.copyWith(
      status: FormActionBindingStatus.ready,
      formId: draft?.formId ?? event.formId,
      bindingId: draft?.bindingId ?? event.bindingId,
      draft: draft ?? const FormDataBindingDraft(),
      formName: draft?.formName ?? '',
      bindingName: draft?.bindingName ?? '',
      sourceItems: sourceItems,
      selectedSourceItemId: selectedSourceItemId,
      selectedTrigger: selectedTrigger,
      previewJson: data?.previewJson ?? '',
      actions: draft?.actions ?? const <FormActionBindingDraft>[],
      message: '',
    ));
  }

  void _onSelectSourceItemEvent(
    SelectSourceItemEvent event,
    Emitter<FormActionBindingState> emit,
  ) {
    final selectedSourceItem = state.sourceItems.where(
      (item) => item.itemId == event.itemId,
    );
    final selectedTrigger = selectedSourceItem.isEmpty
        ? ''
        : (selectedSourceItem.first.availableTriggers.isEmpty
            ? ''
            : selectedSourceItem.first.availableTriggers.first);

    emit(state.copyWith(
      status: FormActionBindingStatus.ready,
      selectedSourceItemId: event.itemId,
      selectedTrigger: selectedTrigger,
      message: '',
    ));
  }

  void _onSelectActionEvent(
    SelectActionEvent event,
    Emitter<FormActionBindingState> emit,
  ) {
    final selected = state.selectedSourceItem;
    if (selected == null || state.selectedTrigger.isEmpty) {
      return;
    }

    final actionType = _resolveActionType(event.action);
    final triggerType = _resolveTriggerType(state.selectedTrigger);
    if (actionType == null || triggerType == null) {
      return;
    }

    final currentAction = state.selectedTriggerActions.isEmpty
        ? null
        : state.selectedTriggerActions.first;
    if (currentAction != null && currentAction.actionType == actionType) {
      return;
    }

    final actions = List<FormActionBindingDraft>.from(state.actions)
      ..removeWhere((item) {
        return item.sourceItemId == selected.itemId &&
            item.triggerType == triggerType;
      })
      ..add(
        FormActionBindingDraft(
          actionId:
              '${selected.itemId}_${state.selectedTrigger}_${event.action}',
          sourceItemId: selected.itemId,
          sourceLabel: selected.label,
          sourceType: selected.sourceType,
          triggerType: triggerType,
          actionType: actionType,
          enabled: true,
          description: _buildActionDescription(
            trigger: state.selectedTrigger,
            action: event.action,
          ),
        ),
      );

    emit(state.copyWith(
      status: FormActionBindingStatus.ready,
      draft: state.draft.copyWith(actions: actions),
      actions: actions,
      previewJson:
          _formActionBindingService.buildActionPlanPreviewJsonFromState(
        bindingId: state.bindingId,
        bindingName: state.bindingName,
        formId: state.formId,
        formName: state.formName,
        actions: actions,
        actionSources: state.sourceItems,
      ),
      message: '',
    ));
  }

  Future<void> _onSaveActionSettingsEvent(
    SaveActionSettingsEvent event,
    Emitter<FormActionBindingState> emit,
  ) async {
    emit(state.copyWith(
      status: FormActionBindingStatus.saving,
      message: '',
    ));

    final result = await _formActionBindingService.saveActionSettings(
      draft: state.draft,
      actions: state.actions,
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        status: FormActionBindingStatus.failure,
        message: result.error ?? '儲存動作設定失敗',
      ));
      return;
    }

    final savedDraft =
        result.data ?? state.draft.copyWith(actions: state.actions);
    emit(state.copyWith(
      status: FormActionBindingStatus.saveSuccess,
      draft: savedDraft,
      bindingId: savedDraft.bindingId,
      bindingName: savedDraft.bindingName,
      actions: savedDraft.actions,
      previewJson:
          _formActionBindingService.buildActionPlanPreviewJsonFromState(
        bindingId: savedDraft.bindingId,
        bindingName: savedDraft.bindingName,
        formId: savedDraft.formId,
        formName: savedDraft.formName,
        actions: savedDraft.actions,
        actionSources: state.sourceItems,
      ),
      message: '已將動作設定寫回 local storage',
    ));
  }

  void _onSelectTriggerEvent(
    SelectTriggerEvent event,
    Emitter<FormActionBindingState> emit,
  ) {
    emit(state.copyWith(
      status: FormActionBindingStatus.ready,
      selectedTrigger: event.trigger,
      message: '',
    ));
  }

  void _onRequestExportPreviewEvent(
    RequestExportPreviewEvent event,
    Emitter<FormActionBindingState> emit,
  ) {
    emit(state.copyWith(
      status: FormActionBindingStatus.exportPreview,
      message: '',
    ));
  }

  void _onUpdateSearchKeywordEvent(
    UpdateSearchKeywordEvent event,
    Emitter<FormActionBindingState> emit,
  ) {
    emit(state.copyWith(
      status: FormActionBindingStatus.ready,
      searchKeyword: event.keyword,
      message: '',
    ));
  }

  ActionType? _resolveActionType(String action) {
    for (final item in ActionType.values) {
      if (item.name == action) {
        return item;
      }
    }

    return null;
  }

  ActionTriggerType? _resolveTriggerType(String trigger) {
    for (final item in ActionTriggerType.values) {
      if (item.name == trigger) {
        return item;
      }
    }

    return null;
  }

  String _buildActionDescription({
    required String trigger,
    required String action,
  }) {
    return '${formActionTriggerDisplayName(trigger)} -> ${formActionDisplayName(action)}';
  }
}
