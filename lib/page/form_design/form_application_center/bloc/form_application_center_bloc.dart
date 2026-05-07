import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/form_submission_model.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_application_service.dart';

part 'form_application_center_event.dart';
part 'form_application_center_state.dart';

class FormApplicationCenterBloc
    extends Bloc<FormApplicationCenterEvent, FormApplicationCenterState> {
  final FormApplicationService _service;

  FormApplicationCenterBloc(this._service)
      : super(const FormApplicationCenterState()) {
    on<InitEvent>(_onInitEvent);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQueryEvent);
    on<SelectFormToApplyEvent>(_onSelectFormToApplyEvent);
    on<NavigationHandledEvent>(_onNavigationHandledEvent);
    on<RequestExportJsonEvent>(_onRequestExportJsonEvent);
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<FormApplicationCenterState> emit,
  ) async {
    emit(state.copyWith(
      status: FormApplicationCenterStatus.loading,
      employeeId: event.employeeId,
    ));

    final result = await _service.initialize(event.employeeId);

    if (result.isSuccess) {
      final data = result.data!;
      emit(state.copyWith(
        status: FormApplicationCenterStatus.success,
        availableForms: data.availableForms,
        mySubmissions: data.mySubmissions,
        currentEmployee: data.currentEmployee,
      ));
      return;
    }

    emit(state.copyWith(
      status: FormApplicationCenterStatus.failure,
      message: result.error ?? '初始化失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onUpdateSearchQueryEvent(
    UpdateSearchQueryEvent event,
    Emitter<FormApplicationCenterState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSelectFormToApplyEvent(
    SelectFormToApplyEvent event,
    Emitter<FormApplicationCenterState> emit,
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
    Emitter<FormApplicationCenterState> emit,
  ) {
    emit(state.copyWith(
      navigateRoute: '',
      navigateExtra: const {},
    ));
  }

  Future<void> _onRequestExportJsonEvent(
    RequestExportJsonEvent event,
    Emitter<FormApplicationCenterState> emit,
  ) async {
    final result = await _service.buildExportJson(state.employeeId);
    if (result.isSuccess) {
      emit(state.copyWith(
        exportJson: result.data ?? '',
        exportDialogRequestId: state.exportDialogRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      message: result.error ?? '匯出失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onCompleteStatusEvent(
    CompleteStatusEvent event,
    Emitter<FormApplicationCenterState> emit,
  ) {
    emit(state.copyWith(message: ''));
  }
}
