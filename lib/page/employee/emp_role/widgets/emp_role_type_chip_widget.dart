import 'package:flutter/material.dart';

class EmpRoleTypeChipWidget extends StatelessWidget {
  final bool isManagerLevel;

  const EmpRoleTypeChipWidget({
    super.key,
    required this.isManagerLevel,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        isManagerLevel ? const Color(0xFF5046B3) : const Color(0xFF227A68);
    final backgroundColor =
        isManagerLevel ? const Color(0xFFE8E4FF) : const Color(0xFFDDF9F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isManagerLevel ? '管理職' : '一般職',
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
