import 'package:equatable/equatable.dart';

class EmpAgentAssignmentModel extends Equatable {
  final String assignmentId;
  final String principalDepartmentId;
  final String principalEmployeeId;
  final String agentDepartmentId;
  final String agentEmployeeId;
  final int status;
  final String createdDate;
  final String createdTime;
  final String createdBy;
  final String createdByName;
  final String updatedDate;
  final String updatedTime;
  final String updatedBy;
  final String updatedByName;

  const EmpAgentAssignmentModel({
    this.assignmentId = '',
    this.principalDepartmentId = '',
    this.principalEmployeeId = '',
    this.agentDepartmentId = '',
    this.agentEmployeeId = '',
    this.status = 1,
    this.createdDate = '',
    this.createdTime = '',
    this.createdBy = '',
    this.createdByName = '',
    this.updatedDate = '',
    this.updatedTime = '',
    this.updatedBy = '',
    this.updatedByName = '',
  });

  bool get isActive => status == 1;

  EmpAgentAssignmentModel copyWith({
    String? assignmentId,
    String? principalDepartmentId,
    String? principalEmployeeId,
    String? agentDepartmentId,
    String? agentEmployeeId,
    int? status,
    String? createdDate,
    String? createdTime,
    String? createdBy,
    String? createdByName,
    String? updatedDate,
    String? updatedTime,
    String? updatedBy,
    String? updatedByName,
  }) {
    return EmpAgentAssignmentModel(
      assignmentId: assignmentId ?? this.assignmentId,
      principalDepartmentId:
          principalDepartmentId ?? this.principalDepartmentId,
      principalEmployeeId: principalEmployeeId ?? this.principalEmployeeId,
      agentDepartmentId: agentDepartmentId ?? this.agentDepartmentId,
      agentEmployeeId: agentEmployeeId ?? this.agentEmployeeId,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      createdTime: createdTime ?? this.createdTime,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedDate: updatedDate ?? this.updatedDate,
      updatedTime: updatedTime ?? this.updatedTime,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignment_id': assignmentId,
      'principal_department_id': principalDepartmentId,
      'principal_employee_id': principalEmployeeId,
      'agent_department_id': agentDepartmentId,
      'agent_employee_id': agentEmployeeId,
      'status': status,
      'created_date': createdDate,
      'created_time': createdTime,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'updated_date': updatedDate,
      'updated_time': updatedTime,
      'updated_by': updatedBy,
      'updated_by_name': updatedByName,
    };
  }

  factory EmpAgentAssignmentModel.fromMap(Map<String, dynamic> map) {
    return EmpAgentAssignmentModel(
      assignmentId: map['assignment_id']?.toString() ??
          map['assignmentId']?.toString() ??
          '',
      principalDepartmentId: map['principal_department_id']?.toString() ??
          map['principalDepartmentId']?.toString() ??
          '',
      principalEmployeeId: map['principal_employee_id']?.toString() ??
          map['principalEmployeeId']?.toString() ??
          '',
      agentDepartmentId: map['agent_department_id']?.toString() ??
          map['agentDepartmentId']?.toString() ??
          '',
      agentEmployeeId: map['agent_employee_id']?.toString() ??
          map['agentEmployeeId']?.toString() ??
          '',
      status: (map['status'] as num?)?.toInt() ?? 1,
      createdDate: map['created_date']?.toString() ??
          map['createdDate']?.toString() ??
          '',
      createdTime: map['created_time']?.toString() ??
          map['createdTime']?.toString() ??
          '',
      createdBy:
          map['created_by']?.toString() ?? map['createdBy']?.toString() ?? '',
      createdByName: map['created_by_name']?.toString() ??
          map['createdByName']?.toString() ??
          '',
      updatedDate: map['updated_date']?.toString() ??
          map['updatedDate']?.toString() ??
          '',
      updatedTime: map['updated_time']?.toString() ??
          map['updatedTime']?.toString() ??
          '',
      updatedBy:
          map['updated_by']?.toString() ?? map['updatedBy']?.toString() ?? '',
      updatedByName: map['updated_by_name']?.toString() ??
          map['updatedByName']?.toString() ??
          '',
    );
  }

  @override
  List<Object> get props => [
        assignmentId,
        principalDepartmentId,
        principalEmployeeId,
        agentDepartmentId,
        agentEmployeeId,
        status,
        createdDate,
        createdTime,
        createdBy,
        createdByName,
        updatedDate,
        updatedTime,
        updatedBy,
        updatedByName,
      ];
}
