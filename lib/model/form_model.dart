import 'package:equatable/equatable.dart';

class FormModel extends Equatable {
  final String id;
  final String name;
  final String size;
  final List<String> sectionIds; // For phase 2, section assignments

  const FormModel({
    required this.id,
    required this.name,
    required this.size,
    this.sectionIds = const [],
  });

  FormModel copyWith({
    String? id,
    String? name,
    String? size,
    List<String>? sectionIds,
  }) {
    return FormModel(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      sectionIds: sectionIds ?? this.sectionIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'sectionIds': sectionIds,
    };
  }

  factory FormModel.fromMap(Map<String, dynamic> map) {
    return FormModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      size: map['size'] ?? '',
      sectionIds: List<String>.from(map['sectionIds'] ?? []),
    );
  }

  @override
  List<Object> get props => [id, name, size, sectionIds];
}
