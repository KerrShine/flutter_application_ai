import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';

class EmptyDropZoneWidget extends StatelessWidget {
  const EmptyDropZoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;

    return DragTarget<DesignerItemType>(
      onAcceptWithDetails: (details) {
        context
            .read<FormSectionDesignBloc>()
            .add(AddDesignerItemEvent(details.data, targetRowIndex: 0));
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Center(
          child: Container(
            height: 160,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isHovering ? themeColors.hoverBorder : themeColors.border,
                width: isHovering ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
              color: isHovering
                  ? themeColors.hoverFill
                  : themeColors.emptyStateBackground,
              boxShadow: [
                BoxShadow(
                  color: isHovering
                      ? themeColors.selectedShadow
                      : themeColors.panelShadow,
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '把左側元件拖到這裡開始建立表單',
                style: TextStyle(
                  color: themeColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
