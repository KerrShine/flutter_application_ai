import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';
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
      applicantId: event.applicantId,
      applicantName: event.applicantName,
      departmentId: event.departmentId,
      signOffId: event.signOffId,
    ));

    final result = await _formRunService.initialize(
      event.formId,
      event.bindingId,
      signOffId: event.signOffId,
      currentEmployeeId: event.applicantId,
      currentEmployeeName: event.applicantName,
      currentEmployeeCode: event.applicantCode,
      currentDepartmentName: event.departmentName,
      currentRoleName: event.roleName,
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        status: FormRunStatus.actionFailure,
        message: result.error ?? '載入表單失敗',
      ));
      return;
    }

    final data = result.data!;
    final initialComputed = await _evaluate(
      event.formId,
      data.fieldValues,
    );
    emit(state.copyWith(
      status: FormRunStatus.ready,
      formName: data.draft.formName,
      sections: data.sections,
      draft: data.draft,
      apiMap: data.apiMap,
      fieldValues: data.fieldValues,
      conditionDefinitions: data.conditionDefinitions,
      computedValues: initialComputed,
      message: '',
      clearNavigateRoute: true,
      clearApiResponse: true,
    ));

    // DEBUG: 檢查 apiMap 內容
    // ignore: avoid_print
    print('[FormRunBloc] apiMap keys: ${data.apiMap.keys.toList()}');
    // ignore: avoid_print
    print('[FormRunBloc] actions count: ${data.draft.actions.length}');
    for (final a in data.draft.actions) {
      // ignore: avoid_print
      print(
          '[FormRunBloc]   action: ${a.actionId} | type=${a.actionType.name} | apiId="${a.apiId}" | parameterName="${a.parameterName}" | source=${a.sourceItemId}');
    }

    // 自動觸發 dropdownLoaded 事件
    for (final section in data.draft.sections) {
      for (final field in section.fields) {
        if (field.sourceType == 'dropdown') {
          // ignore: avoid_print
          print(
              '[FormRunBloc] 觸發 DropdownLoadedEvent: itemId=${field.itemId}, label=${field.label}');
          add(FormRunDropdownLoadedEvent(field.itemId));
        }
      }
    }
  }

  Future<void> _onFieldChanged(
    FormRunFieldChangedEvent event,
    Emitter<FormRunState> emit,
  ) async {
    final updated = Map<String, FormRunFieldValue>.from(state.fieldValues);
    if (updated.containsKey(event.itemId)) {
      updated[event.itemId] =
          updated[event.itemId]!.copyWith(value: event.value);
    }
    final computed = await _evaluate(state.formId, updated);
    emit(state.copyWith(
      status: FormRunStatus.ready,
      fieldValues: updated,
      computedValues: computed,
    ));
  }

  /// 用 ConditionFieldService 計算所有 condition fieldKey 的衍生值。
  /// 回傳 Map<fieldKey, computedValue>；formId 為空 / 無 condition draft 時回空 map。
  Future<Map<String, String>> _evaluate(
    String formId,
    Map<String, FormRunFieldValue> fieldValues,
  ) async {
    if (formId.isEmpty) return const {};
    final rawMap = fieldValues.map((k, v) => MapEntry(k, v.value));
    final result =
        await _formRunService.conditionFieldService.evaluate(formId, rawMap);
    return result.isSuccess ? (result.data ?? const {}) : const {};
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
          // 「測試寫入」特例 — 構造 SignOffInstance 寫入 LocalStorage，
          // 不走 executeCallApi 的 mock/真實 API 流程。
          // 編輯模式（state.signOffId 非空）走 update 分支覆寫該筆。
          final apiDef = state.apiMap[action.apiId];
          if (apiDef != null && apiDef.apiId == 'test_write_to_storage_api') {
            final isEdit = state.signOffId.isNotEmpty;
            final writeResult = isEdit
                ? await _formRunService.executeUpdateSignOff(
                    api: apiDef,
                    signOffId: state.signOffId,
                    sections: state.sections,
                    fieldValues: state.fieldValues,
                    computedValues: state.computedValues,
                  )
                : await _formRunService.executeTestWriteSignOff(
                    api: apiDef,
                    formId: state.formId,
                    formName: state.formName,
                    bindingId: state.bindingId,
                    applicantId: state.applicantId,
                    applicantName: state.applicantName,
                    departmentId: state.departmentId,
                    sections: state.sections,
                    fieldValues: state.fieldValues,
                    computedValues: state.computedValues,
                  );
            if (!writeResult.isSuccess) {
              emit(state.copyWith(
                status: FormRunStatus.actionFailure,
                message: writeResult.error ?? '測試寫入失敗',
              ));
              return;
            }
            emit(state.copyWith(
              status: FormRunStatus.actionSuccess,
              message: isEdit ? '已更新' : '測試寫入完成',
              lastApiResponse: writeResult.data,
            ));
            break;
          }

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
    // ignore: avoid_print
    print('[FormRunBloc] _onDropdownLoaded: itemId=${event.itemId}');

    // DEBUG: 列出所有 actions 供比對
    final allMatching = state.draft.actions.where((a) =>
        a.sourceItemId == event.itemId &&
        a.triggerType == ActionTriggerType.dropdownLoaded);
    // ignore: avoid_print
    print(
        '[FormRunBloc]   matching actions for this dropdown (dropdownLoaded): ${allMatching.length}');
    for (final m in allMatching) {
      // ignore: avoid_print
      print(
          '[FormRunBloc]     -> actionType=${m.actionType.name}, apiId="${m.apiId}", parameterName="${m.parameterName}"');
    }

    final action =
        state.draft.actions.cast<FormActionBindingDraft?>().firstWhere(
              (a) =>
                  a?.sourceItemId == event.itemId &&
                  a?.triggerType == ActionTriggerType.dropdownLoaded &&
                  a?.actionType == ActionType.loadDropdownOptions,
              orElse: () => null,
            );

    if (action == null) {
      // ignore: avoid_print
      print('[FormRunBloc]   ❌ 找不到 loadDropdownOptions action，跳過');
      return;
    }

    // ignore: avoid_print
    print(
        '[FormRunBloc]   ✅ 找到 action: apiId="${action.apiId}", parameterName="${action.parameterName}"');

    // 有 apiId → 從 API 取得選項（使用 action.parameterName 作為取值 key）
    if (action.apiId.isNotEmpty) {
      // ignore: avoid_print
      print(
          '[FormRunBloc]   呼叫 executeLoadDropdownOptions, apiId="${action.apiId}"');
      // ignore: avoid_print
      print(
          '[FormRunBloc]   apiMap 是否包含此 apiId: ${state.apiMap.containsKey(action.apiId)}');

      final result = await _formRunService.executeLoadDropdownOptions(
        action,
        state.apiMap,
      );

      // ignore: avoid_print
      print(
          '[FormRunBloc]   result: success=${result.isSuccess}, data=${result.data}, error=${result.error}');

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
    // ignore: avoid_print
    print(
        '[FormRunBloc]   apiId 為空，走 fallback 路徑, targetItemId="${action.targetItemId}"');
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

  Future<void> _onDropdownChanged(
    FormRunDropdownChangedEvent event,
    Emitter<FormRunState> emit,
  ) async {
    final updated = Map<String, FormRunFieldValue>.from(state.fieldValues);
    if (updated.containsKey(event.itemId)) {
      updated[event.itemId] =
          updated[event.itemId]!.copyWith(value: event.value);
    }
    final computed = await _evaluate(state.formId, updated);
    emit(state.copyWith(
      status: FormRunStatus.ready,
      fieldValues: updated,
      computedValues: computed,
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
