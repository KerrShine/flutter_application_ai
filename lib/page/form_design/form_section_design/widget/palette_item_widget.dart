import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/palette_tile_widget.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';

class PaletteItemWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final DesignerItemType data;

  const PaletteItemWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;

    return Draggable<DesignerItemType>(
      data: data,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: themeColors.tileBackground,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: themeColors.tileBorder),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: themeColors.tileIconBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: themeColors.tileIconColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: PaletteTileWidget(title: title, icon: icon),
      ),
      child: PaletteTileWidget(title: title, icon: icon),
    );
  }
}
