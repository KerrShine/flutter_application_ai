import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/page/form_design/form_run/bloc/form_run_bloc.dart';
import 'package:flutter_application_ai/route/route_catalog.dart';
import 'package:flutter_application_ai/service/form_run_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFormRunService extends Mock implements FormRunService {}

// ── 測試用綁定草稿 ──────────────────────────────────────────────

/// 按鈕觸發 navigate → 跳至表單管理頁
const _navigateDraft = FormDataBindingDraft(
  bindingId: 'binding-1',
  bindingName: '測試綁定',
  formId: 'form-1',
  formName: '測試表單',
  actions: [
    FormActionBindingDraft(
      actionId: 'submit-btn_buttonPressed_navigate',
      sourceItemId: 'submit-btn',
      sourceLabel: '送出',
      sourceType: 'button',
      triggerType: ActionTriggerType.buttonPressed,
      actionType: ActionType.navigate,
      navigateRoute: '/home/form-manage',
      description: '點擊後跳至表單管理',
      enabled: true,
    ),
  ],
);

/// 按鈕觸發 navigate → 留在本頁（__stay__）
const _stayDraft = FormDataBindingDraft(
  bindingId: 'binding-2',
  formId: 'form-1',
  actions: [
    FormActionBindingDraft(
      actionId: 'stay-btn_buttonPressed_navigate',
      sourceItemId: 'stay-btn',
      sourceLabel: '留在本頁',
      sourceType: 'button',
      triggerType: ActionTriggerType.buttonPressed,
      actionType: ActionType.navigate,
      navigateRoute: RouteCatalog.stayPath,
      enabled: true,
    ),
  ],
);

/// 按鈕觸發 navigate → 回到上一頁（__back__）
const _backDraft = FormDataBindingDraft(
  bindingId: 'binding-3',
  formId: 'form-1',
  actions: [
    FormActionBindingDraft(
      actionId: 'back-btn_buttonPressed_navigate',
      sourceItemId: 'back-btn',
      sourceLabel: '返回',
      sourceType: 'button',
      triggerType: ActionTriggerType.buttonPressed,
      actionType: ActionType.navigate,
      navigateRoute: RouteCatalog.backPath,
      enabled: true,
    ),
  ],
);

/// 按鈕觸發 saveDraft
const _saveDraftDraft = FormDataBindingDraft(
  bindingId: 'binding-4',
  formId: 'form-1',
  actions: [
    FormActionBindingDraft(
      actionId: 'save-btn_buttonPressed_saveDraft',
      sourceItemId: 'save-btn',
      sourceLabel: '暫存',
      sourceType: 'button',
      triggerType: ActionTriggerType.buttonPressed,
      actionType: ActionType.saveDraft,
      enabled: true,
    ),
  ],
);

void main() {
  late MockFormRunService service;

  setUp(() {
    service = MockFormRunService();
  });

  // ────────────────────────────────────────────────────────────
  // navigate action
  // ────────────────────────────────────────────────────────────
  group('FormRunButtonPressedEvent – navigate', () {
    blocTest<FormRunBloc, FormRunState>(
      '導頁至指定路由：emit executingAction → navigating with route',
      build: () => FormRunBloc(service),
      seed: () => const FormRunState(
        status: FormRunStatus.ready,
        formId: 'form-1',
        bindingId: 'binding-1',
        formName: '測試表單',
        draft: _navigateDraft,
      ),
      act: (bloc) => bloc.add(const FormRunButtonPressedEvent('submit-btn')),
      expect: () => [
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.executingAction),
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.navigating)
            .having(
              (s) => s.pendingNavigateRoute,
              'pendingNavigateRoute',
              '/home/form-manage',
            ),
      ],
    );

    blocTest<FormRunBloc, FormRunState>(
      '留在本頁（__stay__）：emit navigating with stayPath',
      build: () => FormRunBloc(service),
      seed: () => const FormRunState(
        status: FormRunStatus.ready,
        draft: _stayDraft,
      ),
      act: (bloc) => bloc.add(const FormRunButtonPressedEvent('stay-btn')),
      expect: () => [
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.executingAction),
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.navigating)
            .having(
              (s) => s.pendingNavigateRoute,
              'pendingNavigateRoute',
              RouteCatalog.stayPath,
            ),
      ],
    );

    blocTest<FormRunBloc, FormRunState>(
      '回到上一頁（__back__）：emit navigating with backPath',
      build: () => FormRunBloc(service),
      seed: () => const FormRunState(
        status: FormRunStatus.ready,
        draft: _backDraft,
      ),
      act: (bloc) => bloc.add(const FormRunButtonPressedEvent('back-btn')),
      expect: () => [
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.executingAction),
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.navigating)
            .having(
              (s) => s.pendingNavigateRoute,
              'pendingNavigateRoute',
              RouteCatalog.backPath,
            ),
      ],
    );

    blocTest<FormRunBloc, FormRunState>(
      '無綁定動作的按鈕：不 emit 任何狀態',
      build: () => FormRunBloc(service),
      seed: () => const FormRunState(
        status: FormRunStatus.ready,
        draft: _navigateDraft,
      ),
      act: (bloc) => bloc.add(const FormRunButtonPressedEvent('unknown-btn')),
      expect: () => [],
    );
  });

  // ────────────────────────────────────────────────────────────
  // saveDraft action
  // ────────────────────────────────────────────────────────────
  group('FormRunButtonPressedEvent – saveDraft', () {
    blocTest<FormRunBloc, FormRunState>(
      '儲存成功：emit executingAction → actionSuccess',
      build: () {
        when(() => service.executeSaveDraft(any(), any(), any()))
            .thenAnswer((_) async => Result.success(true));
        return FormRunBloc(service);
      },
      seed: () => const FormRunState(
        status: FormRunStatus.ready,
        formId: 'form-1',
        bindingId: 'binding-4',
        draft: _saveDraftDraft,
      ),
      act: (bloc) => bloc.add(const FormRunButtonPressedEvent('save-btn')),
      expect: () => [
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.executingAction),
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.actionSuccess)
            .having((s) => s.message, 'message', '草稿已儲存'),
      ],
    );

    blocTest<FormRunBloc, FormRunState>(
      '儲存失敗：emit executingAction → actionFailure',
      build: () {
        when(() => service.executeSaveDraft(any(), any(), any()))
            .thenAnswer((_) async => Result.failure('儲存失敗'));
        return FormRunBloc(service);
      },
      seed: () => const FormRunState(
        status: FormRunStatus.ready,
        draft: _saveDraftDraft,
      ),
      act: (bloc) => bloc.add(const FormRunButtonPressedEvent('save-btn')),
      expect: () => [
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.executingAction),
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.actionFailure)
            .having((s) => s.message, 'message', '儲存失敗'),
      ],
    );
  });

  // ────────────────────────────────────────────────────────────
  // FormRunDismissResultEvent
  // ────────────────────────────────────────────────────────────
  group('FormRunDismissResultEvent', () {
    blocTest<FormRunBloc, FormRunState>(
      '清除 navigating 狀態後回到 ready',
      build: () => FormRunBloc(service),
      seed: () => const FormRunState(
        status: FormRunStatus.navigating,
        pendingNavigateRoute: RouteCatalog.stayPath,
      ),
      act: (bloc) => bloc.add(const FormRunDismissResultEvent()),
      expect: () => [
        isA<FormRunState>()
            .having((s) => s.status, 'status', FormRunStatus.ready)
            .having((s) => s.pendingNavigateRoute, 'pendingNavigateRoute', null)
            .having((s) => s.message, 'message', ''),
      ],
    );
  });
}
