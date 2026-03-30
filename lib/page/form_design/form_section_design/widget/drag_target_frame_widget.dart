import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';

class DragTargetFrameWidget extends StatelessWidget {
  final int index;
  final Widget child;
  final double widthFactor;

  const DragTargetFrameWidget({
    super.key,
    required this.index,
    required this.child,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;

    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: DragTarget<Object>(
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Container(
            margin: const EdgeInsets.only(bottom: 8, right: 8),
            decoration: isHovering
                ? BoxDecoration(
                    border:
                        Border.all(color: themeColors.hoverBorder, width: 2),
                    borderRadius: BorderRadius.circular(6),
                    color: themeColors.hoverFill,
                    boxShadow: [
                      BoxShadow(
                        color: themeColors.selectedShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  )
                : null,
            child: child,
          );
        },
        onAcceptWithDetails: (details) {
          final data = details.data;
          if (data is DesignerItemType) {
            context
                .read<FormSectionDesignBloc>()
                .add(InsertDesignerItemEvent(data, index));
          } else if (data is DesignerItem) {
            context
                .read<FormSectionDesignBloc>()
                .add(MoveDesignerItemEvent(data.id, index));
          }
        },
      ),
    );
  }
}
