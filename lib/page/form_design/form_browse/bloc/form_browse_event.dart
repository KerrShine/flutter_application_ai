import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/section_model.dart';

class FormBrowseEvent extends Equatable {
  const FormBrowseEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends FormBrowseEvent {
  final String formId;
  final List<SectionModel> initialSections;

  const InitEvent(
    this.formId, {
    this.initialSections = const [],
  });

  @override
  List<Object> get props => [formId, initialSections];
}

class SelectSectionEvent extends FormBrowseEvent {
  final String? sectionId;

  const SelectSectionEvent({this.sectionId});

  @override
  List<Object?> get props => [sectionId];
}

class SelectFieldEvent extends FormBrowseEvent {
  final String sectionId;
  final String itemId;

  const SelectFieldEvent({
    required this.sectionId,
    required this.itemId,
  });

  @override
  List<Object?> get props => [sectionId, itemId];
}

class ToggleFieldExpandEvent extends FormBrowseEvent {
  final String sectionId;
  final String itemId;

  const ToggleFieldExpandEvent({
    required this.sectionId,
    required this.itemId,
  });

  @override
  List<Object?> get props => [sectionId, itemId];
}
