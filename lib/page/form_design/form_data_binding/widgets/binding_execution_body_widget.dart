import 'package:flutter/material.dart';

import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/bloc/form_data_binding_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/widgets/binding_execution_empty_state_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/widgets/binding_execution_header_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/widgets/binding_execution_section_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/widgets/binding_execution_summary_widget.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class BindingExecutionBodyWidget extends StatelessWidget {
  final FormDataBindingState state;
  final VoidCallback onSave;
  final ValueChanged<bool> onBindingEnabledChanged;
  final String Function(String itemId) actionSummaryBuilder;
  final void Function(String sectionId, String itemId) onOpenActionBinding;
  final void Function(String sectionId, String itemId, String outputKey)
      onOutputKeyChanged;
  final void Function(
    String sectionId,
    String itemId,
    BindingNullStrategy nullStrategy,
  ) onNullStrategyChanged;
  final void Function(String sectionId, String itemId, String value)
      onCustomDefaultChanged;
  final void Function(String sectionId, String itemId, String key)
      onProvidedDataKeyChanged;
  final VoidCallback onExportJson;

  const BindingExecutionBodyWidget({
    super.key,
    required this.state,
    required this.onSave,
    required this.onBindingEnabledChanged,
    required this.actionSummaryBuilder,
    required this.onOpenActionBinding,
    required this.onOutputKeyChanged,
    required this.onNullStrategyChanged,
    required this.onCustomDefaultChanged,
    required this.onProvidedDataKeyChanged,
    required this.onExportJson,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == FormDataBindingStatus.init ||
        state.status == FormDataBindingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.pageGradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -30,
            child: GlowOrbWidget(color: colors.heroGlow, size: 220),
          ),
          Positioned(
            right: -60,
            bottom: -80,
            child: GlowOrbWidget(
              color: colors.heroGlow.withValues(alpha: 0.18),
              size: 240,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.shellBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.shellBorder),
                boxShadow: [
                  BoxShadow(
                    color: colors.shellShadow,
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BindingExecutionHeaderWidget(
                      draft: state.draft,
                      errorCount: state.errorCount,
                      isSaving: state.status == FormDataBindingStatus.saving,
                      onSave: onSave,
                      onBindingEnabledChanged: onBindingEnabledChanged,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 1360;
                          final summaryWidth = compact ? 300.0 : 340.0;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: state.draft.sections.isEmpty
                                    ? const BindingExecutionEmptyStateWidget()
                                    : SingleChildScrollView(
                                        child: Column(
                                          children: state.draft.sections
                                              .map(
                                                (section) =>
                                                    BindingExecutionSectionWidget(
                                                  section: section,
                                                  fieldErrorBuilder:
                                                      state.errorForField,
                                                  actionSummaryBuilder: (
                                                    itemId,
                                                  ) {
                                                    return actionSummaryBuilder(
                                                      itemId,
                                                    );
                                                  },
                                                  onOpenActionBinding:
                                                      onOpenActionBinding,
                                                  onOutputKeyChanged:
                                                      onOutputKeyChanged,
                                                  onNullStrategyChanged:
                                                      onNullStrategyChanged,
                                                  onCustomDefaultChanged:
                                                      onCustomDefaultChanged,
                                                  onProvidedDataKeyChanged:
                                                      onProvidedDataKeyChanged,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: summaryWidth,
                                child: BindingExecutionSummaryWidget(
                                  draft: state.draft,
                                  fieldErrors: state.fieldErrors,
                                  onExportJson: onExportJson,
                                  onSave: onSave,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
