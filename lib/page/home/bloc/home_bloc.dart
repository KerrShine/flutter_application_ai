import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeTabChanged>(_onTabChanged);
    on<HomeNavigateEvent>(_onNavigate);
  }

  void _onTabChanged(HomeTabChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(tabIndex: event.index));
  }

  void _onNavigate(HomeNavigateEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(navigateRoute: event.routeName));
    emit(state.copyWith(clearNavigateRoute: true));
  }
}
