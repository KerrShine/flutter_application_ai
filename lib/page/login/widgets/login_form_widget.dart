import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/app_colors.dart';
import 'package:flutter_application_ai/theme/login_theme_colors.dart';

class LoginFormWidget extends StatelessWidget {
  final TextEditingController accountController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;

  const LoginFormWidget({
    super.key,
    required this.accountController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final colorScheme = Theme.of(context).colorScheme;
    final loginThemeColors = Theme.of(context).extension<LoginThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: loginThemeColors.panelShadowColor,
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            context: context,
            controller: accountController,
            label: 'Account',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            context: context,
            controller: passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isObscure: true,
          ),
          const SizedBox(height: 32),
          if (isLoading)
            const CircularProgressIndicator(color: AppColors.primary)
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onLogin,
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary, size: 28),
      ),
    );
  }
}
