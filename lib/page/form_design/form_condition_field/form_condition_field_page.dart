import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/enum/condition_compute_function.dart';
import 'package:flutter_application_ai/enum/condition_field_type.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/condition_field_definition.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/bloc/form_condition_field_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_add_prompt_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_definition_card.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_editor_dialog.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_empty_state_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_header_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_no_fields_hint_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_section_header_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_stats_card_widget.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';
import 'package:flutter_application_ai/theme/form_condition_field_theme_colors.dart';

/// 表單條件欄位設定頁。
///
/// 入口：sign_off_editor header chip → push 此頁帶 formId。
/// 一個 form 對應一筆 ConditionFieldDraft，內含多個 ConditionFieldDefinition。
class FormConditionFieldPage extends StatefulWidget {
  final String formId;
  final String formName;

  const FormConditionFieldPage({
    super.key,
    required this.formId,
    this.formName = '',
  });

  @override
  State<FormConditionFieldPage> createState() => _FormConditionFieldPageState();
}

class _FormConditionFieldPageState extends State<FormConditionFieldPage> {
  late final FormConditionFieldBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<FormConditionFieldBloc>();
    _bloc.add(InitConditionFieldEvent(
      formId: widget.formId,
      formName: widget.formName,
    ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<FormConditionFieldBloc, FormConditionFieldState>(
            listenWhen: (previous, current) =>
                previous.message != current.message &&
                current.message.isNotEmpty,
            listener: _onMessageChanged,
          ),
        ],
        child: BlocBuilder<FormConditionFieldBloc, FormConditionFieldState>(
          builder: (context, state) {
            final colors =
                Theme.of(context).extension<FormConditionFieldThemeColors>()!;
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors.pageGradient,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      ConditionFieldHeaderWidget(
                        formName: state.draft.formName,
                        isDirty: state.isDirty,
                        onBack: () => Navigator.of(context).maybePop(),
                        onPreview: state.draft.definitions.isEmpty
                            ? null
                            : () => _showPreview(context, state),
                        onSave: state.status ==
                                    FormConditionFieldStatus.saving ||
                                !state.isDirty
                            ? null
                            : () => context
                                .read<FormConditionFieldBloc>()
                                .add(const SaveConditionDraftEvent()),
                      ),
                      Expanded(child: _buildBody(context, state)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onMessageChanged(
    BuildContext context,
    FormConditionFieldState state,
  ) {
    final isFailure = state.status == FormConditionFieldStatus.failure;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor:
            isFailure ? Theme.of(context).colorScheme.error : null,
      ),
    );
    context
        .read<FormConditionFieldBloc>()
        .add(const DismissConditionMessageEvent());
  }

  Widget _buildBody(BuildContext context, FormConditionFieldState state) {
    if (state.status == FormConditionFieldStatus.loading ||
        state.status == FormConditionFieldStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.availableItems.isEmpty && state.draft.definitions.isEmpty) {
      return const ConditionFieldNoFieldsHintWidget();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConditionFieldStatsCardWidget(
            definitionCount: state.draft.definitions.length,
            availableItemCount: state.availableItems.length,
          ),
          const SizedBox(height: 16),
          ConditionFieldSectionHeaderWidget(
            onAdd: state.availableItems.isEmpty
                ? null
                : () => _onAddDefinition(context, state),
          ),
          const SizedBox(height: 12),
          if (state.draft.definitions.isEmpty)
            const ConditionFieldEmptyStateWidget()
          else
            ...state.draft.definitions.map((def) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ConditionFieldDefinitionCard(
                    definition: def,
                    availableItems: state.availableItems,
                    onEdit: () => _onEditDefinition(context, state, def),
                    onRemove: () =>
                        _onRemoveDefinition(context, def.fieldKey),
                  ),
                )),
          if (state.draft.definitions.isNotEmpty &&
              state.availableItems.isNotEmpty)
            ConditionFieldAddPromptWidget(
              availableItemCount: state.availableItems.length,
              onTap: () => _onAddDefinition(context, state),
            ),
        ],
      ),
    );
  }

  // ---------- Actions ----------

  Future<void> _onAddDefinition(
    BuildContext context,
    FormConditionFieldState state,
  ) async {
    final result = await showConditionFieldEditorDialog(
      context: context,
      availableItems: state.availableItems,
      existingDefinitions: state.draft.definitions,
      service: sl<ConditionFieldService>(),
    );
    if (result != null && context.mounted) {
      context
          .read<FormConditionFieldBloc>()
          .add(AddConditionDefinitionEvent(result.definition));
    }
  }

  Future<void> _onEditDefinition(
    BuildContext context,
    FormConditionFieldState state,
    ConditionFieldDefinition def,
  ) async {
    final result = await showConditionFieldEditorDialog(
      context: context,
      availableItems: state.availableItems,
      existingDefinitions: state.draft.definitions,
      service: sl<ConditionFieldService>(),
      initialDefinition: def,
    );
    if (result != null && context.mounted) {
      context.read<FormConditionFieldBloc>().add(
            UpdateConditionDefinitionEvent(
              result.originalFieldKey,
              result.definition,
            ),
          );
    }
  }

  Future<void> _onRemoveDefinition(
    BuildContext context,
    String fieldKey,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移除條件欄位'),
        content:
            Text('確定要移除 "$fieldKey"？sign_off 中已引用此 fieldKey 的規則將失效。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('移除')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<FormConditionFieldBloc>()
          .add(RemoveConditionDefinitionEvent(fieldKey));
    }
  }

  void _showPreview(BuildContext context, FormConditionFieldState state) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('條件欄位預覽'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('共 ${state.draft.definitions.length} 個定義：'),
                const SizedBox(height: 8),
                for (final def in state.draft.definitions) ...[
                  Text(
                    '• ${def.fieldKey} (${def.outputType.label})',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text('  ${def.label} ← ${def.function.label}'),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('關閉')),
        ],
      ),
    );
  }
}
