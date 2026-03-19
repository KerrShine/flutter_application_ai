part of 'home_bloc.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeTabChanged extends HomeEvent {
  final int index;
  const HomeTabChanged(this.index);

  @override
  List<Object> get props => [index];
}

class HomeNavigateEvent extends HomeEvent {
  final String routeName;
  const HomeNavigateEvent(this.routeName);

  @override
  List<Object> get props => [routeName];
}
