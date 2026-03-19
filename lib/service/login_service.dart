import 'package:flutter_application_ai/model/user_model.dart';
import 'package:flutter_application_ai/repositories/interface/login_repository.dart';

class LoginService {
  final LoginRepository _loginRepository;

  LoginService(this._loginRepository);

  Future<UserModel> login(String email, String password) async {
    return await _loginRepository.login(email, password);
  }
}
