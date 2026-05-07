part of 'sign_off_manager_bloc.dart';

abstract class SignOffManagerEvent extends Equatable {
  const SignOffManagerEvent();

  @override
  List<Object?> get props => [];
}

class InitSignOffManagerEvent extends SignOffManagerEvent {
  const InitSignOffManagerEvent();
}

class DeleteSignOffTemplateEvent extends SignOffManagerEvent {
  final String templateId;

  const DeleteSignOffTemplateEvent(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

class RequestSignOffExportJsonEvent extends SignOffManagerEvent {
  const RequestSignOffExportJsonEvent();
}

class DismissSignOffMessageEvent extends SignOffManagerEvent {
  const DismissSignOffMessageEvent();
}
