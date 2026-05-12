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
  final String signOffId;
  final LeaveSignOffModel? signOff;
  final List<SectionModel> sections;
  final List<ResolvedApprover> resolvedChain;
  final String exportJson;
  final int exportDialogRequestId;

  const ApplicationSubmissionViewState({
    this.status = ApplicationSubmissionViewStatus.init,
    this.message = '',
    this.signOffId = '',
    this.signOff,
    this.sections = const [],
    this.resolvedChain = const [],
    this.exportJson = '',
    this.exportDialogRequestId = 0,
  });

  ApplicationSubmissionViewState copyWith({
    ApplicationSubmissionViewStatus? status,
    String? message,
    String? signOffId,
    LeaveSignOffModel? signOff,
    List<SectionModel>? sections,
    List<ResolvedApprover>? resolvedChain,
    String? exportJson,
    int? exportDialogRequestId,
  }) {
    return ApplicationSubmissionViewState(
      status: status ?? this.status,
      message: message ?? this.message,
      signOffId: signOffId ?? this.signOffId,
      signOff: signOff ?? this.signOff,
      sections: sections ?? this.sections,
      resolvedChain: resolvedChain ?? this.resolvedChain,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        signOffId,
        signOff,
        sections,
        resolvedChain,
        exportJson,
        exportDialogRequestId,
      ];
}
