import 'package:flutter/material.dart';

class BindingHeaderCellWidget extends StatelessWidget {
  final int flex;
  final String text;

  const BindingHeaderCellWidget({
    super.key,
    required this.flex,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
