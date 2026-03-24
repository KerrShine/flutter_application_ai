part of 'org_tree_design_bloc.dart';

enum OrgTreeDesignStatus {
  init,
  loading,
  success,
  saving,
  failure,
}

class OrgTreeDesignState extends Equatable {
  static const List<double> defaultCanvasTransformValues = [
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
  ];

  final OrgTreeDesignStatus status;
  final String message;
  final String noticeMessage;
  final int noticeId;
  final String orgId;
  final String orgName;
  final int schemaVersion;
  final String updatedAt;
  final List<OrgDepartmentNode> availableDepartments;
  final Map<String, String> departmentNameMap;
  final String filterKeyword;
  final List<OrgTreeCanvasNode> canvasNodes;
  final String selectedDepartmentId;
  final String draftParentDepartmentId;
  final double canvasScale;
  final double viewportWidth;
  final double viewportHeight;
  final List<double> canvasTransformValues;
  final int canvasTransformRequestId;
  final bool pendingAutoCenter;
  final String pendingRemovalDepartmentId;
  final String pendingRemovalDepartmentName;
  final int removeDialogRequestId;
  final String pendingSaveOrgName;
  final int saveDialogRequestId;
  final String exportJson;
  final int exportDialogRequestId;
  final bool hasUnsavedChanges;

  const OrgTreeDesignState({
    this.status = OrgTreeDesignStatus.init,
    this.message = '',
    this.noticeMessage = '',
    this.noticeId = 0,
    this.orgId = 'default_org',
    this.orgName = '',
    this.schemaVersion = 3,
    this.updatedAt = '',
    this.availableDepartments = const [],
    this.departmentNameMap = const {},
    this.filterKeyword = '',
    this.canvasNodes = const [],
    this.selectedDepartmentId = '',
    this.draftParentDepartmentId = '',
    this.canvasScale = 1.0,
    this.viewportWidth = 0,
    this.viewportHeight = 0,
    this.canvasTransformValues = defaultCanvasTransformValues,
    this.canvasTransformRequestId = 0,
    this.pendingAutoCenter = false,
    this.pendingRemovalDepartmentId = '',
    this.pendingRemovalDepartmentName = '',
    this.removeDialogRequestId = 0,
    this.pendingSaveOrgName = '',
    this.saveDialogRequestId = 0,
    this.exportJson = '',
    this.exportDialogRequestId = 0,
    this.hasUnsavedChanges = false,
  });

  OrgDepartmentNode? get selectedDepartment {
    for (final department in availableDepartments) {
      if (department.departmentId == selectedDepartmentId) {
        return department;
      }
    }
    return null;
  }

  OrgTreeCanvasNode? get selectedCanvasNode {
    for (final canvasNode in canvasNodes) {
      if (canvasNode.departmentId == selectedDepartmentId) {
        return canvasNode;
      }
    }
    return null;
  }

  bool get isSelectedDepartmentOnCanvas => selectedCanvasNode != null;

  List<OrgDepartmentNode> get canvasDepartments {
    final departmentIds = canvasNodes.map((node) => node.departmentId).toSet();
    return availableDepartments
        .where((department) => departmentIds.contains(department.departmentId))
        .toList();
  }

  List<OrgDepartmentNode> get filteredAvailableDepartments {
    final normalizedKeyword = filterKeyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) {
      return availableDepartments;
    }

    final filteredDepartments = availableDepartments.where((department) {
      final name = department.name.toLowerCase();
      final code = department.departmentCode.toLowerCase();
      return name.contains(normalizedKeyword) ||
          code.contains(normalizedKeyword);
    }).toList();

    return filteredDepartments.isEmpty
        ? availableDepartments
        : filteredDepartments;
  }

  List<OrgDepartmentNode> get availableParentDepartments {
    if (!isSelectedDepartmentOnCanvas) {
      return const [];
    }

    final blockedIds = _collectDescendantIds(selectedDepartmentId)
      ..add(selectedDepartmentId);
    return canvasDepartments
        .where((department) => !blockedIds.contains(department.departmentId))
        .toList();
  }

  String get selectedParentDepartmentName {
    final parentDepartmentId = selectedDepartment?.parentDepartmentId ?? '';
    if (parentDepartmentId.isEmpty) {
      return '未設定';
    }

    return departmentNameMap[parentDepartmentId] ?? parentDepartmentId;
  }

  String get selectedParentDepartmentId {
    return selectedDepartment?.parentDepartmentId ?? '';
  }

  Set<String> _collectDescendantIds(String departmentId) {
    final descendants = <String>{};
    final children = availableDepartments
        .where((department) => department.parentDepartmentId == departmentId)
        .toList();

    for (final child in children) {
      if (descendants.add(child.departmentId)) {
        descendants.addAll(_collectDescendantIds(child.departmentId));
      }
    }

    return descendants;
  }

  OrgTreeDesignState copyWith({
    OrgTreeDesignStatus? status,
    String? message,
    String? noticeMessage,
    int? noticeId,
    String? orgId,
    String? orgName,
    int? schemaVersion,
    String? updatedAt,
    List<OrgDepartmentNode>? availableDepartments,
    Map<String, String>? departmentNameMap,
    String? filterKeyword,
    List<OrgTreeCanvasNode>? canvasNodes,
    String? selectedDepartmentId,
    String? draftParentDepartmentId,
    double? canvasScale,
    double? viewportWidth,
    double? viewportHeight,
    List<double>? canvasTransformValues,
    int? canvasTransformRequestId,
    bool? pendingAutoCenter,
    String? pendingRemovalDepartmentId,
    String? pendingRemovalDepartmentName,
    int? removeDialogRequestId,
    String? pendingSaveOrgName,
    int? saveDialogRequestId,
    String? exportJson,
    int? exportDialogRequestId,
    bool? hasUnsavedChanges,
    bool clearNotice = false,
  }) {
    return OrgTreeDesignState(
      status: status ?? this.status,
      message: message ?? this.message,
      noticeMessage: clearNotice ? '' : (noticeMessage ?? this.noticeMessage),
      noticeId: noticeId ?? this.noticeId,
      orgId: orgId ?? this.orgId,
      orgName: orgName ?? this.orgName,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      availableDepartments: availableDepartments ?? this.availableDepartments,
      departmentNameMap: departmentNameMap ?? this.departmentNameMap,
      filterKeyword: filterKeyword ?? this.filterKeyword,
      canvasNodes: canvasNodes ?? this.canvasNodes,
      selectedDepartmentId: selectedDepartmentId ?? this.selectedDepartmentId,
      draftParentDepartmentId:
          draftParentDepartmentId ?? this.draftParentDepartmentId,
      canvasScale: canvasScale ?? this.canvasScale,
      viewportWidth: viewportWidth ?? this.viewportWidth,
      viewportHeight: viewportHeight ?? this.viewportHeight,
      canvasTransformValues:
          canvasTransformValues ?? this.canvasTransformValues,
      canvasTransformRequestId:
          canvasTransformRequestId ?? this.canvasTransformRequestId,
      pendingAutoCenter: pendingAutoCenter ?? this.pendingAutoCenter,
      pendingRemovalDepartmentId:
          pendingRemovalDepartmentId ?? this.pendingRemovalDepartmentId,
      pendingRemovalDepartmentName:
          pendingRemovalDepartmentName ?? this.pendingRemovalDepartmentName,
      removeDialogRequestId:
          removeDialogRequestId ?? this.removeDialogRequestId,
      pendingSaveOrgName: pendingSaveOrgName ?? this.pendingSaveOrgName,
      saveDialogRequestId: saveDialogRequestId ?? this.saveDialogRequestId,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        noticeMessage,
        noticeId,
        orgId,
        orgName,
        schemaVersion,
        updatedAt,
        availableDepartments,
        departmentNameMap,
        filterKeyword,
        canvasNodes,
        selectedDepartmentId,
        draftParentDepartmentId,
        canvasScale,
        viewportWidth,
        viewportHeight,
        canvasTransformValues,
        canvasTransformRequestId,
        pendingAutoCenter,
        pendingRemovalDepartmentId,
        pendingRemovalDepartmentName,
        removeDialogRequestId,
        pendingSaveOrgName,
        saveDialogRequestId,
        exportJson,
        exportDialogRequestId,
        hasUnsavedChanges,
      ];
}
