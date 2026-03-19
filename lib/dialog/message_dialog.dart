import 'package:flutter/material.dart';

Future<void> showMessageDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  bool useRootNavigator = false,
  bool barrierDismissible = false,
  String? leftText,
  String? rightText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      final hasConfirm = onConfirm != null;
      final hasCancel = onCancel != null || hasConfirm;

      return AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          if (hasCancel)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (onCancel != null) {
                  onCancel.call();
                }
              },
              child: Text(leftText ?? '取消'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (hasConfirm) {
                onConfirm.call();
              }
            },
            child: Text(rightText ?? (hasConfirm ? '確認' : '關閉')),
          ),
        ],
      );
    },
  );
}

Future<void> showScrollableMessageDialog({
  required BuildContext context,
  required String title,
  required Widget child,
  double width = 700,
  bool useRootNavigator = false,
  bool barrierDismissible = false,
  String? rightText,
}) {
  return showMessageDialog(
    context: context,
    title: title,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    rightText: rightText,
    content: SizedBox(
      width: width,
      child: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

Future<void> showTextInputDialog({
  required BuildContext context,
  required String title,
  required TextEditingController controller,
  required String labelText,
  required ValueChanged<String> onConfirm,
  VoidCallback? onCancel,
  bool useRootNavigator = false,
  bool barrierDismissible = false,
  String? leftText,
  String? rightText,
  bool autofocus = true,
}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: autofocus,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.of(dialogContext).pop();
            onConfirm(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onCancel?.call();
            },
            child: Text(leftText ?? '取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm(controller.text);
            },
            child: Text(rightText ?? '確認'),
          ),
        ],
      );
    },
  );
}
