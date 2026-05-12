part of 'form_run_bloc.dart';

class FormRunEvent extends Equatable {
  const FormRunEvent();

  @override
  List<Object> get props => [];
}

class FormRunInitEvent extends FormRunEvent {
  final String formId;
  final String bindingId;
  final String applicantId;
  final String applicantName;
  final String departmentId;

  /// 編輯模式 — 非空時 form_run 以「編輯既有 LeaveSignOffModel」模式啟動。
  final String signOffId;

  const FormRunInitEvent(
    this.formId, {
    this.bindingId = '',
    this.applicantId = '',
    this.applicantName = '',
    this.departmentId = '',
    this.signOffId = '',
  });

  @override
  List<Object> get props => [
        formId,
        bindingId,
        applicantId,
        applicantName,
        departmentId,
        signOffId,
      ];
}

class FormRunFieldChangedEvent extends FormRunEvent {
  final String itemId;
  final String value;

  const FormRunFieldChangedEvent(this.itemId, this.value);

  @override
  List<Object> get props => [itemId, value];
}

class FormRunButtonPressedEvent extends FormRunEvent {
  final String itemId;

  const FormRunButtonPressedEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class FormRunDropdownLoadedEvent extends FormRunEvent {
  final String itemId;

  const FormRunDropdownLoadedEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class FormRunDropdownChangedEvent extends FormRunEvent {
  final String itemId;
  final String value;

  const FormRunDropdownChangedEvent(this.itemId, this.value);

  @override
  List<Object> get props => [itemId, value];
}

class FormRunDismissResultEvent extends FormRunEvent {
  const FormRunDismissResultEvent();
}
