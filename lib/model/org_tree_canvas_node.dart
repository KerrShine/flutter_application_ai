import 'package:equatable/equatable.dart';

class OrgTreeCanvasNode extends Equatable {
  final String departmentId;
  final double offsetDx;
  final double offsetDy;

  const OrgTreeCanvasNode({
    required this.departmentId,
    required this.offsetDx,
    required this.offsetDy,
  });

  OrgTreeCanvasNode copyWith({
    String? departmentId,
    double? offsetDx,
    double? offsetDy,
  }) {
    return OrgTreeCanvasNode(
      departmentId: departmentId ?? this.departmentId,
      offsetDx: offsetDx ?? this.offsetDx,
      offsetDy: offsetDy ?? this.offsetDy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'departmentId': departmentId,
      'offsetDx': offsetDx,
      'offsetDy': offsetDy,
    };
  }

  factory OrgTreeCanvasNode.fromMap(Map<String, dynamic> map) {
    return OrgTreeCanvasNode(
      departmentId: map['departmentId']?.toString() ?? '',
      offsetDx: (map['offsetDx'] as num?)?.toDouble() ?? 0,
      offsetDy: (map['offsetDy'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object> get props => [departmentId, offsetDx, offsetDy];
}
