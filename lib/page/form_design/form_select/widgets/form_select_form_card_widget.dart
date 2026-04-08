import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormSelectFormCardWidget extends StatelessWidget {
  final FormModel form;
  final VoidCallback onTap;

  const FormSelectFormCardWidget({
    super.key,
    required this.form,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.sectionCardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.sectionCardBorder),
          boxShadow: [
            BoxShadow(
              color: colors.sectionCardShadow,
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
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
                    child: Text(
                      form.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'ID: ${form.id}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.faintText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '區塊數: ${form.sectionIds.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.faintText,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricChip(
                    label: '表單識別',
                    value: form.id.length > 12
                        ? '${form.id.substring(0, 12)}...'
                        : form.id,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('進入綁定'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value'),
    );
  }
}
