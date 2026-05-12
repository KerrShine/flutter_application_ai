import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/leave_sign_off_model.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/service/form_application_service.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';

part 'application_submission_view_event.dart';
part 'application_submission_view_state.dart';

class ApplicationSubmissionViewBloc
    extends Bloc<ApplicationSubmissionViewEvent, ApplicationSubmissionViewState> {
  final FormApplicationService _service;

  ApplicationSubmissionViewBloc(this._service) : super(const ApplicationSubmissionViewState()) {
    on<InitEvent>(_onInitEvent);
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
    on<RefreshEvent>(_onRefreshEvent);
    on<RequestExportJsonEvent>(_onRequestExportJsonEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    emit(state.copyWith(
      status: ApplicationSubmissionViewStatus.loading,
      signOffId: event.signOffId,
    ));
    await _load(event.signOffId, emit);
  }

  Future<void> _onRefreshEvent(
    RefreshEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    if (state.signOffId.isEmpty) return;
    await _load(state.signOffId, emit);
  }

  Future<void> _load(
    String signOffId,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    final result = await _service.loadSignOffById(signOffId);
    if (!result.isSuccess || result.data == null) {
      emit(state.copyWith(
        status: ApplicationSubmissionViewStatus.failure,
        message: result.error ?? '讀取申請詳情失敗',
      ));
      return;
    }
    final model = result.data!;
    final sections = model.sectionsSnapshot
        .map((m) => SectionModel.fromMap(m))
        .toList();
    // 解析簽核鏈（含 templateId 時才會回非空 list；失敗或無模板回空）
    final chainResult = await _service.resolveSignOffChain(model);
    final List<ResolvedApprover> resolvedChain = chainResult.isSuccess
        ? (chainResult.data ?? const <ResolvedApprover>[])
        : const <ResolvedApprover>[];
    emit(state.copyWith(
      status: ApplicationSubmissionViewStatus.success,
      signOff: model,
      sections: sections,
      resolvedChain: resolvedChain,
    ));
  }

  void _onCompleteStatusEvent(
    CompleteStatusEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) {
    emit(state.copyWith(message: ''));
  }

  void _onRequestExportJsonEvent(
    RequestExportJsonEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) {
    final signOff = state.signOff;
    if (signOff == null) {
      emit(state.copyWith(message: '尚無資料可匯出'));
      return;
    }
    try {
      final json = const JsonEncoder.withIndent('  ').convert(signOff.toMap());
      emit(state.copyWith(
        exportJson: json,
        exportDialogRequestId: state.exportDialogRequestId + 1,
      ));
    } catch (ex) {
      emit(state.copyWith(message: '匯出失敗: ${ex.toString()}'));
    }
  }
}
