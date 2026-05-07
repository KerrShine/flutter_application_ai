import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class EditorFormSectionWidget extends StatelessWidget {
  final List<FormModel> forms;
  final String selectedFormId;
  final void Function(String formId, String formName) onSelectForm;

  const EditorFormSectionWidget({
    super.key,
    required this.forms,
    required this.selectedFormId,
    required this.onSelectForm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.sectionPanelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.headerAccentBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.sectionIconBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: colors.sectionIconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '選擇表單',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '指定此權限設定對應的表單',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtleText,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.headerChipBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '必填',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.headerChipText,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dropdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: selectedFormId.isNotEmpty ? selectedFormId : null,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 19),
              decoration: InputDecoration(
                hintText: '請選擇表單',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 19,
                  color: colors.faintText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: forms.map((form) {
                return DropdownMenuItem(
                  value: form.id,
                  child: Text(form.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final form = forms.firstWhere((f) => f.id == value);
                  onSelectForm(form.id, form.name);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
