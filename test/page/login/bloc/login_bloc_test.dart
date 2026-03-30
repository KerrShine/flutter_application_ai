import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/login/bloc/login_bloc.dart';
import 'package:flutter_application_ai/page/login/bloc/login_event.dart';
import 'package:flutter_application_ai/page/login/bloc/login_state.dart';
import 'package:flutter_application_ai/model/user_model.dart';
import 'package:flutter_application_ai/service/login_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginService extends Mock implements LoginService {}

void main() {
  group('LoginBloc', () {
    late LoginService loginService;

    setUp(() {
      loginService = MockLoginService();
    });

    test('initial state is correct', () {
      expect(LoginBloc(loginService).state,
          const LoginState(status: LoginStatus.init));
    });

    blocTest<LoginBloc, LoginState>(
      'emits updated theme mode when ChangeThemeModeEvent is added',
      build: () => LoginBloc(loginService),
      act: (bloc) => bloc.add(
        const ChangeThemeModeEvent(themeMode: ThemeMode.dark),
      ),
      expect: () => const [
        LoginState(
          status: LoginStatus.init,
          themeMode: ThemeMode.dark,
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, success] when LoginRequestEvent succeeds',
      build: () {
        when(() => loginService.login(any(), any())).thenAnswer(
          (_) async => const UserModel(
            id: '123',
            email: 'test@example.com',
            displayName: 'Test User',
          ),
        );
        return LoginBloc(loginService);
      },
      act: (bloc) => bloc.add(const LoginRequestEvent(
          email: 'test@example.com', password: 'password')),
      expect: () => const [
        LoginState(status: LoginStatus.loading),
        LoginState(
          status: LoginStatus.success,
          user: UserModel(
            id: '123',
            email: 'test@example.com',
            displayName: 'Test User',
          ),
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, failure] when LoginRequestEvent fails',
      build: () {
        when(() => loginService.login(any(), any()))
            .thenThrow(Exception('Login failed'));
        return LoginBloc(loginService);
      },
      act: (bloc) => bloc
          .add(const LoginRequestEvent(email: 'wrong', password: 'password')),
      expect: () => [
        const LoginState(status: LoginStatus.loading),
        predicate<LoginState>((state) =>
            state.status == LoginStatus.failure &&
            state.message == 'Exception: Login failed'),
      ],
    );
  });
}
