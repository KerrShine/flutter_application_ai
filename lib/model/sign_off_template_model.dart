import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/model/sign_off_path_rule.dart';

/// 簽核流程模板。
class SignOffTemplateModel extends Equatable {
  final String templateId;
  final String formId;
  final String formName;

  /// 引用既有 form_launch_permission 的 permissionId（可空）。
  final String permissionId;

  final String name;

  /// 流程狀態：draft / active / disabled
  final String status;

  final List<SignOffCanvasNode> canvasNodes;

  /// Path 路由規則 — 提交時依 sortOrder first-match 評估，決定本次走哪些 nodeId。
  /// 空 list = backward compat，行為等同「全部節點都啟用」。
  final List<SignOffPathRule> pathRules;

  /// Matrix4.storage（縮放/平移狀態）— 16 個 double，可空。
  final List<double> canvasTransform;

  final int version;
  final String createdAt;
  final String updatedAt;

  const SignOffTemplateModel({
    this.templateId = '',
    this.formId = '',
    this.formName = '',
    this.permissionId = '',
    this.name = '',
    this.status = 'draft',
    this.canvasNodes = const [],
    this.pathRules = const [],
    this.canvasTransform = const [],
    this.version = 1,
    this.createdAt = '',
    this.updatedAt = '',
  });

  bool get isActive => status == 'active';
  bool get isDraft => status == 'draft';
  bool get isDisabled => status == 'disabled';

  SignOffTemplateModel copyWith({
    String? templateId,
    String? formId,
    String? formName,
    String? permissionId,
    String? name,
    String? status,
    List<SignOffCanvasNode>? canvasNodes,
    List<SignOffPathRule>? pathRules,
    List<double>? canvasTransform,
    int? version,
    String? createdAt,
    String? updatedAt,
  }) {
    return SignOffTemplateModel(
      templateId: templateId ?? this.templateId,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      permissionId: permissionId ?? this.permissionId,
      name: name ?? this.name,
      status: status ?? this.status,
      canvasNodes: canvasNodes ?? this.canvasNodes,
      pathRules: pathRules ?? this.pathRules,
      canvasTransform: canvasTransform ?? this.canvasTransform,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'templateId': templateId,
      'formId': formId,
      'formName': formName,
      'permissionId': permissionId,
      'name': name,
      'status': status,
      'canvasNodes': canvasNodes.map((node) => node.toMap()).toList(),
      'pathRules': pathRules.map((rule) => rule.toMap()).toList(),
      'canvasTransform': canvasTransform,
      'version': version,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory SignOffTemplateModel.fromMap(Map<String, dynamic> map) {
    final nodesRaw = map['canvasNodes'];
    final rulesRaw = map['pathRules'];
    final transformRaw = map['canvasTransform'];

    return SignOffTemplateModel(
      templateId: map['templateId']?.toString() ?? '',
      formId: map['formId']?.toString() ?? '',
      formName: map['formName']?.toString() ?? '',
      permissionId: map['permissionId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      status: map['status']?.toString() ?? 'draft',
      canvasNodes: nodesRaw is List
          ? nodesRaw
              .map((item) =>
                  SignOffCanvasNode.fromMap(item as Map<String, dynamic>))
              .toList()
          : const [],
      pathRules: rulesRaw is List
          ? rulesRaw
              .map((item) =>
                  SignOffPathRule.fromMap(item as Map<String, dynamic>))
              .toList()
          : const [],
      canvasTransform: transformRaw is List
          ? transformRaw.map((e) => (e as num).toDouble()).toList()
          : const [],
      version: (map['version'] as num?)?.toInt() ?? 1,
      createdAt: map['createdAt']?.toString() ?? '',
      updatedAt: map['updatedAt']?.toString() ?? '',
    );
  }

  @override
  List<Object> get props => [
        templateId,
        formId,
        formName,
        permissionId,
        name,
        status,
        canvasNodes,
        pathRules,
        canvasTransform,
        version,
        createdAt,
        updatedAt,
      ];
}
