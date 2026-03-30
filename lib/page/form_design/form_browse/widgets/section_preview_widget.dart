import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/form_widget_factory.dart';
import 'package:flutter_application_ai/theme/form_browse_theme_colors.dart';

class SectionPreviewWidget extends StatelessWidget {
  final SectionModel section;
  final String? selectedFieldKey;
  final void Function(String sectionId, String itemId)? onFieldTap;

  const SectionPreviewWidget({
    super.key,
    required this.section,
    this.selectedFieldKey,
    this.onFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormBrowseThemeColors>()!;
    final rowIndexes =
        section.items.map((item) => item.rowIndex).toSet().toList()..sort();

    if (section.items.isEmpty) {
      return Text(
        '此 Section 無欄位',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.previewSubtleText,
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowIndexes.map((rowIndex) {
        final rowItems =
            section.items.where((item) => item.rowIndex == rowIndex).toList();
        final totalFlex = rowItems.fold<int>(
          0,
          (sum, item) => sum + (item.widthPercentage * 100).round(),
        );
        final remaining = 100 - totalFlex;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...rowItems.map((item) {
                  final fieldKey = '${section.id}::${item.id}';
                  final isSelected = selectedFieldKey == fieldKey;

                  return Expanded(
                    flex: (item.widthPercentage * 100).round(),
                    child: InkWell(
                      onTap: () => onFieldTap?.call(section.id, item.id),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isSelected
                              ? colors.previewSelectedBackground
                              : colors.previewSurface,
                        ),
                        child: FormWidgetFactory.buildReadOnlyWidget(
                          context,
                          item,
                        ),
                      ),
                    ),
                  );
                }),
                if (remaining > 0)
                  Expanded(flex: remaining, child: const SizedBox()),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
