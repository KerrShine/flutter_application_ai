import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/sign_off_approver_mode.dart';
import 'package:flutter_application_ai/enum/sign_off_multi_strategy.dart';
import 'package:flutter_application_ai/enum/sign_off_node_type.dart';
import 'package:flutter_application_ai/enum/sign_off_return_policy.dart';

/// 簽核流程畫布上的節點 — 一個節點代表一個簽核關卡。
class SignOffCanvasNode extends Equatable {
  final String nodeId;

  /// 引用的組織部門 ID（拖曳來源）。申請起點虛擬節點時為空字串。
  final String departmentId;

  final double offsetDx;
  final double offsetDy;

  /// 簽核順序（sortOrder）。
  /// 申請起點為 0，其餘節點依拖入順序遞增。
  /// 使用者可透過屬性面板的「上移/下移」改變順序。
  final int sortOrder;

  /// 是否為申請起點（虛擬節點，不屬於實際部門）。
  final bool isApplicantOrigin;

  final SignOffNodeType nodeType;
  final SignOffApproverMode approverMode;

  /// 同層互簽目標 nodeId（v1 單目標）。
  final String crossLevelTargetNodeId;

  /// 指定角色 ID（approverMode = designatedRole 時使用）。
  final String designatedRoleId;

  /// 指定員工 ID（approverMode = designatedEmployee 時使用）。
  final String designatedEmployeeId;

  /// 會簽多人策略（僅 nodeType = countersign 時使用）。
  final SignOffMultiStrategy multiStrategy;

  final SignOffReturnPolicy returnPolicy;

  /// 退回指定關卡時使用的目標 nodeId。
  final String returnTargetNodeId;

  /// 是否允許加簽（v1 預設 false，v2 啟用）。
  final bool allowAddSigner;

  /// 簽核期限天數（SLA）。0 = 不限期；> 0 = 限定 N 天內必須完成簽核。
  /// 僅對 nodeType = approve / countersign 有意義；notify 與申請起點不使用。
  final int slaDays;

  /// 相對申請人「往上 N 層主管」的層數（沿 parentDepartmentId 鏈走 N 步）。
  /// 0 = 申請人直屬部門主管；N = 沿組織樹往上 N 步的部門主管。
  /// 僅 approverMode = applicantAncestorManager 使用。
  final int applicantAncestorOffset;

  /// 申請人指定組織層級主管 — depthLevel 目標值。
  /// 0 = 總管理、1 = 事業群、2 = BU、3+ = 子部門。
  /// 僅 approverMode = applicantManagerAtDepth 使用。
  final int applicantTargetDepthLevel;

  const SignOffCanvasNode({
    required this.nodeId,
    this.departmentId = '',
    required this.offsetDx,
    required this.offsetDy,
    this.sortOrder = 0,
    this.isApplicantOrigin = false,
    this.nodeType = SignOffNodeType.approve,
    this.approverMode = SignOffApproverMode.hierarchyManager,
    this.crossLevelTargetNodeId = '',
    this.designatedRoleId = '',
    this.designatedEmployeeId = '',
    this.multiStrategy = SignOffMultiStrategy.all,
    this.returnPolicy = SignOffReturnPolicy.toApplicant,
    this.returnTargetNodeId = '',
    this.allowAddSigner = false,
    this.slaDays = 0,
    this.applicantAncestorOffset = 0,
    this.applicantTargetDepthLevel = 0,
  });

  SignOffCanvasNode copyWith({
    String? nodeId,
    String? departmentId,
    double? offsetDx,
    double? offsetDy,
    int? sortOrder,
    bool? isApplicantOrigin,
    SignOffNodeType? nodeType,
    SignOffApproverMode? approverMode,
    String? crossLevelTargetNodeId,
    String? designatedRoleId,
    String? designatedEmployeeId,
    SignOffMultiStrategy? multiStrategy,
    SignOffReturnPolicy? returnPolicy,
    String? returnTargetNodeId,
    bool? allowAddSigner,
    int? slaDays,
    int? applicantAncestorOffset,
    int? applicantTargetDepthLevel,
  }) {
    return SignOffCanvasNode(
      nodeId: nodeId ?? this.nodeId,
      departmentId: departmentId ?? this.departmentId,
      offsetDx: offsetDx ?? this.offsetDx,
      offsetDy: offsetDy ?? this.offsetDy,
      sortOrder: sortOrder ?? this.sortOrder,
      isApplicantOrigin: isApplicantOrigin ?? this.isApplicantOrigin,
      nodeType: nodeType ?? this.nodeType,
      approverMode: approverMode ?? this.approverMode,
      crossLevelTargetNodeId:
          crossLevelTargetNodeId ?? this.crossLevelTargetNodeId,
      designatedRoleId: designatedRoleId ?? this.designatedRoleId,
      designatedEmployeeId: designatedEmployeeId ?? this.designatedEmployeeId,
      multiStrategy: multiStrategy ?? this.multiStrategy,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      returnTargetNodeId: returnTargetNodeId ?? this.returnTargetNodeId,
      allowAddSigner: allowAddSigner ?? this.allowAddSigner,
      slaDays: slaDays ?? this.slaDays,
      applicantAncestorOffset:
          applicantAncestorOffset ?? this.applicantAncestorOffset,
      applicantTargetDepthLevel:
          applicantTargetDepthLevel ?? this.applicantTargetDepthLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nodeId': nodeId,
      'departmentId': departmentId,
      'offsetDx': offsetDx,
      'offsetDy': offsetDy,
      'sortOrder': sortOrder,
      'isApplicantOrigin': isApplicantOrigin,
      'nodeType': nodeType.code,
      'approverMode': approverMode.code,
      'crossLevelTargetNodeId': crossLevelTargetNodeId,
      'designatedRoleId': designatedRoleId,
      'designatedEmployeeId': designatedEmployeeId,
      'multiStrategy': multiStrategy.code,
      'returnPolicy': returnPolicy.code,
      'returnTargetNodeId': returnTargetNodeId,
      'allowAddSigner': allowAddSigner,
      'slaDays': slaDays,
      'applicantAncestorOffset': applicantAncestorOffset,
      'applicantTargetDepthLevel': applicantTargetDepthLevel,
    };
  }

  factory SignOffCanvasNode.fromMap(Map<String, dynamic> map) {
    return SignOffCanvasNode(
      nodeId: map['nodeId']?.toString() ?? '',
      departmentId: map['departmentId']?.toString() ?? '',
      offsetDx: (map['offsetDx'] as num?)?.toDouble() ?? 0,
      offsetDy: (map['offsetDy'] as num?)?.toDouble() ?? 0,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      isApplicantOrigin: map['isApplicantOrigin'] as bool? ?? false,
      nodeType: SignOffNodeTypeX.fromCode(map['nodeType']?.toString()),
      approverMode:
          SignOffApproverModeX.fromCode(map['approverMode']?.toString()),
      crossLevelTargetNodeId: map['crossLevelTargetNodeId']?.toString() ?? '',
      designatedRoleId: map['designatedRoleId']?.toString() ?? '',
      designatedEmployeeId: map['designatedEmployeeId']?.toString() ?? '',
      multiStrategy:
          SignOffMultiStrategyX.fromCode(map['multiStrategy']?.toString()),
      returnPolicy:
          SignOffReturnPolicyX.fromCode(map['returnPolicy']?.toString()),
      returnTargetNodeId: map['returnTargetNodeId']?.toString() ?? '',
      allowAddSigner: map['allowAddSigner'] as bool? ?? false,
      slaDays: (map['slaDays'] as num?)?.toInt() ?? 0,
      applicantAncestorOffset:
          (map['applicantAncestorOffset'] as num?)?.toInt() ?? 0,
      applicantTargetDepthLevel:
          (map['applicantTargetDepthLevel'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object> get props => [
        nodeId,
        departmentId,
        offsetDx,
        offsetDy,
        sortOrder,
        isApplicantOrigin,
        nodeType,
        approverMode,
        crossLevelTargetNodeId,
        designatedRoleId,
        designatedEmployeeId,
        multiStrategy,
        returnPolicy,
        returnTargetNodeId,
        allowAddSigner,
        slaDays,
        applicantAncestorOffset,
        applicantTargetDepthLevel,
      ];
}
