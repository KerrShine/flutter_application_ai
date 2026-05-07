import 'package:equatable/equatable.dart';

class FormSubmissionModel extends Equatable {
  final String submissionId;
  final String formId;
  final String formName;
  final String bindingId;
  final String applicantId;
  final String applicantName;
  final String departmentId;
  final Map<String, dynamic> fieldValues;
  final String status;
  final String submittedAt;
  final String createdAt;
  final String updatedAt;

  const FormSubmissionModel({
    this.submissionId = '',
    this.formId = '',
    this.formName = '',
    this.bindingId = '',
    this.applicantId = '',
    this.applicantName = '',
    this.departmentId = '',
    this.fieldValues = const {},
    this.status = 'draft',
    this.submittedAt = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  bool get isDraft => status == 'draft';
  bool get isSubmitted => status == 'submitted';

  FormSubmissionModel copyWith({
    String? submissionId,
    String? formId,
    String? formName,
    String? bindingId,
    String? applicantId,
    String? applicantName,
    String? departmentId,
    Map<String, dynamic>? fieldValues,
    String? status,
    String? submittedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return FormSubmissionModel(
      submissionId: submissionId ?? this.submissionId,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      bindingId: bindingId ?? this.bindingId,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      departmentId: departmentId ?? this.departmentId,
      fieldValues: fieldValues ?? this.fieldValues,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'submission_id': submissionId,
      'form_id': formId,
      'form_name': formName,
      'binding_id': bindingId,
      'applicant_id': applicantId,
      'applicant_name': applicantName,
      'department_id': departmentId,
      'field_values': fieldValues,
      'status': status,
      'submitted_at': submittedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FormSubmissionModel.fromMap(Map<String, dynamic> map) {
    return FormSubmissionModel(
      submissionId: map['submission_id']?.toString() ??
          map['submissionId']?.toString() ??
          '',
      formId:
          map['form_id']?.toString() ?? map['formId']?.toString() ?? '',
      formName:
          map['form_name']?.toString() ?? map['formName']?.toString() ?? '',
      bindingId:
          map['binding_id']?.toString() ?? map['bindingId']?.toString() ?? '',
      applicantId: map['applicant_id']?.toString() ??
          map['applicantId']?.toString() ??
          '',
      applicantName: map['applicant_name']?.toString() ??
          map['applicantName']?.toString() ??
          '',
      departmentId: map['department_id']?.toString() ??
          map['departmentId']?.toString() ??
          '',
      fieldValues: _parseMap(map['field_values'] ?? map['fieldValues']),
      status: map['status']?.toString() ?? 'draft',
      submittedAt: map['submitted_at']?.toString() ??
          map['submittedAt']?.toString() ??
          '',
      createdAt:
          map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '',
      updatedAt:
          map['updated_at']?.toString() ?? map['updatedAt']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  @override
  List<Object> get props => [
        submissionId,
        formId,
        formName,
        bindingId,
        applicantId,
        applicantName,
        departmentId,
        fieldValues,
        status,
        submittedAt,
        createdAt,
        updatedAt,
      ];
}
