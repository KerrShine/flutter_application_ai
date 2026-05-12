import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_application_service.dart';

part 'application_create_event.dart';
part 'application_create_state.dart';

class ApplicationCreateBloc
    extends Bloc<ApplicationCreateEvent, ApplicationCreateState> {
  final FormApplicationService _service;

  ApplicationCreateBloc(this._service)
      : super(const ApplicationCreateState()) {
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
    on<InitEvent>(_onInitEvent);
    on<NavigationHandledEvent>(_onNavigationHandledEvent);
    on<RefreshEvent>(_onRefreshEvent);
    on<SelectFormToApplyEvent>(_onSelectFormToApplyEvent);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQueryEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<ApplicationCreateState> emit,
  ) async {
    emit(state.copyWith(
      status: ApplicationCreateStatus.loading,
      employeeId: event.employeeId,
    ));

    final result = await _service.loadAvailableForms(event.employeeId);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: ApplicationCreateStatus.success,
        availableForms: result.data ?? const [],
      ));
      return;
    }

    emit(state.copyWith(
      status: ApplicationCreateStatus.failure,
      message: result.error ?? '可申請表單載入失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onRefreshEvent(
    RefreshEvent event,
    Emitter<ApplicationCreateState> emit,
  ) async {
    if (state.employeeId.isEmpty) return;
    final result = await _service.loadAvailableForms(state.employeeId);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: ApplicationCreateStatus.success,
        availableForms: result.data ?? const [],
      ));
      return;
    }

    emit(state.copyWith(
      status: ApplicationCreateStatus.failure,
      message: result.error ?? '可申請表單重整失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onUpdateSearchQueryEvent(
    UpdateSearchQueryEvent event,
    Emitter<ApplicationCreateState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSelectFormToApplyEvent(
    SelectFormToApplyEvent event,
    Emitter<ApplicationCreateState> emit,
  ) {
    emit(state.copyWith(
      navigateRoute: RouteName.formRunPage,
      navigateExtra: {
        'formId': event.formId,
        'bindingId': event.bindingId,
      },
    ));
  }

  void _onNavigationHandledEvent(
    NavigationHandledEvent event,
    Emitter<ApplicationCreateState> emit,
  ) {
    emit(state.copyWith(
      navigateRoute: '',
      navigateExtra: const {},
    ));
  }

  void _onCompleteStatusEvent(
    CompleteStatusEvent event,
    Emitter<ApplicationCreateState> emit,
  ) {
    emit(state.copyWith(message: ''));
  }
}
