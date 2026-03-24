import 'package:equatable/equatable.dart';

class OrgDepartmentNode extends Equatable {
  final String departmentId;
  final String departmentCode;
  final String name;
  final String parentDepartmentId;
  final String departmentHeadUserId;
  final int depthLevel;
  final int status;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  const OrgDepartmentNode({
    required this.departmentId,
    this.departmentCode = '',
    required this.name,
    this.parentDepartmentId = '',
    this.departmentHeadUserId = '',
    this.depthLevel = 0,
    this.status = 1,
    this.sortOrder = 0,
    this.createdAt = '',
    this.updatedAt = '',
  });

  bool get isActive => status == 1;

  OrgDepartmentNode copyWith({
    String? departmentId,
    String? departmentCode,
    String? name,
    String? parentDepartmentId,
    String? departmentHeadUserId,
    int? depthLevel,
    int? status,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
  }) {
    return OrgDepartmentNode(
      departmentId: departmentId ?? this.departmentId,
      departmentCode: departmentCode ?? this.departmentCode,
      name: name ?? this.name,
      parentDepartmentId: parentDepartmentId ?? this.parentDepartmentId,
      departmentHeadUserId: departmentHeadUserId ?? this.departmentHeadUserId,
      depthLevel: depthLevel ?? this.depthLevel,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'department_id': departmentId,
      'department_code': departmentCode,
      'name': name,
      'parent_department_id': parentDepartmentId,
      'department_head_user_id': departmentHeadUserId,
      'depth_level': depthLevel,
      'status': status,
      'sort_order': sortOrder,
      'created_at': createdAt,
      'updatedAt': updatedAt,
      'updated_at': updatedAt,
    };
  }

  factory OrgDepartmentNode.fromMap(Map<String, dynamic> map) {
    return OrgDepartmentNode(
      departmentId:
          map['department_id']?.toString() ?? map['id']?.toString() ?? '',
      departmentCode:
          map['department_code']?.toString() ?? map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      parentDepartmentId: map['parent_department_id']?.toString() ??
          map['parentId']?.toString() ??
          '',
      departmentHeadUserId: map['department_head_user_id']?.toString() ?? '',
      depthLevel: (map['depth_level'] as num?)?.toInt() ??
          (map['level'] as num?)?.toInt() ??
          0,
      status: (map['status'] as num?)?.toInt() ??
          ((map['isActive'] as bool?) == false ? 0 : 1),
      sortOrder: (map['sort_order'] as num?)?.toInt() ??
          (map['sortOrder'] as num?)?.toInt() ??
          0,
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt:
          map['updated_at']?.toString() ?? map['updatedAt']?.toString() ?? '',
    );
  }

  @override
  List<Object> get props => [
        departmentId,
        departmentCode,
        name,
        parentDepartmentId,
        departmentHeadUserId,
        depthLevel,
        status,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
