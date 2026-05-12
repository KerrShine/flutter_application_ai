part of 'application_submission_view_bloc.dart';

abstract class ApplicationSubmissionViewEvent extends Equatable {
  const ApplicationSubmissionViewEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends ApplicationSubmissionViewEvent {
  final String signOffId;

  const InitEvent({required this.signOffId});

  @override
  List<Object> get props => [signOffId];
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
