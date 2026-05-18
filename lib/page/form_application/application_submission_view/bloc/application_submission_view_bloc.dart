import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/enum/submission_view_mode.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/sign_off_instance.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/service/form_application_service.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';

part 'application_submission_view_event.dart';
part 'application_submission_view_state.dart';

class ApplicationSubmissionViewBloc extends Bloc<
    ApplicationSubmissionViewEvent, ApplicationSubmissionViewState> {
  final FormApplicationService _service;

  ApplicationSubmissionViewBloc(this._service)
      : super(const ApplicationSubmissionViewState()) {
    on<InitEvent>(_onInitEvent);
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
    on<RefreshEvent>(_onRefreshEvent);
    on<RequestExportJsonEvent>(_onRequestExportJsonEvent);
    on<ApproveActionEvent>(_onApproveActionEvent);
    on<RejectActionEvent>(_onRejectActionEvent);
    on<ReturnBackActionEvent>(_onReturnBackActionEvent);
    on<RequestSupplementActionEvent>(_onRequestSupplementActionEvent);
    on<TransferActionEvent>(_onTransferActionEvent);
    on<AddApproverActionEvent>(_onAddApproverActionEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    emit(state.copyWith(
      status: ApplicationSubmissionViewStatus.loading,
      signOffId: event.signOffId,
      mode: event.mode,
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
    // 載入全部 active 員工 — 給轉派 / 加簽 dialog 員工選擇用
    final empResult = await _service.loadActiveEmployees();
    final employees = empResult.isSuccess
        ? (empResult.data ?? const <EmployeeModel>[])
        : const <EmployeeModel>[];
    emit(state.copyWith(
      status: ApplicationSubmissionViewStatus.success,
      signOff: model,
      sections: sections,
      resolvedChain: resolvedChain,
      employees: employees,
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

  Future<void> _onApproveActionEvent(
    ApproveActionEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    final result = await _service.approveSignOff(
      signOffId: state.signOffId,
      approverId: event.approverId,
      approverName: event.approverName,
      comment: event.comment,
    );
    await _afterAction(result, '已同意', emit);
  }

  Future<void> _onRejectActionEvent(
    RejectActionEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    final result = await _service.rejectSignOff(
      signOffId: state.signOffId,
      approverId: event.approverId,
      approverName: event.approverName,
      comment: event.comment,
    );
    await _afterAction(result, '已拒絕', emit);
  }

  Future<void> _onReturnBackActionEvent(
    ReturnBackActionEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    final result = await _service.returnBackSignOff(
      signOffId: state.signOffId,
      approverId: event.approverId,
      approverName: event.approverName,
      comment: event.comment,
    );
    await _afterAction(result, '已退回', emit);
  }

  Future<void> _onRequestSupplementActionEvent(
    RequestSupplementActionEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    final result = await _service.requestSupplementSignOff(
      signOffId: state.signOffId,
      approverId: event.approverId,
      approverName: event.approverName,
      comment: event.comment,
    );
    await _afterAction(result, '已要求補件', emit);
  }

  Future<void> _onTransferActionEvent(
    TransferActionEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    final result = await _service.transferSignOff(
      signOffId: state.signOffId,
      approverId: event.approverId,
      approverName: event.approverName,
      targetEmployeeId: event.targetEmployeeId,
      comment: event.comment,
    );
    await _afterAction(result, '已轉派', emit);
  }

  Future<void> _onAddApproverActionEvent(
    AddApproverActionEvent event,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    final result = await _service.addApproverSignOff(
      signOffId: state.signOffId,
      approverId: event.approverId,
      approverName: event.approverName,
      addedEmployeeId: event.addedEmployeeId,
      comment: event.comment,
    );
    await _afterAction(result, '已加簽', emit);
  }

  Future<void> _afterAction(
    dynamic result,
    String successMessage,
    Emitter<ApplicationSubmissionViewState> emit,
  ) async {
    if (!result.isSuccess) {
      emit(state.copyWith(
        message: result.error ?? '簽核動作失敗',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }
    // 重新載入 signOff + 鏈
    await _load(state.signOffId, emit);
    emit(state.copyWith(
      message: successMessage,
      messageRequestId: state.messageRequestId + 1,
      actionCompletedRequestId: state.actionCompletedRequestId + 1,
    ));
  }
}
