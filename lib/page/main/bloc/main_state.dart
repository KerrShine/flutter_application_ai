part of 'main_bloc.dart';

enum MainStatus {
  init,
  loading,
  success,
  failure,
}

class MainState extends Equatable {
  final MainStatus status;
  final String message;
  final List<String> shortcuts;
  final bool isEditingShortcuts;

  const MainState({
    this.status = MainStatus.init,
    this.message = '',
    this.shortcuts = const [],
    this.isEditingShortcuts = false,
  });

  MainState copyWith({
    MainStatus? status,
    String? message,
    List<String>? shortcuts,
    bool? isEditingShortcuts,
  }) {
    return MainState(
      status: status ?? this.status,
      message: message ?? this.message,
      shortcuts: shortcuts ?? this.shortcuts,
      isEditingShortcuts: isEditingShortcuts ?? this.isEditingShortcuts,
    );
  }

  @override
  List<Object> get props => [status, message, shortcuts, isEditingShortcuts];
}
