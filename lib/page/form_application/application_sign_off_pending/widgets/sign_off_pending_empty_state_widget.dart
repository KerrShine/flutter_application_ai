import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';

/// 「待我簽核」v1 空殼提示 — sign_off 流程未實作時顯示。
class SignOffPendingEmptyStateWidget extends StatelessWidget {
  const SignOffPendingEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: themeColors.emptyText,
            ),
            const SizedBox(height: 16),
            const Text(
              '待我簽核',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '此功能將於簽核流程模組完成後上線',
              style: TextStyle(fontSize: 14, color: themeColors.subtitleText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
