import 'package:equatable/equatable.dart';

/// 會簽節點內部多人簽核狀態追蹤。
///
/// 只追蹤該節點「已 approve」與「已 reject」的人員 ID 集合，
/// 供 [FormApplicationService] 在 multiStrategy = all / sequential 時
/// 判定是否收斂 / 推進。actionHistory 仍保留完整時間軸；本結構僅用於
/// 推進判斷時的快速查詢。
class NodeApprovalState extends Equatable {
  /// 對應 ResolvedApprover.nodeId。
  final String nodeId;

  /// 已 approve 的 employeeId 序列（按發生順序）。
  final List<String> approvedBy;

  /// 已 reject 的 employeeId 序列（按發生順序）。
  final List<String> rejectedBy;

  const NodeApprovalState({
    required this.nodeId,
    this.approvedBy = const [],
    this.rejectedBy = const [],
  });

  NodeApprovalState copyWith({
    String? nodeId,
    List<String>? approvedBy,
    List<String>? rejectedBy,
  }) {
    return NodeApprovalState(
      nodeId: nodeId ?? this.nodeId,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectedBy: rejectedBy ?? this.rejectedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'node_id': nodeId,
      'approved_by': approvedBy,
      'rejected_by': rejectedBy,
    };
  }

  factory NodeApprovalState.fromMap(Map<String, dynamic> map) {
    return NodeApprovalState(
      nodeId: (map['node_id'] ?? map['nodeId'] ?? '').toString(),
      approvedBy: ((map['approved_by'] ?? map['approvedBy'] ?? const []) as List)
          .map((e) => e.toString())
          .toList(),
      rejectedBy: ((map['rejected_by'] ?? map['rejectedBy'] ?? const []) as List)
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  List<Object> get props => [nodeId, approvedBy, rejectedBy];
}
