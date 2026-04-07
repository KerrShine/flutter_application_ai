import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/drag_target_frame_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/widget/draggable_designer_item_widget.dart';
import 'package:flutter_application_ai/theme/form_section_design_theme_colors.dart';

/// 畫布中單一列，寬度依 [widthPercentage] 以列寬的絕對比例切分。
/// 可接受來自元件庫（DesignerItemType）或其他列（DesignerItem）的拖曳。
class CanvasRowWidget extends StatelessWidget {
  final int rowIndex;
  final List<DesignerItem> allItems;
  final List<DesignerItem> items;
  final String selectedItemId;

  const CanvasRowWidget({
    super.key,
    required this.rowIndex,
    required this.allItems,
    required this.items,
    required this.selectedItemId,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormSectionDesignThemeColors>()!;

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
              color: isHovering ? themeColors.hoverBorder : themeColors.border,
              width: isHovering ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
            color: isHovering ? themeColors.hoverFill : themeColors.surface,
            boxShadow: [
              BoxShadow(
                color: isHovering
                    ? themeColors.selectedShadow
                    : themeColors.panelShadow,
                blurRadius: isHovering ? 14 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            '拖曳元件到此列',
                            style: TextStyle(
                              color: themeColors.textFaint,
                              fontSize: 13,
                            ),
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
                            final rowChildren = <Widget>[];

                            for (final entry in items.asMap().entries) {
                              final item = entry.value;
                              final globalIndex = allItems.indexWhere(
                                (candidate) => candidate.id == item.id,
                              );

                              if (entry.key == 0 && globalIndex != -1) {
                                rowChildren.add(
                                  DragTargetFrameWidget(
                                    rowIndex: rowIndex,
                                    insertIndex: globalIndex,
                                  ),
                                );
                              }

                              rowChildren.add(
                                Expanded(
                                  flex: (item.widthPercentage * 100).round(),
                                  child: DraggableDesignerItemWidget(
                                    item: item,
                                    index: entry.key,
                                    isSelected: item.id == selectedItemId,
                                  ),
                                ),
                              );

                              if (globalIndex != -1) {
                                rowChildren.add(
                                  DragTargetFrameWidget(
                                    rowIndex: rowIndex,
                                    insertIndex: globalIndex + 1,
                                  ),
                                );
                              }
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ...rowChildren,
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
                    color: themeColors.destructiveSoft,
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
