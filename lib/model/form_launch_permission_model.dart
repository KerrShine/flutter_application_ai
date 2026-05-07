import 'package:equatable/equatable.dart';

class FormLaunchPermissionModel extends Equatable {
  final String permissionId;
  final String formId;
  final String formName;
  final String bindingId;
  final List<String> allowedRoleIds;
  final List<String> allowedDepartmentIds;
  final bool requireActiveStatus;
  final bool requireManagerRole;
  final int isEnabled;
  final String createdAt;
  final String updatedAt;

  const FormLaunchPermissionModel({
    this.permissionId = '',
    this.formId = '',
    this.formName = '',
    this.bindingId = '',
    this.allowedRoleIds = const [],
    this.allowedDepartmentIds = const [],
    this.requireActiveStatus = true,
    this.requireManagerRole = false,
    this.isEnabled = 1,
    this.createdAt = '',
    this.updatedAt = '',
  });

  bool get isActive => isEnabled == 1;

  FormLaunchPermissionModel copyWith({
    String? permissionId,
    String? formId,
    String? formName,
    String? bindingId,
    List<String>? allowedRoleIds,
    List<String>? allowedDepartmentIds,
    bool? requireActiveStatus,
    bool? requireManagerRole,
    int? isEnabled,
    String? createdAt,
    String? updatedAt,
  }) {
    return FormLaunchPermissionModel(
      permissionId: permissionId ?? this.permissionId,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      bindingId: bindingId ?? this.bindingId,
      allowedRoleIds: allowedRoleIds ?? this.allowedRoleIds,
      allowedDepartmentIds: allowedDepartmentIds ?? this.allowedDepartmentIds,
      requireActiveStatus: requireActiveStatus ?? this.requireActiveStatus,
      requireManagerRole: requireManagerRole ?? this.requireManagerRole,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'permission_id': permissionId,
      'form_id': formId,
      'form_name': formName,
      'binding_id': bindingId,
      'allowed_role_ids': allowedRoleIds,
      'allowed_department_ids': allowedDepartmentIds,
      'require_active_status': requireActiveStatus,
      'require_manager_role': requireManagerRole,
      'is_enabled': isEnabled,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FormLaunchPermissionModel.fromMap(Map<String, dynamic> map) {
    return FormLaunchPermissionModel(
      permissionId: map['permission_id']?.toString() ??
          map['permissionId']?.toString() ??
          '',
      formId:
          map['form_id']?.toString() ?? map['formId']?.toString() ?? '',
      formName:
          map['form_name']?.toString() ?? map['formName']?.toString() ?? '',
      bindingId:
          map['binding_id']?.toString() ?? map['bindingId']?.toString() ?? '',
      allowedRoleIds: _parseStringList(
          map['allowed_role_ids'] ?? map['allowedRoleIds']),
      allowedDepartmentIds: _parseStringList(
          map['allowed_department_ids'] ?? map['allowedDepartmentIds']),
      requireActiveStatus:
          map['require_active_status'] ?? map['requireActiveStatus'] ?? true,
      requireManagerRole:
          map['require_manager_role'] ?? map['requireManagerRole'] ?? false,
      isEnabled: (map['is_enabled'] as num?)?.toInt() ??
          (map['isEnabled'] as num?)?.toInt() ??
          1,
      createdAt:
          map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '',
      updatedAt:
          map['updated_at']?.toString() ?? map['updatedAt']?.toString() ?? '',
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  @override
  List<Object> get props => [
        permissionId,
        formId,
        formName,
        bindingId,
        allowedRoleIds,
        allowedDepartmentIds,
        requireActiveStatus,
        requireManagerRole,
        isEnabled,
        createdAt,
        updatedAt,
      ];
}
