import 'package:flutter/material.dart';

class EmpDepHeaderWidget extends StatelessWidget {
  const EmpDepHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '部門綁定',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '左側選擇部門，右側顯示該部門既有員工；從下方未綁定員工區拖拉到上方即可完成綁定。',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF616161),
            ),
          ),
        ],
      ),
    );
  }
}
