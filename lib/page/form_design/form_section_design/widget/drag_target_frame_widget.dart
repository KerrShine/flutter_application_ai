import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';

class DragTargetFrameWidget extends StatelessWidget {
  final int rowIndex;
  final int insertIndex;

  const DragTargetFrameWidget({
    super.key,
    required this.rowIndex,
    required this.insertIndex,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;

    return DragTarget<DesignerItem>(
      onWillAcceptWithDetails: (details) => details.data.rowIndex == rowIndex,
      onAcceptWithDetails: (details) {
        context.read<FormSectionDesignBloc>().add(
              MoveDesignerItemEvent(details.data.id, insertIndex),
            );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: isHovering ? 18 : 12,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isHovering
                ? themeColors.hoverBorder
                : themeColors.border.withValues(alpha: 0.18),
            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: themeColors.selectedShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
