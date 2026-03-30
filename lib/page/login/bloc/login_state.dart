import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
  final ThemeMode themeMode;

  const LoginState({
    this.status = LoginStatus.init,
    this.message = '',
    this.user,
    this.themeMode = ThemeMode.system,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? message,
    UserModel? user,
    ThemeMode? themeMode,
  }) {
    return LoginState(
      status: status ?? this.status,
      message: message ?? this.message,
      user: user ?? this.user,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [status, message, user, themeMode];
}
