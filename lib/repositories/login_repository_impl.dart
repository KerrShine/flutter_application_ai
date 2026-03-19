import 'dart:async';
import 'package:flutter_application_ai/data/remote/dio_client.dart';
import 'package:flutter_application_ai/model/user_model.dart';
import 'package:flutter_application_ai/repositories/interface/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final DioClient dioClient;

  LoginRepositoryImpl(this.dioClient);

  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'test001' && password == '123456') {
      return const UserModel(
        id: '123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
    } else {
      throw Exception('Login failed');
    }
  }
}
