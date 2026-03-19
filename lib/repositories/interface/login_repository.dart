import 'package:flutter_application_ai/model/user_model.dart';

abstract class LoginRepository {
  Future<UserModel> login(String email, String password);
}
