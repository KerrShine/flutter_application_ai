import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_composer/bloc/form_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_composer/widgets/info_row_widget.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormDesignInfoPanelWidget extends StatelessWidget {
  final FormDesignState state;
  final VoidCallback onSaveDraft;
  final VoidCallback onPreviewJson;
  final VoidCallback onBrowse;

  const FormDesignInfoPanelWidget({
    super.key,
    required this.state,
    required this.onSaveDraft,
    required this.onPreviewJson,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final totalItemCount = state.selectedSections.fold<int>(
      0,
      (sum, section) => sum + section.items.length,
    );

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colors.infoPanelBackground,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatCard(
                          label: '目前表單',
                          value:
                              state.formName.isEmpty ? '未命名表單' : state.formName,
                          colors: colors,
                        ),
                        const SizedBox(height: 10),
                        InfoRowWidget(
                          label: 'Section 數',
                          value: '${state.selectedSections.length}',
                        ),
                        const SizedBox(height: 8),
                        InfoRowWidget(
                          label: '總元件數',
                          value: '$totalItemCount',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onBrowse,
                        icon: const Icon(Icons.preview_outlined),
                        label: const Text('表單瀏覽'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onPreviewJson,
                        icon: const Icon(Icons.data_object_outlined),
                        label: const Text('Json 瀏覽'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onSaveDraft,
                        icon: const Icon(Icons.save_as_outlined),
                        label: const Text('表單暫存'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final FormDesignThemeColors colors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.statsCardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.statsCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.faintText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
