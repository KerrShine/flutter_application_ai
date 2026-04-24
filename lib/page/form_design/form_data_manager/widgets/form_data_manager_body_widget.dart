import 'package:flutter/material.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'binding_mapping_table_widget.dart';
import 'binding_sidebar_widget.dart';
import 'binding_summary_panel_widget.dart';

class FormDataManagerBodyWidget extends StatelessWidget {
  final FormDataManagerState state;
  final VoidCallback onAddBinding;
  final ValueChanged<String> onSelectBinding;
  final ValueChanged<String> onEditBinding;
  final ValueChanged<String> onDeleteBinding;
  final VoidCallback onPreviewApiExport;
  final VoidCallback onExportJson;
  final VoidCallback? onRunForm;

  const FormDataManagerBodyWidget({
    super.key,
    required this.state,
    required this.onAddBinding,
    required this.onSelectBinding,
    required this.onEditBinding,
    required this.onDeleteBinding,
    required this.onPreviewApiExport,
    required this.onExportJson,
    this.onRunForm,
  });

  @override
  Widget build(BuildContext context) {
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useCompactLayout = constraints.maxWidth < 1380;
                final sidebarWidth = useCompactLayout ? 268.0 : 300.0;
                final summaryWidth = useCompactLayout ? 280.0 : 320.0;

                return Container(
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
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: sidebarWidth,
                          child: BindingSidebarWidget(
                            state: state,
                            onAddBinding: onAddBinding,
                            onSelectBinding: onSelectBinding,
                            onEditBinding: onEditBinding,
                            onDeleteBinding: onDeleteBinding,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BindingMappingTableWidget(
                            state: state,
                            onPreviewApiExport: onPreviewApiExport,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: summaryWidth,
                          child: BindingSummaryPanelWidget(
                            state: state,
                            onExportJson: onExportJson,
                            onRunForm: onRunForm,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
