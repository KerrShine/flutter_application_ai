import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/designer_item.dart';

class ChoiceGroupWidget extends StatelessWidget {
  final DesignerItem item;
  final bool isRadio;
  final Color primaryTextColor;

  const ChoiceGroupWidget({
    super.key,
    required this.item,
    required this.isRadio,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final optionLabels = item.isGrouped ? item.options : [item.text];
    final title = item.isGrouped && item.text.isNotEmpty ? item.text : '';
    final optionSpacing = item.optionSpacing;
    final children = optionLabels
        .asMap()
        .entries
        .map(
          (entry) => _ChoiceOptionWidget(
            label: entry.value,
            isRadio: isRadio,
            isChecked: isRadio ? entry.key == 0 : false,
            fontSize: item.fontSize,
            textColor: primaryTextColor,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: item.fontSize,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (item.isGrouped &&
            item.optionLayout == DesignerItemOptionLayout.horizontal)
          Wrap(
            spacing: optionSpacing,
            runSpacing: optionSpacing,
            children: children,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map(
                  (child) => Padding(
                    padding: EdgeInsets.only(bottom: optionSpacing),
                    child: child,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ChoiceOptionWidget extends StatelessWidget {
  final String label;
  final bool isRadio;
  final bool isChecked;
  final double fontSize;
  final Color textColor;

  const _ChoiceOptionWidget({
    required this.label,
    required this.isRadio,
    required this.isChecked,
    required this.fontSize,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isRadio) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<bool>(
            value: true,
            groupValue: isChecked,
            onChanged: (_) {},
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            label,
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (_) {},
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          label,
          style: TextStyle(fontSize: fontSize, color: textColor),
        ),
      ],
    );
  }
}
