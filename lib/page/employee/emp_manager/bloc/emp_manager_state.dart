part of 'emp_manager_bloc.dart';

enum EmpManagerStatus {
  init,
  loading,
  success,
  failure,
}

class EmpManagerState extends Equatable {
  final EmpManagerStatus status;
  final String message;
  final String navigateRoute;

  const EmpManagerState({
    this.status = EmpManagerStatus.init,
    this.message = '',
    this.navigateRoute = '',
  });

  EmpManagerState copyWith({
    EmpManagerStatus? status,
    String? message,
    String? navigateRoute,
  }) {
    return EmpManagerState(
      status: status ?? this.status,
      message: message ?? this.message,
      navigateRoute: navigateRoute ?? this.navigateRoute,
    );
  }

  @override
  List<Object> get props => [status, message, navigateRoute];
}
