import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/sign_off_path_condition.dart';

/// 簽核流程的 path 路由規則。
///
/// 提交申請時依 sortOrder 評估，第一個 condition 為 true 的 rule 被選用 →
/// 該 rule 的 activatedNodeIds 即為本次簽核要走的節點集合。
///
/// condition = null 代表 default rule（永遠 match）— 通常放在 sortOrder 最後。
class SignOffPathRule extends Equatable {
  final String ruleId;
  final String name;
  final SignOffPathCondition? condition;
  final List<String> activatedNodeIds;
  final int sortOrder;

  const SignOffPathRule({
    required this.ruleId,
    this.name = '',
    this.condition,
    this.activatedNodeIds = const [],
    this.sortOrder = 0,
  });

  bool get isDefault => condition == null;

  SignOffPathRule copyWith({
    String? ruleId,
    String? name,
    SignOffPathCondition? condition,
    bool clearCondition = false,
    List<String>? activatedNodeIds,
    int? sortOrder,
  }) {
    return SignOffPathRule(
      ruleId: ruleId ?? this.ruleId,
      name: name ?? this.name,
      condition: clearCondition ? null : (condition ?? this.condition),
      activatedNodeIds: activatedNodeIds ?? this.activatedNodeIds,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ruleId': ruleId,
      'name': name,
      'condition': condition?.toMap(),
      'activatedNodeIds': activatedNodeIds,
      'sortOrder': sortOrder,
    };
  }

  factory SignOffPathRule.fromMap(Map<String, dynamic> map) {
    final conditionRaw = map['condition'];
    final activatedRaw = map['activatedNodeIds'];
    return SignOffPathRule(
      ruleId: map['ruleId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      condition: conditionRaw is Map<String, dynamic>
          ? SignOffPathCondition.fromMap(conditionRaw)
          : null,
      activatedNodeIds: activatedRaw is List
          ? activatedRaw.map((e) => e.toString()).toList()
          : const [],
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        ruleId,
        name,
        condition,
        activatedNodeIds,
        sortOrder,
      ];
}
