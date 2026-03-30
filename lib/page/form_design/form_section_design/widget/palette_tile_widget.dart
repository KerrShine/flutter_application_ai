import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';

class PaletteTileWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const PaletteTileWidget({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: themeColors.tileBorder),
        color: themeColors.tileBackground,
        boxShadow: [
          BoxShadow(
            color: themeColors.tileShadow,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: themeColors.tileIconBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: themeColors.tileIconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: themeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: themeColors.textFaint, size: 18),
        ],
      ),
    );
  }
}
