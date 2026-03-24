part of 'org_design_config_bloc.dart';

enum OrgDesignConfigStatus {
  init,
  loading,
  success,
  saved,
  failure,
}

class OrgDesignConfigState extends Equatable {
  final OrgDesignConfigStatus status;
  final String message;
  final String orgName;
  final List<OrgDepartmentNode> departmentNodes;
  final String selectedDepartmentId;
  final String draftDepartmentName;
  final String draftDepartmentCode;
  final String draftParentId;
  final int draftDepartmentStatus;

  const OrgDesignConfigState({
    this.status = OrgDesignConfigStatus.init,
    this.message = '',
    this.orgName = '',
    this.departmentNodes = const [],
    this.selectedDepartmentId = '',
    this.draftDepartmentName = '',
    this.draftDepartmentCode = '',
    this.draftParentId = '',
    this.draftDepartmentStatus = 1,
  });

  bool get isEditing => selectedDepartmentId.isNotEmpty;

  OrgDesignConfigState copyWith({
    OrgDesignConfigStatus? status,
    String? message,
    String? orgName,
    List<OrgDepartmentNode>? departmentNodes,
    String? selectedDepartmentId,
    String? draftDepartmentName,
    String? draftDepartmentCode,
    String? draftParentId,
    int? draftDepartmentStatus,
  }) {
    return OrgDesignConfigState(
      status: status ?? this.status,
      message: message ?? this.message,
      orgName: orgName ?? this.orgName,
      departmentNodes: departmentNodes ?? this.departmentNodes,
      selectedDepartmentId: selectedDepartmentId ?? this.selectedDepartmentId,
      draftDepartmentName: draftDepartmentName ?? this.draftDepartmentName,
      draftDepartmentCode: draftDepartmentCode ?? this.draftDepartmentCode,
      draftParentId: draftParentId ?? this.draftParentId,
      draftDepartmentStatus:
          draftDepartmentStatus ?? this.draftDepartmentStatus,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        orgName,
        departmentNodes,
        selectedDepartmentId,
        draftDepartmentName,
        draftDepartmentCode,
        draftParentId,
        draftDepartmentStatus,
      ];
}
