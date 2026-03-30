import 'package:flutter/material.dart';

class EmpRoleNextStepWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const EmpRoleNextStepWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111111),
          side: const BorderSide(color: Color(0xFFBDBDBD)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text('下一步：建立職員資料'),
      ),
    );
  }
}
