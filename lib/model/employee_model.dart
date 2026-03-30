import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String account;
  final String departmentId;
  final String roleId;
  final String roleName;
  final int roleType;
  final int status;
  final String hireDate;
  final String leaveDate;
  final String createdDate;
  final String createdTime;
  final String createdBy;
  final String createdByName;
  final String updatedDate;
  final String updatedTime;
  final String updatedBy;
  final String updatedByName;

  const EmployeeModel({
    this.employeeId = '',
    this.employeeCode = '',
    this.employeeName = '',
    this.account = '',
    this.departmentId = '',
    this.roleId = '',
    this.roleName = '',
    this.roleType = 0,
    this.status = 1,
    this.hireDate = '',
    this.leaveDate = '',
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

  bool get isManagerLevel => roleType == 1;

  EmployeeModel copyWith({
    String? employeeId,
    String? employeeCode,
    String? employeeName,
    String? account,
    String? departmentId,
    String? roleId,
    String? roleName,
    int? roleType,
    int? status,
    String? hireDate,
    String? leaveDate,
    String? createdDate,
    String? createdTime,
    String? createdBy,
    String? createdByName,
    String? updatedDate,
    String? updatedTime,
    String? updatedBy,
    String? updatedByName,
  }) {
    return EmployeeModel(
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeName: employeeName ?? this.employeeName,
      account: account ?? this.account,
      departmentId: departmentId ?? this.departmentId,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      roleType: roleType ?? this.roleType,
      status: status ?? this.status,
      hireDate: hireDate ?? this.hireDate,
      leaveDate: leaveDate ?? this.leaveDate,
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
      'employee_id': employeeId,
      'employee_code': employeeCode,
      'employee_name': employeeName,
      'account': account,
      'department_id': departmentId,
      'role_id': roleId,
      'role_name': roleName,
      'role_type': roleType,
      'status': status,
      'hire_date': hireDate,
      'leave_date': leaveDate,
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

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      employeeId:
          map['employee_id']?.toString() ?? map['employeeId']?.toString() ?? '',
      employeeCode: map['employee_code']?.toString() ??
          map['employeeCode']?.toString() ??
          '',
      employeeName: map['employee_name']?.toString() ??
          map['employeeName']?.toString() ??
          '',
      account:
          map['account']?.toString() ?? map['loginAccount']?.toString() ?? '',
      departmentId: map['department_id']?.toString() ??
          map['departmentId']?.toString() ??
          '',
      roleId: map['role_id']?.toString() ?? map['roleId']?.toString() ?? '',
      roleName:
          map['role_name']?.toString() ?? map['roleName']?.toString() ?? '',
      roleType: (map['role_type'] as num?)?.toInt() ??
          (map['roleType'] as num?)?.toInt() ??
          ((map['isManagerLevel'] as bool?) == true ? 1 : 0),
      status: (map['status'] as num?)?.toInt() ??
          ((map['isActive'] as bool?) == false ? 0 : 1),
      hireDate:
          map['hire_date']?.toString() ?? map['hireDate']?.toString() ?? '',
      leaveDate:
          map['leave_date']?.toString() ?? map['leaveDate']?.toString() ?? '',
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
        employeeId,
        employeeCode,
        employeeName,
        account,
        departmentId,
        roleId,
        roleName,
        roleType,
        status,
        hireDate,
        leaveDate,
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
