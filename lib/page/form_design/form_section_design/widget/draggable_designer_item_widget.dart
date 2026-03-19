import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/designer_item_row_widget.dart';

class DraggableDesignerItemWidget extends StatelessWidget {
  final DesignerItem item;
  final int index;
  final bool isSelected;

  const DraggableDesignerItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<DesignerItem>(
      data: item,
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 300, // Fixed width for feedback
          child: DesignerItemRowWidget(item: item, index: index, isSelected: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: DesignerItemRowWidget(item: item, index: index, isSelected: isSelected),
      ),
      child: DesignerItemRowWidget(item: item, index: index, isSelected: isSelected),
    );
  }
}
