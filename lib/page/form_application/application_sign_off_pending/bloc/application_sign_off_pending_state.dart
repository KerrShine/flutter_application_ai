part of 'application_sign_off_pending_bloc.dart';

enum SignOffPendingStatus {
  init,
  loading,
  success,
  failure,
}

class ApplicationSignOffPendingState extends Equatable {
  final SignOffPendingStatus status;
  final String message;
  final String employeeId;
  final List<dynamic> pendingItems;

  const ApplicationSignOffPendingState({
    this.status = SignOffPendingStatus.init,
    this.message = '',
    this.employeeId = '',
    this.pendingItems = const [],
  });

  ApplicationSignOffPendingState copyWith({
    SignOffPendingStatus? status,
    String? message,
    String? employeeId,
    List<dynamic>? pendingItems,
  }) {
    return ApplicationSignOffPendingState(
      status: status ?? this.status,
      message: message ?? this.message,
      employeeId: employeeId ?? this.employeeId,
      pendingItems: pendingItems ?? this.pendingItems,
    );
  }

  @override
  List<Object> get props => [status, message, employeeId, pendingItems];
}
