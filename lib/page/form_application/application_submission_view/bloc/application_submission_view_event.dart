part of 'application_submission_view_bloc.dart';

abstract class ApplicationSubmissionViewEvent extends Equatable {
  const ApplicationSubmissionViewEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends ApplicationSubmissionViewEvent {
  final String signOffId;
  final SubmissionViewMode mode;

  const InitEvent({
    required this.signOffId,
    this.mode = SubmissionViewMode.viewer,
  });

  @override
  List<Object> get props => [signOffId, mode];
}

class CompleteStatusEvent extends ApplicationSubmissionViewEvent {
  const CompleteStatusEvent();
}

class RefreshEvent extends ApplicationSubmissionViewEvent {
  const RefreshEvent();
}

class RequestExportJsonEvent extends ApplicationSubmissionViewEvent {
  const RequestExportJsonEvent();
}

class ApproveActionEvent extends ApplicationSubmissionViewEvent {
  final String approverId;
  final String approverName;
  final String comment;

  const ApproveActionEvent({
    required this.approverId,
    required this.approverName,
    this.comment = '',
  });

  @override
  List<Object> get props => [approverId, approverName, comment];
}

class RejectActionEvent extends ApplicationSubmissionViewEvent {
  final String approverId;
  final String approverName;
  final String comment;

  const RejectActionEvent({
    required this.approverId,
    required this.approverName,
    required this.comment,
  });

  @override
  List<Object> get props => [approverId, approverName, comment];
}

class ReturnBackActionEvent extends ApplicationSubmissionViewEvent {
  final String approverId;
  final String approverName;
  final String comment;

  const ReturnBackActionEvent({
    required this.approverId,
    required this.approverName,
    required this.comment,
  });

  @override
  List<Object> get props => [approverId, approverName, comment];
}

class RequestSupplementActionEvent extends ApplicationSubmissionViewEvent {
  final String approverId;
  final String approverName;
  final String comment;

  const RequestSupplementActionEvent({
    required this.approverId,
    required this.approverName,
    required this.comment,
  });

  @override
  List<Object> get props => [approverId, approverName, comment];
}

class TransferActionEvent extends ApplicationSubmissionViewEvent {
  final String approverId;
  final String approverName;
  final String targetEmployeeId;
  final String comment;

  const TransferActionEvent({
    required this.approverId,
    required this.approverName,
    required this.targetEmployeeId,
    this.comment = '',
  });

  @override
  List<Object> get props =>
      [approverId, approverName, targetEmployeeId, comment];
}

class AddApproverActionEvent extends ApplicationSubmissionViewEvent {
  final String approverId;
  final String approverName;
  final String addedEmployeeId;
  final String comment;

  const AddApproverActionEvent({
    required this.approverId,
    required this.approverName,
    required this.addedEmployeeId,
    this.comment = '',
  });

  @override
  List<Object> get props =>
      [approverId, approverName, addedEmployeeId, comment];
}
