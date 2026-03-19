import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/bloc/form_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/widgets/info_row_widget.dart';

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
    return Container(
      width: 240,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('表單資訊', style: Theme.of(context).textTheme.titleSmall),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRowWidget(label: '名稱', value: state.formName),
                const SizedBox(height: 8),
                InfoRowWidget(
                  label: 'Section 數',
                  value: '${state.selectedSections.length}',
                ),
                const SizedBox(height: 8),
                InfoRowWidget(
                  label: '總元件數',
                  value:
                      '${state.selectedSections.fold(0, (sum, section) => sum + section.items.length)}',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onBrowse,
                icon: const Icon(Icons.preview_outlined),
                label: const Text('表單瀏覽'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPreviewJson,
                icon: const Icon(Icons.data_object_outlined),
                label: const Text('Json 瀏覽'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSaveDraft,
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('表單暫存'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
