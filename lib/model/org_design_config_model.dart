import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/org_tree_canvas_node.dart';

class OrgDesignConfigModel extends Equatable {
  final String orgId;
  final String orgName;
  final int schemaVersion;
  final String updatedAt;
  final List<OrgDepartmentNode> departmentNodes;
  final List<OrgTreeCanvasNode> treeCanvasNodes;

  const OrgDesignConfigModel({
    required this.orgId,
    required this.orgName,
    this.schemaVersion = 3,
    this.updatedAt = '',
    this.departmentNodes = const [],
    this.treeCanvasNodes = const [],
  });

  OrgDesignConfigModel copyWith({
    String? orgId,
    String? orgName,
    int? schemaVersion,
    String? updatedAt,
    List<OrgDepartmentNode>? departmentNodes,
    List<OrgTreeCanvasNode>? treeCanvasNodes,
  }) {
    return OrgDesignConfigModel(
      orgId: orgId ?? this.orgId,
      orgName: orgName ?? this.orgName,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      departmentNodes: departmentNodes ?? this.departmentNodes,
      treeCanvasNodes: treeCanvasNodes ?? this.treeCanvasNodes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orgId': orgId,
      'orgName': orgName,
      'schemaVersion': schemaVersion,
      'updatedAt': updatedAt,
      'departmentNodes': departmentNodes.map((node) => node.toMap()).toList(),
      'treeCanvasNodes': treeCanvasNodes.map((node) => node.toMap()).toList(),
    };
  }

  factory OrgDesignConfigModel.fromMap(Map<String, dynamic> map) {
    final rawNodes = map['departmentNodes'] as List<dynamic>? ?? const [];
    final rawCanvasNodes = map['treeCanvasNodes'] as List<dynamic>? ??
        map['canvasNodes'] as List<dynamic>? ??
        const [];
    return OrgDesignConfigModel(
      orgId: map['orgId']?.toString() ?? 'default_org',
      orgName: map['orgName']?.toString() ?? '簽核系統組織',
      schemaVersion: (map['schemaVersion'] as num?)?.toInt() ?? 3,
      updatedAt: map['updatedAt']?.toString() ?? '',
      departmentNodes: rawNodes
          .map(
              (item) => OrgDepartmentNode.fromMap(item as Map<String, dynamic>))
          .toList(),
      treeCanvasNodes: rawCanvasNodes
          .map(
            (item) => OrgTreeCanvasNode.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  List<Object> get props => [
        orgId,
        orgName,
        schemaVersion,
        updatedAt,
        departmentNodes,
        treeCanvasNodes,
      ];
}
