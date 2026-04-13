import 'package:flutter/material.dart';

class BindingStatusChipWidget extends StatelessWidget {
  final bool isEnabled;

  const BindingStatusChipWidget({
    super.key,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isEnabled ? '啟用' : '停用';
    final foreground = isEnabled
        ? (isDark ? const Color(0xFF8BD3A8) : const Color(0xFF1E7A45))
        : (isDark ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A));
    final background = foreground.withValues(alpha: isDark ? 0.16 : 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
