part of 'org_manager_bloc.dart';

enum OrgManagerStatus {
  init,
  loading,
  success,
  failure,
}

class OrgManagerState extends Equatable {
  static const String defaultOrgName = '簽核系統組織';

  final OrgManagerStatus status;
  final String message;
  final String orgName;
  final int departmentCount;
  final String updatedAt;
  final String pendingDeleteOrgName;
  final int deleteDialogRequestId;
  final String? navigateRoute;

  const OrgManagerState({
    this.status = OrgManagerStatus.init,
    this.message = '',
    this.orgName = defaultOrgName,
    this.departmentCount = 0,
    this.updatedAt = '',
    this.pendingDeleteOrgName = '',
    this.deleteDialogRequestId = 0,
    this.navigateRoute,
  });

  bool get hasOrganization => departmentCount > 0;

  OrgManagerState copyWith({
    OrgManagerStatus? status,
    String? message,
    String? orgName,
    int? departmentCount,
    String? updatedAt,
    String? pendingDeleteOrgName,
    int? deleteDialogRequestId,
    String? navigateRoute,
    bool clearNavigateRoute = false,
  }) {
    return OrgManagerState(
      status: status ?? this.status,
      message: message ?? this.message,
      orgName: orgName ?? this.orgName,
      departmentCount: departmentCount ?? this.departmentCount,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingDeleteOrgName: pendingDeleteOrgName ?? this.pendingDeleteOrgName,
      deleteDialogRequestId:
          deleteDialogRequestId ?? this.deleteDialogRequestId,
      navigateRoute:
          clearNavigateRoute ? null : (navigateRoute ?? this.navigateRoute),
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        orgName,
        departmentCount,
        updatedAt,
        pendingDeleteOrgName,
        deleteDialogRequestId,
        navigateRoute,
      ];
}
