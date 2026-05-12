part of 'application_my_bloc.dart';

enum ApplicationMyStatus {
  init,
  loading,
  success,
  failure,
}

class ApplicationMyState extends Equatable {
  final ApplicationMyStatus status;
  final String message;
  final int messageRequestId;
  final String employeeId;
  final List<LeaveSignOffModel> mySignOffs;
  final String exportJson;
  final int exportDialogRequestId;

  const ApplicationMyState({
    this.status = ApplicationMyStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.employeeId = '',
    this.mySignOffs = const [],
    this.exportJson = '',
    this.exportDialogRequestId = 0,
  });

  ApplicationMyState copyWith({
    ApplicationMyStatus? status,
    String? message,
    int? messageRequestId,
    String? employeeId,
    List<LeaveSignOffModel>? mySignOffs,
    String? exportJson,
    int? exportDialogRequestId,
  }) {
    return ApplicationMyState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      employeeId: employeeId ?? this.employeeId,
      mySignOffs: mySignOffs ?? this.mySignOffs,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        messageRequestId,
        employeeId,
        mySignOffs,
        exportJson,
        exportDialogRequestId,
      ];
}
