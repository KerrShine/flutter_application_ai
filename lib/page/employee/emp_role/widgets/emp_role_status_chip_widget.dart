import 'package:flutter/material.dart';

class EmpRoleStatusChipWidget extends StatelessWidget {
  final bool isActive;

  const EmpRoleStatusChipWidget({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF7ED957) : const Color(0xFF9CA3AF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isActive ? '啟用' : '停用',
          style: TextStyle(
            color: isActive ? const Color(0xFF7ED957) : const Color(0xFFD1D5DB),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
