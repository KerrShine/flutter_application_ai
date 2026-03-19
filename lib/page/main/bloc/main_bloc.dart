import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/service/main_service.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final MainService _service;

  MainBloc(this._service) : super(const MainState()) {
    on<InitEvent>(_onInitEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(status: MainStatus.loading));
    
    final result = await _service.initData();
    
    if (result.isSuccess) {
      emit(state.copyWith(
        status: MainStatus.success,
      ));
    } else {
      emit(state.copyWith(
        status: MainStatus.failure,
        message: result.error,
      ));
    }
  }
}
