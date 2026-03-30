import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends LoginEvent {}

class LoginRequestEvent extends LoginEvent {
  final String email;
  final String password;

  const LoginRequestEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class ChangeThemeModeEvent extends LoginEvent {
  final ThemeMode themeMode;

  const ChangeThemeModeEvent({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}
