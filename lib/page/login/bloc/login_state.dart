import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/user_model.dart';

enum LoginStatus {
  init,
  loading,
  success,
  failure,
}

class LoginState extends Equatable {
  final LoginStatus status;
  final String message;
  final UserModel? user;

  const LoginState({
    this.status = LoginStatus.init,
    this.message = '',
    this.user,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? message,
    UserModel? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, message, user];
}
