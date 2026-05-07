part of 'form_launch_permission_editor_bloc.dart';

enum PermissionEditorPageStatus {
  init,
  ready,
  saving,
  saved,
  failure,
}

class FormLaunchPermissionEditorState extends Equatable {
  final PermissionEditorPageStatus status;
  final String message;
  final int messageRequestId;
  final bool isEditMode;

  // data
  final List<FormModel> forms;
  final List<EmpRoleModel> roles;
  final List<OrgDepartmentNode> departments;

  // editor fields
  final String permissionId;
  final String selectedFormId;
  final String selectedFormName;
  final List<String> allowedRoleIds;
  final List<String> allowedDepartmentIds;
  final bool requireActiveStatus;
  final bool requireManagerRole;
  final int isEnabled;

  // search
  final String departmentSearchQuery;

  // preview
  final List<EligibleEmployeeInfo> eligibleEmployees;
  final int eligiblePreviewRequestId;

  const FormLaunchPermissionEditorState({
    this.status = PermissionEditorPageStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.isEditMode = false,
    this.forms = const [],
    this.roles = const [],
    this.departments = const [],
    this.permissionId = '',
    this.selectedFormId = '',
    this.selectedFormName = '',
    this.allowedRoleIds = const [],
    this.allowedDepartmentIds = const [],
    this.requireActiveStatus = true,
    this.requireManagerRole = false,
    this.isEnabled = 1,
    this.departmentSearchQuery = '',
    this.eligibleEmployees = const [],
    this.eligiblePreviewRequestId = 0,
  });

  FormLaunchPermissionEditorState copyWith({
    PermissionEditorPageStatus? status,
    String? message,
    int? messageRequestId,
    bool? isEditMode,
    List<FormModel>? forms,
    List<EmpRoleModel>? roles,
    List<OrgDepartmentNode>? departments,
    String? permissionId,
    String? selectedFormId,
    String? selectedFormName,
    List<String>? allowedRoleIds,
    List<String>? allowedDepartmentIds,
    bool? requireActiveStatus,
    bool? requireManagerRole,
    int? isEnabled,
    String? departmentSearchQuery,
    List<EligibleEmployeeInfo>? eligibleEmployees,
    int? eligiblePreviewRequestId,
  }) {
    return FormLaunchPermissionEditorState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      isEditMode: isEditMode ?? this.isEditMode,
      forms: forms ?? this.forms,
      roles: roles ?? this.roles,
      departments: departments ?? this.departments,
      permissionId: permissionId ?? this.permissionId,
      selectedFormId: selectedFormId ?? this.selectedFormId,
      selectedFormName: selectedFormName ?? this.selectedFormName,
      allowedRoleIds: allowedRoleIds ?? this.allowedRoleIds,
      allowedDepartmentIds: allowedDepartmentIds ?? this.allowedDepartmentIds,
      requireActiveStatus: requireActiveStatus ?? this.requireActiveStatus,
      requireManagerRole: requireManagerRole ?? this.requireManagerRole,
      isEnabled: isEnabled ?? this.isEnabled,
      departmentSearchQuery:
          departmentSearchQuery ?? this.departmentSearchQuery,
      eligibleEmployees: eligibleEmployees ?? this.eligibleEmployees,
      eligiblePreviewRequestId:
          eligiblePreviewRequestId ?? this.eligiblePreviewRequestId,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        messageRequestId,
        isEditMode,
        forms,
        roles,
        departments,
        permissionId,
        selectedFormId,
        selectedFormName,
        allowedRoleIds,
        allowedDepartmentIds,
        requireActiveStatus,
        requireManagerRole,
        isEnabled,
        departmentSearchQuery,
        eligibleEmployees,
        eligiblePreviewRequestId,
      ];
}
