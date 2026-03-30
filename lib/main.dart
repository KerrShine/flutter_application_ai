import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/theme/theme_controller.dart';
import 'package:flutter_application_ai/theme/theme.dart';

final ThemeController appThemeController = ThemeController();

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initDI();

      runApp(const MainApp());
    },
    (error, stack) {
      debugPrint('Error: $error');
      debugPrint('Stack: $stack');
    },
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeController,
      builder: (context, themeMode, child) {
        return MaterialApp.router(
          title: 'Flutter Demo',
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
        );
      },
    );
  }
}
