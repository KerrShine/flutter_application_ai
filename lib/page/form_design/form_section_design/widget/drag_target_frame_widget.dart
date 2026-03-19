import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';

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
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: DragTarget<Object>(
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Container(
            margin: const EdgeInsets.only(bottom: 8, right: 8),
            decoration: isHovering
                ? BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.withOpacity(0.1),
                  )
                : null,
            child: child,
          );
        },
        onAcceptWithDetails: (details) {
          final data = details.data;
          if (data is DesignerItemType) {
            context.read<FormSectionDesignBloc>().add(InsertDesignerItemEvent(data, index));
          } else if (data is DesignerItem) {
            context.read<FormSectionDesignBloc>().add(MoveDesignerItemEvent(data.id, index));
          }
        },
      ),
    );
  }
}
