import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/service/login_service.dart';
import 'package:flutter_application_ai/page/login/bloc/login_event.dart';
import 'package:flutter_application_ai/page/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginService _loginService;

  LoginBloc(this._loginService) : super(const LoginState()) {
    on<InitEvent>(_onInitEvent);
    on<LoginRequestEvent>(_onLoginEvent);
  }

  void _onInitEvent(InitEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: LoginStatus.init));
  }

  Future<void> _onLoginEvent(
    LoginRequestEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final user = await _loginService.login(event.email, event.password);
      emit(state.copyWith(
        status: LoginStatus.success,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        message: e.toString(),
      ));
    }
  }
}
