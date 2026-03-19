import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/draggable_designer_item_widget.dart';

/// 畫布中單一列，寬度依 [widthPercentage] 以列寬的絕對比例切分。
/// 可接受來自元件庫（DesignerItemType）或其他列（DesignerItem）的拖曳。
class CanvasRowWidget extends StatelessWidget {
  final int rowIndex;
  final List<DesignerItem> items;
  final String selectedItemId;

  const CanvasRowWidget({
    super.key,
    required this.rowIndex,
    required this.items,
    required this.selectedItemId,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) =>
          details.data is DesignerItemType || details.data is DesignerItem,
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data is DesignerItemType) {
          context.read<FormSectionDesignBloc>().add(
                AddDesignerItemEvent(data, targetRowIndex: rowIndex),
              );
        } else if (data is DesignerItem && data.rowIndex != rowIndex) {
          context.read<FormSectionDesignBloc>().add(
                MoveItemToRowEvent(data.id, rowIndex),
              );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovering ? Colors.blue : Colors.grey.shade200,
              width: isHovering ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color:
                isHovering ? Colors.blue.withOpacity(0.05) : Colors.transparent,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            '拖曳元件到此列',
                            style:
                                TextStyle(color: Colors.black38, fontSize: 13),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final totalFlex = items.fold<int>(
                              0,
                              (sum, item) =>
                                  sum + (item.widthPercentage * 100).round(),
                            );
                            final remaining = 100 - totalFlex;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ...items.asMap().entries.map((entry) {
                                  final item = entry.value;
                                  return Expanded(
                                    flex: (item.widthPercentage * 100).round(),
                                    child: DraggableDesignerItemWidget(
                                      item: item,
                                      index: entry.key,
                                      isSelected: item.id == selectedItemId,
                                    ),
                                  );
                                }),
                                if (remaining > 0)
                                  Expanded(
                                    flex: remaining,
                                    child: const SizedBox(),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red.shade300,
                    size: 20,
                  ),
                  tooltip: '刪除此列',
                  onPressed: () => context
                      .read<FormSectionDesignBloc>()
                      .add(DeleteRowEvent(rowIndex)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
