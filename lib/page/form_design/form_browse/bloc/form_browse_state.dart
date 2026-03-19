import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/section_model.dart';

enum FormBrowseStatus { init, loading, success, failure }

class _UnsetValue {
  const _UnsetValue();
}

const _unsetValue = _UnsetValue();

class FormBrowseState extends Equatable {
  final FormBrowseStatus status;
  final String message;
  final List<SectionModel> sections;
  final String? selectedSectionId;
  final String? selectedFieldKey;
  final String? expandedFieldKey;

  const FormBrowseState({
    this.status = FormBrowseStatus.init,
    this.message = '',
    this.sections = const [],
    this.selectedSectionId,
    this.selectedFieldKey,
    this.expandedFieldKey,
  });

  FormBrowseState copyWith({
    FormBrowseStatus? status,
    String? message,
    List<SectionModel>? sections,
    Object? selectedSectionId = _unsetValue,
    Object? selectedFieldKey = _unsetValue,
    Object? expandedFieldKey = _unsetValue,
  }) {
    return FormBrowseState(
      status: status ?? this.status,
      message: message ?? this.message,
      sections: sections ?? this.sections,
      selectedSectionId: identical(selectedSectionId, _unsetValue)
          ? this.selectedSectionId
          : selectedSectionId as String?,
      selectedFieldKey: identical(selectedFieldKey, _unsetValue)
          ? this.selectedFieldKey
          : selectedFieldKey as String?,
      expandedFieldKey: identical(expandedFieldKey, _unsetValue)
          ? this.expandedFieldKey
          : expandedFieldKey as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        sections,
        selectedSectionId,
        selectedFieldKey,
        expandedFieldKey,
      ];
}
