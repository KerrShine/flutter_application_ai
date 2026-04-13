import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/bloc/form_data_binding_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/widgets/binding_execution_header_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/widgets/binding_execution_section_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/widgets/binding_execution_summary_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormDataBindingPage extends StatefulWidget {
  final String formId;
  final String bindingId;

  const FormDataBindingPage({
    super.key,
    required this.formId,
    this.bindingId = '',
  });

  @override
  State<FormDataBindingPage> createState() => _FormDataBindingPageState();
}

class _FormDataBindingPageState extends State<FormDataBindingPage> {
  late final FormDataBindingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormDataBindingBloc(sl<FormDataBindingService>());
    _bloc.add(InitEvent(widget.formId, bindingId: widget.bindingId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<FormDataBindingBloc, FormDataBindingState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FormDataBindingStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                _bloc.add(const CompleteStatusEvent());
              } else if (state.status ==
                  FormDataBindingStatus.confirmBindingName) {
                final controller = TextEditingController(
                  text: state.pendingBindingName,
                );
                showDialog<String>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('設定綁定名稱'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: '綁定名稱',
                          hintText: '請輸入這份綁定的名稱',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext)
                                .pop(controller.text.trim());
                          },
                          child: const Text('儲存'),
                        ),
                      ],
                    );
                  },
                ).then((bindingName) {
                  controller.dispose();
                  if (!context.mounted) {
                    return;
                  }

                  if (bindingName == null) {
                    _bloc.add(const CompleteStatusEvent());
                    return;
                  }

                  _bloc.add(ConfirmSaveDraftEvent(bindingName));
                });
              } else if (state.status ==
                  FormDataBindingStatus.exportJsonPreview) {
                showScrollableMessageDialog(
                  context: context,
                  title: '目前表單 JSON 架構',
                  child: SelectableText(state.exportedJson),
                );
                _bloc.add(const CompleteStatusEvent());
              } else if (state.status ==
                  FormDataBindingStatus.navigateToActionBinding) {
                context.push(
                  RouteName.formActionBindingPage,
                  extra: {
                    'formId': state.navigateFormId,
                    'bindingId': state.navigateBindingId,
                    'sourceItemId': state.navigateSourceItemId,
                  },
                ).then((_) {
                  if (!context.mounted) {
                    return;
                  }
                  _bloc.add(
                    InitEvent(
                      state.formId,
                      bindingId: state.bindingId,
                    ),
                  );
                });
                _bloc.add(const CompleteNavigationEvent());
              } else if (state.status == FormDataBindingStatus.saveSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                _bloc.add(const CompleteStatusEvent());
              }
            },
          ),
        ],
        child: BlocBuilder<FormDataBindingBloc, FormDataBindingState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: colors.shellBackground.withValues(alpha: 0.92),
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.formName.isEmpty ? '資料綁定執行' : state.formName),
                  ],
                ),
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FormDataBindingState state) {
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
                      onSave: () {
                        _bloc.add(const RequestSaveDraftEvent());
                      },
                      onBindingEnabledChanged: (isEnabled) {
                        _bloc.add(UpdateBindingEnabledEvent(isEnabled));
                      },
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
                                    ? _buildEmptyState(context)
                                    : SingleChildScrollView(
                                        child: Column(
                                          children: state.draft.sections
                                              .map(
                                                (section) =>
                                                    BindingExecutionSectionWidget(
                                                  section: section,
                                                  fieldErrors:
                                                      state.fieldErrors,
                                                  fieldKeyBuilder: _fieldKey,
                                                  actionSummaryBuilder: (
                                                    itemId,
                                                  ) {
                                                    return _actionSummaryForItem(
                                                      state,
                                                      itemId,
                                                    );
                                                  },
                                                  onOpenActionBinding: (
                                                    sectionId,
                                                    itemId,
                                                  ) {
                                                    _bloc.add(
                                                      RequestNavigateToActionBindingEvent(
                                                        itemId,
                                                      ),
                                                    );
                                                  },
                                                  onOutputKeyChanged: (
                                                    sectionId,
                                                    itemId,
                                                    outputKey,
                                                  ) {
                                                    _bloc.add(
                                                      UpdateOutputKeyEvent(
                                                        sectionId: sectionId,
                                                        itemId: itemId,
                                                        outputKey: outputKey,
                                                      ),
                                                    );
                                                  },
                                                  onNullStrategyChanged: (
                                                    sectionId,
                                                    itemId,
                                                    nullStrategy,
                                                  ) {
                                                    _bloc.add(
                                                      UpdateNullStrategyEvent(
                                                        sectionId: sectionId,
                                                        itemId: itemId,
                                                        nullStrategy:
                                                            nullStrategy,
                                                      ),
                                                    );
                                                  },
                                                  onCustomDefaultChanged: (
                                                    sectionId,
                                                    itemId,
                                                    value,
                                                  ) {
                                                    _bloc.add(
                                                      UpdateCustomDefaultValueEvent(
                                                        sectionId: sectionId,
                                                        itemId: itemId,
                                                        value: value,
                                                      ),
                                                    );
                                                  },
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
                                  fieldKeyBuilder: _fieldKey,
                                  onExportJson: () {
                                    _bloc.add(const ExportJsonPreviewEvent());
                                  },
                                  onSave: () {
                                    _bloc.add(const RequestSaveDraftEvent());
                                  },
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '目前沒有可執行綁定的欄位',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '此表單尚未配置可綁定的 SectionModel 欄位，或欄位型別目前不支援綁定輸出。',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _fieldKey(String sectionId, String itemId) {
    return '$sectionId::$itemId';
  }

  String _actionSummaryForItem(
    FormDataBindingState state,
    String itemId,
  ) {
    final actions = state.draft.actions.where((item) {
      return item.sourceItemId == itemId && item.enabled;
    }).toList();

    if (actions.isEmpty) {
      return '尚未選擇動作';
    }

    return actions.map((item) {
      return '${formActionTriggerDisplayName(item.triggerType.name)} / ${formActionDisplayName(item.actionType.name)}';
    }).join('、');
  }
}
