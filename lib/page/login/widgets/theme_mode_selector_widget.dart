import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/app_colors.dart';
import 'package:flutter_application_ai/theme/login_theme_colors.dart';

class ThemeModeSelectorWidget extends StatelessWidget {
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onChanged;

  const ThemeModeSelectorWidget({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loginThemeColors = Theme.of(context).extension<LoginThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: loginThemeColors.selectorBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: loginThemeColors.panelShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Light'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Dark'),
          ),
        ],
        selected: <ThemeMode>{selectedMode},
        onSelectionChanged: (selection) {
          if (selection.isNotEmpty) {
            onChanged(selection.first);
          }
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return Theme.of(context).colorScheme.onSurface;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }

            return Colors.transparent;
          }),
          side: WidgetStateProperty.all(BorderSide.none),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
