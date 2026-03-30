import 'package:flutter/material.dart';

class EmpInfoStatusChipWidget extends StatelessWidget {
  final bool isActive;

  const EmpInfoStatusChipWidget({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        isActive ? const Color(0xFF1B5E20) : const Color(0xFF616161);
    final backgroundColor =
        isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? '啟用' : '停用',
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
