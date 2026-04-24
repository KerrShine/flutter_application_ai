import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/model/form_run_field_value.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/service/form_run_service.dart';

part 'form_run_event.dart';
part 'form_run_state.dart';

class FormRunBloc extends Bloc<FormRunEvent, FormRunState> {
  final FormRunService _formRunService;

  FormRunBloc(this._formRunService) : super(const FormRunState()) {
    on<FormRunInitEvent>(_onInit);
    on<FormRunFieldChangedEvent>(_onFieldChanged);
    on<FormRunButtonPressedEvent>(_onButtonPressed);
    on<FormRunDropdownLoadedEvent>(_onDropdownLoaded);
    on<FormRunDropdownChangedEvent>(_onDropdownChanged);
    on<FormRunDismissResultEvent>(_onDismissResult);
  }

  Future<void> _onInit(
    FormRunInitEvent event,
    Emitter<FormRunState> emit,
  ) async {
    emit(state.copyWith(
      status: FormRunStatus.loading,
      formId: event.formId,
      bindingId: event.bindingId,
    ));

    final result =
        await _formRunService.initialize(event.formId, event.bindingId);
    if (!result.isSuccess) {
      emit(state.copyWith(
        status: FormRunStatus.actionFailure,
        message: result.error ?? '載入表單失敗',
      ));
      return;
    }

    final data = result.data!;
    emit(state.copyWith(
      status: FormRunStatus.ready,
      formName: data.draft.formName,
      sections: data.sections,
      draft: data.draft,
      apiMap: data.apiMap,
      fieldValues: data.fieldValues,
      message: '',
      clearNavigateRoute: true,
      clearApiResponse: true,
    ));

    // 自動觸發 dropdownLoaded 事件
    for (final section in data.draft.sections) {
      for (final field in section.fields) {
        if (field.sourceType == 'dropdown') {
          add(FormRunDropdownLoadedEvent(field.itemId));
        }
      }
    }
  }

  void _onFieldChanged(
    FormRunFieldChangedEvent event,
    Emitter<FormRunState> emit,
  ) {
    final updated = Map<String, FormRunFieldValue>.from(state.fieldValues);
    if (updated.containsKey(event.itemId)) {
      updated[event.itemId] = updated[event.itemId]!.copyWith(value: event.value);
    }
    emit(state.copyWith(
      status: FormRunStatus.ready,
      fieldValues: updated,
    ));
  }

  Future<void> _onButtonPressed(
    FormRunButtonPressedEvent event,
    Emitter<FormRunState> emit,
  ) async {
    final matchingActions = state.draft.actions
        .where((a) =>
            a.sourceItemId == event.itemId &&
            a.triggerType == ActionTriggerType.buttonPressed &&
            a.enabled)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (matchingActions.isEmpty) return;

    // navigate-only 序列不需要 loading overlay（無 API 呼叫）
    final hasApiAction = matchingActions.any((a) =>
        a.actionType == ActionType.callApi ||
        a.actionType == ActionType.submitForm ||
        a.actionType == ActionType.saveDraft);

    if (hasApiAction) {
      emit(state.copyWith(status: FormRunStatus.executingAction, message: ''));
    }

    final params = _formRunService.buildApiParams(state.fieldValues);

    for (final action in matchingActions) {
      switch (action.actionType) {
        case ActionType.callApi:
        case ActionType.submitForm:
          final apiResult = await _formRunService.executeCallApi(
            action,
            state.apiMap,
            params,
          );
          if (!apiResult.isSuccess) {
            emit(state.copyWith(
              status: FormRunStatus.actionFailure,
              message: apiResult.error ?? 'API 呼叫失敗',
            ));
            return; // 失敗中斷後續動作
          }
          if (action.actionType == ActionType.submitForm &&
              action.navigateRoute.isNotEmpty) {
            emit(state.copyWith(
              status: FormRunStatus.navigating,
              pendingNavigateRoute: action.navigateRoute,
              lastApiResponse: apiResult.data,
            ));
            return;
          }
          emit(state.copyWith(
            status: FormRunStatus.actionSuccess,
            message: '執行成功',
            lastApiResponse: apiResult.data,
          ));

        case ActionType.navigate:
          if (action.navigateRoute.isEmpty) {
            emit(state.copyWith(
              status: FormRunStatus.actionFailure,
              message: 'navigate 動作未設定目標頁面，請至事件設定補充路由',
            ));
            return;
          }
          emit(state.copyWith(
            status: FormRunStatus.navigating,
            pendingNavigateRoute: action.navigateRoute,
          ));
          return;

        case ActionType.saveDraft:
          final saveResult = await _formRunService.executeSaveDraft(
            state.formId,
            state.bindingId,
            state.fieldValues,
          );
          if (!saveResult.isSuccess) {
            emit(state.copyWith(
              status: FormRunStatus.actionFailure,
              message: saveResult.error ?? '儲存草稿失敗',
            ));
            return;
          }
          emit(state.copyWith(
            status: FormRunStatus.actionSuccess,
            message: '草稿已儲存',
          ));

        case ActionType.other:
        case ActionType.loadDropdownOptions:
        case ActionType.refreshTarget:
        case ActionType.setFieldValue:
          break;
      }
    }
  }

  Future<void> _onDropdownLoaded(
    FormRunDropdownLoadedEvent event,
    Emitter<FormRunState> emit,
  ) async {
    final action = state.draft.actions
        .cast<FormActionBindingDraft?>()
        .firstWhere(
          (a) =>
              a?.sourceItemId == event.itemId &&
              a?.triggerType == ActionTriggerType.dropdownLoaded &&
              a?.actionType == ActionType.loadDropdownOptions,
          orElse: () => null,
        );

    if (action == null) return;

    // 有 apiId → 從 API 取得選項
    if (action.apiId.isNotEmpty) {
      // 找 dataSourceKey（來自 DesignerItem）
      String dataSourceKey = '';
      for (final section in state.sections) {
        for (final item in section.items) {
          if (item.id == event.itemId) {
            dataSourceKey = item.dataSourceKey;
            break;
          }
        }
      }

      final result = await _formRunService.executeLoadDropdownOptions(
        action,
        state.apiMap,
        dataSourceKey,
      );

      if (!result.isSuccess || result.data == null) return;

      final updated =
          Map<String, List<String>>.from(state.dropdownOptionsOverride);
      updated[event.itemId] = result.data!;

      emit(state.copyWith(
        status: FormRunStatus.ready,
        dropdownOptionsOverride: updated,
      ));
      return;
    }

    // 無 apiId → fallback: 從 targetItemId 靜態選項讀取（舊行為）
    if (action.targetItemId.isEmpty) return;

    List<String>? options;
    for (final section in state.sections) {
      for (final item in section.items) {
        if (item.id == action.targetItemId) {
          options = item.options;
          break;
        }
      }
      if (options != null) break;
    }

    if (options == null || options.isEmpty) return;

    final updated =
        Map<String, List<String>>.from(state.dropdownOptionsOverride);
    updated[event.itemId] = options;

    emit(state.copyWith(
      status: FormRunStatus.ready,
      dropdownOptionsOverride: updated,
    ));
  }

  void _onDropdownChanged(
    FormRunDropdownChangedEvent event,
    Emitter<FormRunState> emit,
  ) {
    final updated = Map<String, FormRunFieldValue>.from(state.fieldValues);
    if (updated.containsKey(event.itemId)) {
      updated[event.itemId] =
          updated[event.itemId]!.copyWith(value: event.value);
    }
    emit(state.copyWith(
      status: FormRunStatus.ready,
      fieldValues: updated,
    ));
  }

  void _onDismissResult(
    FormRunDismissResultEvent event,
    Emitter<FormRunState> emit,
  ) {
    emit(state.copyWith(
      status: FormRunStatus.ready,
      message: '',
      clearApiResponse: true,
    ));
  }
}
