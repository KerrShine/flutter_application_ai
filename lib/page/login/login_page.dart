import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/main.dart';
import 'package:flutter_application_ai/page/login/bloc/login_bloc.dart';
import 'package:flutter_application_ai/page/login/bloc/login_event.dart';
import 'package:flutter_application_ai/page/login/bloc/login_state.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/login/widgets/login_form_widget.dart';
import 'package:flutter_application_ai/page/login/widgets/theme_mode_selector_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/theme/app_colors.dart';
import 'package:flutter_application_ai/theme/login_theme_colors.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginBloc _bloc;
  final TextEditingController _accountController =
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
    _accountController.dispose();
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
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  break;
                case LoginStatus.success:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login Success!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.go(RouteName.mainPage);
                  break;
                default:
                  break;
              }
            },
          ),
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (previous, current) =>
                previous.themeMode != current.themeMode,
            listener: (context, state) {
              appThemeController.setThemeMode(state.themeMode);
            },
          ),
        ],
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;
            final loginThemeColors =
                Theme.of(context).extension<LoginThemeColors>()!;

            return Scaffold(
              body: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: loginThemeColors.backgroundGradient,
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Theme',
                              style: textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            ThemeModeSelectorWidget(
                              selectedMode: state.themeMode,
                              onChanged: (themeMode) {
                                _bloc.add(
                                  ChangeThemeModeEvent(themeMode: themeMode),
                                );
                              },
                            ),
                            const SizedBox(height: 28),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: loginThemeColors.heroShadowColor,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Container(
                                  color: colorScheme.surface,
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      colorScheme.primary,
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
                                          color: AppColors.primary,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Wellan AI Platform',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 40),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 420,
                              ),
                              child: LoginFormWidget(
                                accountController: _accountController,
                                passwordController: _passwordController,
                                isLoading: state.status == LoginStatus.loading,
                                onLogin: () {
                                  _bloc.add(
                                    LoginRequestEvent(
                                      email: _accountController.text,
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
