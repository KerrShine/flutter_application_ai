part of 'sign_off_manager_bloc.dart';

enum SignOffManagerStatus { init, loading, success, failure }

class SignOffManagerState extends Equatable {
  final SignOffManagerStatus status;
  final List<FormModel> forms;
  final List<SignOffTemplateModel> templates;
  final List<FormLaunchPermissionModel> permissions;
  final List<EmpRoleModel> roles;
  final List<OrgDepartmentNode> departments;
  final List<EmployeeModel> employees;
  final String message;
  final int messageRequestId;
  final String exportJson;
  final int exportDialogRequestId;

  const SignOffManagerState({
    this.status = SignOffManagerStatus.init,
    this.forms = const [],
    this.templates = const [],
    this.permissions = const [],
    this.roles = const [],
    this.departments = const [],
    this.employees = const [],
    this.message = '',
    this.messageRequestId = 0,
    this.exportJson = '',
    this.exportDialogRequestId = 0,
  });

  SignOffManagerState copyWith({
    SignOffManagerStatus? status,
    List<FormModel>? forms,
    List<SignOffTemplateModel>? templates,
    List<FormLaunchPermissionModel>? permissions,
    List<EmpRoleModel>? roles,
    List<OrgDepartmentNode>? departments,
    List<EmployeeModel>? employees,
    String? message,
    int? messageRequestId,
    String? exportJson,
    int? exportDialogRequestId,
  }) {
    return SignOffManagerState(
      status: status ?? this.status,
      forms: forms ?? this.forms,
      templates: templates ?? this.templates,
      permissions: permissions ?? this.permissions,
      roles: roles ?? this.roles,
      departments: departments ?? this.departments,
      employees: employees ?? this.employees,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        forms,
        templates,
        permissions,
        roles,
        departments,
        employees,
        message,
        messageRequestId,
        exportJson,
        exportDialogRequestId,
      ];
}
