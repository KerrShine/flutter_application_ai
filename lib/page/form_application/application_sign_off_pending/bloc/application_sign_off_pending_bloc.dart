import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/enum/sign_off_pending_sort_order.dart';
import 'package:flutter_application_ai/model/sign_off_instance.dart';
import 'package:flutter_application_ai/service/form_application_service.dart';

part 'application_sign_off_pending_event.dart';
part 'application_sign_off_pending_state.dart';

class ApplicationSignOffPendingBloc extends Bloc<ApplicationSignOffPendingEvent,
    ApplicationSignOffPendingState> {
  final FormApplicationService _service;

  ApplicationSignOffPendingBloc(this._service)
      : super(const ApplicationSignOffPendingState()) {
    on<InitEvent>(_onInitEvent);
    on<RefreshEvent>(_onRefreshEvent);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQueryEvent);
    on<UpdateSortOrderEvent>(_onUpdateSortOrderEvent);
    on<UpdateFormNameFilterEvent>(_onUpdateFormNameFilterEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<ApplicationSignOffPendingState> emit,
  ) async {
    emit(state.copyWith(
      status: SignOffPendingStatus.loading,
      employeeId: event.employeeId,
      searchQuery: '',
      formNameFilter: '',
      sortOrder: SignOffPendingSortOrder.submittedAtDesc,
    ));
    await _load(event.employeeId, emit);
  }

  Future<void> _onRefreshEvent(
    RefreshEvent event,
    Emitter<ApplicationSignOffPendingState> emit,
  ) async {
    if (state.employeeId.isEmpty) return;
    await _load(state.employeeId, emit);
  }

  void _onUpdateSearchQueryEvent(
    UpdateSearchQueryEvent event,
    Emitter<ApplicationSignOffPendingState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onUpdateSortOrderEvent(
    UpdateSortOrderEvent event,
    Emitter<ApplicationSignOffPendingState> emit,
  ) {
    emit(state.copyWith(sortOrder: event.sortOrder));
  }

  void _onUpdateFormNameFilterEvent(
    UpdateFormNameFilterEvent event,
    Emitter<ApplicationSignOffPendingState> emit,
  ) {
    emit(state.copyWith(formNameFilter: event.formName));
  }

  Future<void> _load(
    String employeeId,
    Emitter<ApplicationSignOffPendingState> emit,
  ) async {
    final result = await _service.loadPendingForApprover(employeeId);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: SignOffPendingStatus.success,
        pendingItems: result.data ?? const [],
      ));
      return;
    }
    emit(state.copyWith(
      status: SignOffPendingStatus.failure,
      message: result.error ?? '待我簽核讀取失敗',
    ));
  }
}
