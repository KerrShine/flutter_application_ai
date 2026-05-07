part of 'form_launch_permission_bloc.dart';

enum FormLaunchPermissionStatus {
  init,
  loading,
  success,
  failure,
}

enum PermissionEditorMode {
  none,
  create,
  edit,
}

class FormLaunchPermissionState extends Equatable {
  final FormLaunchPermissionStatus status;
  final String message;
  final int messageRequestId;

  // data
  final List<FormModel> forms;
  final List<FormLaunchPermissionModel> permissions;
  final List<EmpRoleModel> roles;
  final List<OrgDepartmentNode> departments;

  // editor
  final PermissionEditorMode editorMode;
  final int editorRequestId;
  final String editorPermissionId;
  final String editorSelectedFormId;
  final String editorSelectedFormName;
  final List<String> editorAllowedRoleIds;
  final List<String> editorAllowedDepartmentIds;
  final bool editorRequireActiveStatus;
  final bool editorRequireManagerRole;
  final int editorIsEnabled;

  // preview
  final List<EligibleEmployeeInfo> eligibleEmployees;
  final int eligiblePreviewRequestId;

  // export
  final String exportJson;
  final int exportDialogRequestId;

  const FormLaunchPermissionState({
    this.status = FormLaunchPermissionStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.forms = const [],
    this.permissions = const [],
    this.roles = const [],
    this.departments = const [],
    this.editorMode = PermissionEditorMode.none,
    this.editorRequestId = 0,
    this.editorPermissionId = '',
    this.editorSelectedFormId = '',
    this.editorSelectedFormName = '',
    this.editorAllowedRoleIds = const [],
    this.editorAllowedDepartmentIds = const [],
    this.editorRequireActiveStatus = true,
    this.editorRequireManagerRole = false,
    this.editorIsEnabled = 1,
    this.eligibleEmployees = const [],
    this.eligiblePreviewRequestId = 0,
    this.exportJson = '',
    this.exportDialogRequestId = 0,
  });

  bool get isEditing => editorMode != PermissionEditorMode.none;

  FormLaunchPermissionState copyWith({
    FormLaunchPermissionStatus? status,
    String? message,
    int? messageRequestId,
    List<FormModel>? forms,
    List<FormLaunchPermissionModel>? permissions,
    List<EmpRoleModel>? roles,
    List<OrgDepartmentNode>? departments,
    PermissionEditorMode? editorMode,
    int? editorRequestId,
    String? editorPermissionId,
    String? editorSelectedFormId,
    String? editorSelectedFormName,
    List<String>? editorAllowedRoleIds,
    List<String>? editorAllowedDepartmentIds,
    bool? editorRequireActiveStatus,
    bool? editorRequireManagerRole,
    int? editorIsEnabled,
    List<EligibleEmployeeInfo>? eligibleEmployees,
    int? eligiblePreviewRequestId,
    String? exportJson,
    int? exportDialogRequestId,
  }) {
    return FormLaunchPermissionState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      forms: forms ?? this.forms,
      permissions: permissions ?? this.permissions,
      roles: roles ?? this.roles,
      departments: departments ?? this.departments,
      editorMode: editorMode ?? this.editorMode,
      editorRequestId: editorRequestId ?? this.editorRequestId,
      editorPermissionId: editorPermissionId ?? this.editorPermissionId,
      editorSelectedFormId: editorSelectedFormId ?? this.editorSelectedFormId,
      editorSelectedFormName:
          editorSelectedFormName ?? this.editorSelectedFormName,
      editorAllowedRoleIds: editorAllowedRoleIds ?? this.editorAllowedRoleIds,
      editorAllowedDepartmentIds:
          editorAllowedDepartmentIds ?? this.editorAllowedDepartmentIds,
      editorRequireActiveStatus:
          editorRequireActiveStatus ?? this.editorRequireActiveStatus,
      editorRequireManagerRole:
          editorRequireManagerRole ?? this.editorRequireManagerRole,
      editorIsEnabled: editorIsEnabled ?? this.editorIsEnabled,
      eligibleEmployees: eligibleEmployees ?? this.eligibleEmployees,
      eligiblePreviewRequestId:
          eligiblePreviewRequestId ?? this.eligiblePreviewRequestId,
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
        forms,
        permissions,
        roles,
        departments,
        editorMode,
        editorRequestId,
        editorPermissionId,
        editorSelectedFormId,
        editorSelectedFormName,
        editorAllowedRoleIds,
        editorAllowedDepartmentIds,
        editorRequireActiveStatus,
        editorRequireManagerRole,
        editorIsEnabled,
        eligibleEmployees,
        eligiblePreviewRequestId,
        exportJson,
        exportDialogRequestId,
      ];
}
