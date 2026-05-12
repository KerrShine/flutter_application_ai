part of 'application_create_bloc.dart';

enum ApplicationCreateStatus {
  init,
  loading,
  success,
  failure,
}

class ApplicationCreateState extends Equatable {
  final ApplicationCreateStatus status;
  final String message;
  final int messageRequestId;
  final String employeeId;
  final List<AvailableFormItem> availableForms;
  final String searchQuery;
  final String navigateRoute;
  final Map<String, dynamic> navigateExtra;

  const ApplicationCreateState({
    this.status = ApplicationCreateStatus.init,
    this.message = '',
    this.messageRequestId = 0,
    this.employeeId = '',
    this.availableForms = const [],
    this.searchQuery = '',
    this.navigateRoute = '',
    this.navigateExtra = const {},
  });

  List<AvailableFormItem> get filteredForms {
    if (searchQuery.isEmpty) return availableForms;
    final query = searchQuery.toLowerCase();
    return availableForms
        .where((item) => item.formName.toLowerCase().contains(query))
        .toList();
  }

  ApplicationCreateState copyWith({
    ApplicationCreateStatus? status,
    String? message,
    int? messageRequestId,
    String? employeeId,
    List<AvailableFormItem>? availableForms,
    String? searchQuery,
    String? navigateRoute,
    Map<String, dynamic>? navigateExtra,
  }) {
    return ApplicationCreateState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      employeeId: employeeId ?? this.employeeId,
      availableForms: availableForms ?? this.availableForms,
      searchQuery: searchQuery ?? this.searchQuery,
      navigateRoute: navigateRoute ?? this.navigateRoute,
      navigateExtra: navigateExtra ?? this.navigateExtra,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        messageRequestId,
        employeeId,
        availableForms,
        searchQuery,
        navigateRoute,
        navigateExtra,
      ];
}
