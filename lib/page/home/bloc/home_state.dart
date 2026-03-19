part of 'home_bloc.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  failure,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final int tabIndex;
  final String? navigateRoute;

  const HomeState({
    this.status = HomeStatus.initial,
    this.tabIndex = 0,
    this.navigateRoute,
  });

  HomeState copyWith({
    HomeStatus? status,
    int? tabIndex,
    String? navigateRoute,
    bool clearNavigateRoute = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      tabIndex: tabIndex ?? this.tabIndex,
      navigateRoute: clearNavigateRoute ? null : (navigateRoute ?? this.navigateRoute),
    );
  }

  @override
  List<Object?> get props => [status, tabIndex, navigateRoute];
}
