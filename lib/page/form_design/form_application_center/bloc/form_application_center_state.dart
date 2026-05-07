part of 'form_application_center_bloc.dart';

enum FormApplicationCenterStatus {
  init,
  loading,
  success,
  failure,
}

class FormApplicationCenterState extends Equatable {
  final FormApplicationCenterStatus status;
  final String message;
  final int messageRequestId;
  final String employeeId;
  final EmployeeModel currentEmployee;
  final List<AvailableFormItem> availableForms;
  final List<FormSubmissionModel> mySubmissions;
  final String searchQuery;

  // navigation
  final String navigateRoute;
  final Map<String, dynamic> navigateExtra;

  // export
  final String exportJson;
  final int exportDialogRequestId;

  const FormApplicationCenterState({
    this.status = FormApplicationCenterStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.employeeId = '',
    this.currentEmployee = const EmployeeModel(),
    this.availableForms = const [],
    this.mySubmissions = const [],
    this.searchQuery = '',
    this.navigateRoute = '',
    this.navigateExtra = const {},
    this.exportJson = '',
    this.exportDialogRequestId = 0,
  });

  List<AvailableFormItem> get filteredForms {
    if (searchQuery.isEmpty) return availableForms;
    final query = searchQuery.toLowerCase();
    return availableForms
        .where((item) => item.formName.toLowerCase().contains(query))
        .toList();
  }

  FormApplicationCenterState copyWith({
    FormApplicationCenterStatus? status,
    String? message,
    int? messageRequestId,
    String? employeeId,
    EmployeeModel? currentEmployee,
    List<AvailableFormItem>? availableForms,
    List<FormSubmissionModel>? mySubmissions,
    String? searchQuery,
    String? navigateRoute,
    Map<String, dynamic>? navigateExtra,
    String? exportJson,
    int? exportDialogRequestId,
  }) {
    return FormApplicationCenterState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      employeeId: employeeId ?? this.employeeId,
      currentEmployee: currentEmployee ?? this.currentEmployee,
      availableForms: availableForms ?? this.availableForms,
      mySubmissions: mySubmissions ?? this.mySubmissions,
      searchQuery: searchQuery ?? this.searchQuery,
      navigateRoute: navigateRoute ?? this.navigateRoute,
      navigateExtra: navigateExtra ?? this.navigateExtra,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        messageRequestId,
        employeeId,
        currentEmployee,
        availableForms,
        mySubmissions,
        searchQuery,
        navigateRoute,
        navigateExtra,
        exportJson,
        exportDialogRequestId,
      ];
}
