import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_choice.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/bloc/sign_off_editor_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 簽核流程編輯器頂部的「規則預覽」控制 — 切換 rulePreviewMode 並依條件欄位即時模擬輸入，預覽 path rule first-match 命中的啟用節點。
class SignOffEditorRulePreviewControlsWidget extends StatelessWidget {
  final bool rulePreviewMode;
  final bool formFieldsLoading;
  final List<SignOffConditionFieldChoice> formFields;
  final Map<String, String> rulePreviewValues;

  const SignOffEditorRulePreviewControlsWidget({
    super.key,
    required this.rulePreviewMode,
    required this.formFieldsLoading,
    required this.formFields,
    required this.rulePreviewValues,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
      fontWeight: FontWeight.w700,
      color: colors.headerChipText,
    );
    final bloc = context.read<SignOffEditorBloc>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.headerChipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alt_route, size: 16, color: colors.headerChipText),
          const SizedBox(width: 4),
          Text('規則預覽', style: labelStyle),
          const SizedBox(width: 4),
          Switch.adaptive(
            value: rulePreviewMode,
            onChanged: (value) {
              bloc.add(value
                  ? const EnterRulePreviewEvent()
                  : const ExitRulePreviewEvent());
            },
          ),
          if (rulePreviewMode) ...[
            const SizedBox(width: 6),
            if (formFieldsLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (formFields.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '此表單無可比對欄位',
                  style: labelStyle?.copyWith(color: colors.actionWarning),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final field in formFields) ...[
                        SizedBox(
                          width: 160,
                          child: TextFormField(
                            key: ValueKey('preview_${field.outputKey}'),
                            initialValue:
                                rulePreviewValues[field.outputKey] ?? '',
                            style: labelStyle,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: field.label,
                              helperText: field.outputKey,
                              helperMaxLines: 1,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            ),
                            onChanged: (value) => bloc.add(
                              UpdateRulePreviewValueEvent(
                                field.outputKey,
                                value,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
