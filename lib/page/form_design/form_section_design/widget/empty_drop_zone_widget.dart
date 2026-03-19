import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';

class EmptyDropZoneWidget extends StatelessWidget {
  const EmptyDropZoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(
              border: Border.all(
                color: isHovering ? Colors.blue : Colors.grey.shade300,
                width: isHovering ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isHovering ? Colors.blue.withOpacity(0.05) : null,
            ),
            child: const Center(child: Text('把左側元件拖到這裡開始建立表單')),
          ),
        );
      },
    );
  }
}
