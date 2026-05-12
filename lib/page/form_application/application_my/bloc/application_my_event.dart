part of 'application_my_bloc.dart';

class ApplicationMyEvent extends Equatable {
  const ApplicationMyEvent();

  @override
  List<Object> get props => [];
}

class CompleteStatusEvent extends ApplicationMyEvent {
  const CompleteStatusEvent();
}

class InitEvent extends ApplicationMyEvent {
  final String employeeId;

  const InitEvent({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

class RefreshEvent extends ApplicationMyEvent {
  const RefreshEvent();
}

class RequestExportJsonEvent extends ApplicationMyEvent {
  const RequestExportJsonEvent();
}
