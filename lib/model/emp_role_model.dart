import 'package:equatable/equatable.dart';

class EmpRoleModel extends Equatable {
  final String roleId;
  final String roleCode;
  final String roleName;
  final int roleType;
  final int status;
  final String createdAt;
  final String updatedAt;

  const EmpRoleModel({
    this.roleId = '',
    this.roleCode = '',
    this.roleName = '',
    this.roleType = 0,
    this.status = 1,
    this.createdAt = '',
    this.updatedAt = '',
  });

  bool get isActive => status == 1;

  bool get isManagerLevel => roleType == 1;

  EmpRoleModel copyWith({
    String? roleId,
    String? roleCode,
    String? roleName,
    int? roleType,
    int? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return EmpRoleModel(
      roleId: roleId ?? this.roleId,
      roleCode: roleCode ?? this.roleCode,
      roleName: roleName ?? this.roleName,
      roleType: roleType ?? this.roleType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role_id': roleId,
      'role_code': roleCode,
      'role_name': roleName,
      'role_type': roleType,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory EmpRoleModel.fromMap(Map<String, dynamic> map) {
    return EmpRoleModel(
      roleId: map['role_id']?.toString() ?? map['roleId']?.toString() ?? '',
      roleCode:
          map['role_code']?.toString() ?? map['roleCode']?.toString() ?? '',
      roleName:
          map['role_name']?.toString() ?? map['roleName']?.toString() ?? '',
      roleType: (map['role_type'] as num?)?.toInt() ??
          (map['roleType'] as num?)?.toInt() ??
          ((map['isManagerLevel'] as bool?) == true ? 1 : 0),
      status: (map['status'] as num?)?.toInt() ??
          ((map['isActive'] as bool?) == false ? 0 : 1),
      createdAt:
          map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '',
      updatedAt:
          map['updated_at']?.toString() ?? map['updatedAt']?.toString() ?? '',
    );
  }

  @override
  List<Object> get props => [
        roleId,
        roleCode,
        roleName,
        roleType,
        status,
        createdAt,
        updatedAt,
      ];
}
