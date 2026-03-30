part of 'emp_role_bloc.dart';

enum EmpRoleDialogMode {
  none,
  create,
  edit,
}

enum EmpRoleStatus {
  init,
  loading,
  success,
  failure,
}

class EmpRoleState extends Equatable {
  final EmpRoleStatus status;
  final String message;
  final int messageRequestId;
  final String infoMessage;
  final int infoDialogRequestId;
  final String navigateRoute;
  final List<EmpRoleModel> roles;
  final String exportJson;
  final int exportDialogRequestId;
  final EmpRoleDialogMode roleDialogMode;
  final EmpRoleModel dialogRole;
  final int roleDialogRequestId;

  const EmpRoleState({
    this.status = EmpRoleStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.infoMessage = '',
    this.infoDialogRequestId = 0,
    this.navigateRoute = '',
    this.roles = const [],
    this.exportJson = '',
    this.exportDialogRequestId = 0,
    this.roleDialogMode = EmpRoleDialogMode.none,
    this.dialogRole = const EmpRoleModel(),
    this.roleDialogRequestId = 0,
  });

  bool get isEditDialog => roleDialogMode == EmpRoleDialogMode.edit;

  EmpRoleState copyWith({
    EmpRoleStatus? status,
    String? message,
    int? messageRequestId,
    String? infoMessage,
    int? infoDialogRequestId,
    String? navigateRoute,
    List<EmpRoleModel>? roles,
    String? exportJson,
    int? exportDialogRequestId,
    EmpRoleDialogMode? roleDialogMode,
    EmpRoleModel? dialogRole,
    int? roleDialogRequestId,
  }) {
    return EmpRoleState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      infoMessage: infoMessage ?? this.infoMessage,
      infoDialogRequestId: infoDialogRequestId ?? this.infoDialogRequestId,
      navigateRoute: navigateRoute ?? this.navigateRoute,
      roles: roles ?? this.roles,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
      roleDialogMode: roleDialogMode ?? this.roleDialogMode,
      dialogRole: dialogRole ?? this.dialogRole,
      roleDialogRequestId: roleDialogRequestId ?? this.roleDialogRequestId,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        messageRequestId,
        infoMessage,
        infoDialogRequestId,
        navigateRoute,
        roles,
        exportJson,
        exportDialogRequestId,
        roleDialogMode,
        dialogRole,
        roleDialogRequestId,
      ];
}
