import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/page/login/bloc/login_bloc.dart';
import 'package:flutter_application_ai/page/login/bloc/login_event.dart';
import 'package:flutter_application_ai/page/login/bloc/login_state.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/login/widgets/login_form_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _deepBlue = Color(0xFF1E3A5F);
  late final LoginBloc _bloc;
  final TextEditingController _emailController =
      TextEditingController(text: 'test001');
  final TextEditingController _passwordController =
      TextEditingController(text: '123456');

  @override
  void initState() {
    super.initState();
    _bloc = sl<LoginBloc>();
    _bloc.add(InitEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              switch (state.status) {
                case LoginStatus.failure:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  break;
                case LoginStatus.success:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login Success!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go(RouteName.mainPage);
                  break;
                default:
                  break;
              }
            },
          ),
        ],
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return Scaffold(
              body: Stack(
                children: [
                  // Background Color
                  Container(
                    color: Colors.white,
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // App Icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Container(
                                  color: Colors.white,
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      _deepBlue,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      'assets/wellan_icon.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.auto_awesome,
                                          size: 60,
                                          color: _deepBlue,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Login Form Widget
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 420,
                              ),
                              child: LoginFormWidget(
                                emailController: _emailController,
                                passwordController: _passwordController,
                                isLoading: state.status == LoginStatus.loading,
                                onLogin: () {
                                  _bloc.add(
                                    LoginRequestEvent(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
