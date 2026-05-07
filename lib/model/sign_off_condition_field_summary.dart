import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/enum/sign_off_condition_field_status.dart';

/// 對應表單的 form_condition_field 摘要 — 給 sign_off_editor header chip + dropdown 圖示用。
///
/// 由 [`SignOffService.loadConditionFieldStatuses`](../service/sign_off_service.dart) 算出。
class SignOffConditionFieldSummary extends Equatable {
  final SignOffConditionFieldStatus status;

  /// draft 中已定義的 ConditionFieldDefinition 數量。
  final int definitionCount;

  const SignOffConditionFieldSummary({
    required this.status,
    required this.definitionCount,
  });

  static const SignOffConditionFieldSummary empty =
      SignOffConditionFieldSummary(
    status: SignOffConditionFieldStatus.none,
    definitionCount: 0,
  );

  @override
  List<Object?> get props => [status, definitionCount];
}
