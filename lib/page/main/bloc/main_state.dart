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
  // 其他資料欄位

  const MainState({
    this.status = MainStatus.init,
    this.message = '',
  });

  MainState copyWith({
    MainStatus? status,
    String? message,
  }) {
    return MainState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [status, message];
}
