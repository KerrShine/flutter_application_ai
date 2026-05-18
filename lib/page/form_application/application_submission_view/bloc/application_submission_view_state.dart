part of 'application_submission_view_bloc.dart';

enum ApplicationSubmissionViewStatus {
  init,
  loading,
  success,
  failure,
}

class ApplicationSubmissionViewState extends Equatable {
  final ApplicationSubmissionViewStatus status;
  final String message;
  final int messageRequestId;
  final String signOffId;
  final SubmissionViewMode mode;
  final SignOffInstance? signOff;
  final List<SectionModel> sections;
  final List<ResolvedApprover> resolvedChain;

  /// 全部 active 員工 — 給 panel 的「轉派 / 加簽」員工選擇 dialog 用。
  final List<EmployeeModel> employees;

  final String exportJson;
  final int exportDialogRequestId;

  /// 動作完成後 +1 — page 用 listenWhen 偵測自動 pop 回上一頁。
  final int actionCompletedRequestId;

  const ApplicationSubmissionViewState({
    this.status = ApplicationSubmissionViewStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.signOffId = '',
    this.mode = SubmissionViewMode.viewer,
    this.signOff,
    this.sections = const [],
    this.resolvedChain = const [],
    this.employees = const [],
    this.exportJson = '',
    this.exportDialogRequestId = 0,
    this.actionCompletedRequestId = 0,
  });

  ApplicationSubmissionViewState copyWith({
    ApplicationSubmissionViewStatus? status,
    String? message,
    int? messageRequestId,
    String? signOffId,
    SubmissionViewMode? mode,
    SignOffInstance? signOff,
    List<SectionModel>? sections,
    List<ResolvedApprover>? resolvedChain,
    List<EmployeeModel>? employees,
    String? exportJson,
    int? exportDialogRequestId,
    int? actionCompletedRequestId,
  }) {
    return ApplicationSubmissionViewState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      signOffId: signOffId ?? this.signOffId,
      mode: mode ?? this.mode,
      signOff: signOff ?? this.signOff,
      sections: sections ?? this.sections,
      resolvedChain: resolvedChain ?? this.resolvedChain,
      employees: employees ?? this.employees,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
      actionCompletedRequestId:
          actionCompletedRequestId ?? this.actionCompletedRequestId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        messageRequestId,
        signOffId,
        mode,
        signOff,
        sections,
        resolvedChain,
        employees,
        exportJson,
        exportDialogRequestId,
        actionCompletedRequestId,
      ];
}
