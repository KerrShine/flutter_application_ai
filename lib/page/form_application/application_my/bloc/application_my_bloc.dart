import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/sign_off_instance.dart';
import 'package:flutter_application_ai/service/form_application_service.dart';

part 'application_my_event.dart';
part 'application_my_state.dart';

class ApplicationMyBloc extends Bloc<ApplicationMyEvent, ApplicationMyState> {
  final FormApplicationService _service;

  ApplicationMyBloc(this._service) : super(const ApplicationMyState()) {
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
    on<InitEvent>(_onInitEvent);
    on<RefreshEvent>(_onRefreshEvent);
    on<RequestExportJsonEvent>(_onRequestExportJsonEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<ApplicationMyState> emit,
  ) async {
    emit(state.copyWith(
      status: ApplicationMyStatus.loading,
      employeeId: event.employeeId,
    ));

    final result = await _service.loadMySignOffs(event.employeeId);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: ApplicationMyStatus.success,
        mySignOffs: result.data ?? const [],
      ));
      return;
    }

    emit(state.copyWith(
      status: ApplicationMyStatus.failure,
      message: result.error ?? '我的申請載入失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onRefreshEvent(
    RefreshEvent event,
    Emitter<ApplicationMyState> emit,
  ) async {
    if (state.employeeId.isEmpty) return;
    final result = await _service.loadMySignOffs(state.employeeId);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: ApplicationMyStatus.success,
        mySignOffs: result.data ?? const [],
      ));
      return;
    }

    emit(state.copyWith(
      status: ApplicationMyStatus.failure,
      message: result.error ?? '我的申請重整失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onRequestExportJsonEvent(
    RequestExportJsonEvent event,
    Emitter<ApplicationMyState> emit,
  ) async {
    try {
      final payload = {
        'table': 'leave_sign_off',
        'applicant_id': state.employeeId,
        'total': state.mySignOffs.length,
        'items': state.mySignOffs.map((m) => m.toMap()).toList(),
      };
      final json = const JsonEncoder.withIndent('  ').convert(payload);
      emit(state.copyWith(
        exportJson: json,
        exportDialogRequestId: state.exportDialogRequestId + 1,
      ));
    } catch (ex) {
      emit(state.copyWith(
        message: '匯出失敗: ${ex.toString()}',
        messageRequestId: state.messageRequestId + 1,
      ));
    }
  }

  void _onCompleteStatusEvent(
    CompleteStatusEvent event,
    Emitter<ApplicationMyState> emit,
  ) {
    emit(state.copyWith(message: ''));
  }
}
