import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/enum/sign_off_condition_field_status.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/bloc/sign_off_editor_bloc.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_editor_condition_field_status_chip_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_editor_rule_preview_controls_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_editor_simulation_controls_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/units/sign_off_preview_chain_dialog.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 簽核流程編輯器頂部工具列 — 流程名稱、對應表單、狀態、模擬/規則預覽控制、預覽簽核鏈、節點數 chip。
class SignOffEditorHeaderRowWidget extends StatelessWidget {
  final SignOffEditorState state;

  const SignOffEditorHeaderRowWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final bloc = context.read<SignOffEditorBloc>();
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colors.headerAccentBackground.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          SizedBox(
            width: 280,
            child: TextFormField(
              initialValue: state.template.name,
              style: labelStyle,
              decoration: const InputDecoration(
                labelText: '流程名稱',
                isDense: true,
              ),
              onChanged: (value) => bloc.add(UpdateTemplateNameEvent(value)),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 240,
            child: DropdownButtonFormField<String>(
              value:
                  state.template.formId.isEmpty ? null : state.template.formId,
              style: labelStyle,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: '對應表單',
                isDense: true,
              ),
              items: state.availableForms.map((f) {
                final summary = state.conditionFieldStatuses[f.id];
                final status =
                    summary?.status ?? SignOffConditionFieldStatus.none;
                return DropdownMenuItem(
                  value: f.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status.icon,
                        size: 14,
                        color: signOffConditionFieldStatusColor(
                            theme, colors, status),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          f.name,
                          style: labelStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  bloc.add(SelectFormForTemplateEvent(value));
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          if (state.template.formId.isNotEmpty) ...[
            SignOffEditorConditionFieldStatusChipWidget(
              summary: state.currentConditionFieldSummary,
              onPressed: () => bloc
                  .add(const RequestOpenConditionFieldCenterEvent()),
            ),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              value: state.template.status,
              style: labelStyle,
              decoration: const InputDecoration(
                labelText: '狀態',
                isDense: true,
              ),
              items: [
                DropdownMenuItem(
                    value: 'draft', child: Text('草稿', style: labelStyle)),
                DropdownMenuItem(
                    value: 'active', child: Text('啟用中', style: labelStyle)),
                DropdownMenuItem(
                    value: 'disabled', child: Text('已停用', style: labelStyle)),
              ],
              onChanged: (value) {
                if (value != null) {
                  bloc.add(UpdateTemplateStatusEvent(value));
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          SignOffEditorSimulationControlsWidget(
            simulationMode: state.simulationMode,
            simulationDaysAgo: state.simulationDaysAgo,
          ),
          const SizedBox(width: 12),
          SignOffEditorRulePreviewControlsWidget(
            rulePreviewMode: state.rulePreviewMode,
            formFieldsLoading: state.formFieldsLoading,
            formFields: state.formFields,
            rulePreviewValues: state.rulePreviewValues,
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => showSignOffPreviewChainDialog(
              context: context,
              template: state.template,
              employees: state.employees,
              formFields: state.formFields,
              service: sl<SignOffService>(),
              onRequestOpenEmpAgentPage: () =>
                  bloc.add(const RequestOpenEmpAgentPageEvent()),
            ),
            icon: const Icon(Icons.preview_outlined, size: 16),
            label: Text(
              '預覽簽核鏈',
              style: TextStyle(
                fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.headerChipBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.linear_scale,
                    size: 16, color: colors.headerChipText),
                const SizedBox(width: 4),
                Text(
                  '節點數 ${state.template.canvasNodes.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                    color: colors.headerChipText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
