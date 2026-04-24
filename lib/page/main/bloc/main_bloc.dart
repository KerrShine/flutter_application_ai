import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/service/main_service.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final MainService _service;

  MainBloc(this._service) : super(const MainState()) {
    on<InitEvent>(_onInitEvent);
    on<MainAddShortcutEvent>(_onAddShortcut);
    on<MainRemoveShortcutEvent>(_onRemoveShortcut);
    on<MainToggleShortcutEditEvent>(_onToggleShortcutEdit);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(status: MainStatus.loading));

    final result = await _service.initData();
    final shortcuts = _service.loadShortcuts();

    if (result.isSuccess) {
      emit(state.copyWith(
        status: MainStatus.success,
        shortcuts: shortcuts,
      ));
    } else {
      emit(state.copyWith(
        status: MainStatus.failure,
        message: result.error,
        shortcuts: shortcuts,
      ));
    }
  }

  Future<void> _onAddShortcut(
    MainAddShortcutEvent event,
    Emitter<MainState> emit,
  ) async {
    if (state.shortcuts.contains(event.path)) return;
    if (state.shortcuts.length >= MainService.maxShortcuts) return;

    final updated = [...state.shortcuts, event.path];
    emit(state.copyWith(shortcuts: updated));
    await _service.saveShortcuts(updated);
  }

  Future<void> _onRemoveShortcut(
    MainRemoveShortcutEvent event,
    Emitter<MainState> emit,
  ) async {
    final updated = state.shortcuts.where((p) => p != event.path).toList();
    emit(state.copyWith(shortcuts: updated));
    await _service.saveShortcuts(updated);
  }

  void _onToggleShortcutEdit(
    MainToggleShortcutEditEvent event,
    Emitter<MainState> emit,
  ) {
    emit(state.copyWith(isEditingShortcuts: !state.isEditingShortcuts));
  }
}
