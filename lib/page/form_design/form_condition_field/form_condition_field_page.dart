import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/bloc/form_condition_field_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_definition_card.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/widgets/condition_field_editor_dialog.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 表單條件欄位設定頁。
///
/// 入口：sign_off_editor header chip → push 此頁帶 formId。
/// 一個 form 對應一筆 ConditionFieldDraft，內含多個 ConditionFieldDefinition。
class FormConditionFieldPage extends StatelessWidget {
  final String formId;
  final String formName;

  const FormConditionFieldPage({
    super.key,
    required this.formId,
    this.formName = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormConditionFieldBloc>(
      create: (_) => sl<FormConditionFieldBloc>()
        ..add(InitConditionFieldEvent(formId: formId, formName: formName)),
      child: const _FormConditionFieldView(),
    );
  }
}

class _FormConditionFieldView extends StatelessWidget {
  const _FormConditionFieldView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FormConditionFieldBloc, FormConditionFieldState>(
      listener: (context, state) {
        if (state.message.isNotEmpty &&
            state.status != FormConditionFieldStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context
              .read<FormConditionFieldBloc>()
              .add(const DismissConditionMessageEvent());
        }
        if (state.status == FormConditionFieldStatus.failure &&
            state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context
              .read<FormConditionFieldBloc>()
              .add(const DismissConditionMessageEvent());
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(state.draft.formName.isEmpty
                ? '表單條件欄位'
                : '表單條件欄位 — ${state.draft.formName}'),
            actions: [
              if (state.isDirty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      '尚未儲存',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              TextButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: const Text('儲存'),
                onPressed: state.status == FormConditionFieldStatus.saving ||
                        !state.isDirty
                    ? null
                    : () => context
                        .read<FormConditionFieldBloc>()
                        .add(const SaveConditionDraftEvent()),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(context, state),
          floatingActionButton: state.status == FormConditionFieldStatus.ready
              ? FloatingActionButton.extended(
                  icon: const Icon(Icons.add),
                  label: const Text('新增條件欄位'),
                  onPressed: () => _onAddDefinition(context, state),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FormConditionFieldState state) {
    if (state.status == FormConditionFieldStatus.loading ||
        state.status == FormConditionFieldStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.availableItems.isEmpty &&
        state.draft.definitions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            '此表單尚未設計任何可作為條件來源的欄位。\n請先到表單設計加入欄位後再回此處設定條件欄位。',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, state),
          const SizedBox(height: 12),
          Expanded(
            child: state.draft.definitions.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    itemCount: state.draft.definitions.length,
                    itemBuilder: (ctx, index) {
                      final def = state.draft.definitions[index];
                      return ConditionFieldDefinitionCard(
                        definition: def,
                        availableItems: state.availableItems,
                        onEdit: () =>
                            _onEditDefinition(context, state, def),
                        onRemove: () => _onRemoveDefinition(
                            context, def.fieldKey),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FormConditionFieldState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.functions, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已定義條件欄位 ${state.draft.definitions.length} 個',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '可用表單欄位 ${state.availableItems.length} 個 · 條件欄位獨立於表單提交設定，由 sign_off path rule 直接消費。',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.emptyStateBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.emptyStateBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.functions,
                size: 48, color: colors.emptyStateIconColor),
            const SizedBox(height: 12),
            Text(
              '尚未定義任何條件欄位',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '點右下「+ 新增條件欄位」開始；'
              '可使用 Direct / DateDiff / Sum / Concat 4 種函式組合表單欄位。',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
    dynamic def,
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
        content: Text('確定要移除 "$fieldKey"？sign_off 中已引用此 fieldKey 的規則將失效。'),
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
}
