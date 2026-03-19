import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';

class TrailingDropZoneWidget extends StatelessWidget {
  final int rowCount;

  const TrailingDropZoneWidget({super.key, required this.rowCount});

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) =>
          details.data is DesignerItemType || details.data is DesignerItem,
      onAcceptWithDetails: (details) {
        final data = details.data;
        final newRowIndex = rowCount;
        if (data is DesignerItemType) {
          context
              .read<FormSectionDesignBloc>()
              .add(AddDesignerItemEvent(data, targetRowIndex: newRowIndex));
        } else if (data is DesignerItem) {
          context
              .read<FormSectionDesignBloc>()
              .add(MoveItemToRowEvent(data.id, newRowIndex));
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovering ? Colors.blue : Colors.grey.shade300,
              width: isHovering ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color:
                isHovering ? Colors.blue.withOpacity(0.05) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              isHovering ? '放開以新增一列' : '拖曳到此處新增列',
              style: TextStyle(
                color: isHovering ? Colors.blue : Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }
}
