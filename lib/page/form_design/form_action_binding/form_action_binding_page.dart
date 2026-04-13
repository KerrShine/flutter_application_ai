import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/bloc/form_action_binding_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/widgets/action_binding_inspector_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/widgets/action_binding_planner_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/widgets/action_binding_source_list_widget.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormActionBindingPage extends StatefulWidget {
  final String formId;
  final String bindingId;
  final String initialSourceItemId;

  const FormActionBindingPage({
    super.key,
    required this.formId,
    this.bindingId = '',
    this.initialSourceItemId = '',
  });

  @override
  State<FormActionBindingPage> createState() => _FormActionBindingPageState();
}

class _FormActionBindingPageState extends State<FormActionBindingPage> {
  late final FormActionBindingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormActionBindingBloc(sl<FormActionBindingService>());
    _bloc.add(
      InitEvent(
        widget.formId,
        bindingId: widget.bindingId,
        initialSourceItemId: widget.initialSourceItemId,
      ),
    );
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
          BlocListener<FormActionBindingBloc, FormActionBindingState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FormActionBindingStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                _bloc.add(const CompleteStatusEvent());
              } else if (state.status == FormActionBindingStatus.saveSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                _bloc.add(const CompleteStatusEvent());
              } else if (state.status ==
                  FormActionBindingStatus.exportPreview) {
                showScrollableMessageDialog(
                  context: context,
                  title: '動作設定匯出預覽',
                  child: SelectableText(
                    state.previewJson.isEmpty ? '{}' : state.previewJson,
                  ),
                );
                _bloc.add(const CompleteStatusEvent());
              }
            },
          ),
        ],
        child: BlocBuilder<FormActionBindingBloc, FormActionBindingState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: colors.shellBackground.withValues(alpha: 0.92),
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.formName.isEmpty ? '動作綁定設定' : state.formName),
                    Text(
                      state.bindingName.isEmpty
                          ? '按鈕 / 下拉選單 互動設定'
                          : state.bindingName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.faintText,
                          ),
                    ),
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

  Widget _buildBody(BuildContext context, FormActionBindingState state) {
    if (state.status == FormActionBindingStatus.init ||
        state.status == FormActionBindingStatus.loading) {
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: ActionBindingSourceListWidget(
                        state: state,
                        onSelectSourceItem: (itemId) {
                          _bloc.add(SelectSourceItemEvent(itemId));
                        },
                        onSearchKeywordChanged: (keyword) {
                          _bloc.add(UpdateSearchKeywordEvent(keyword));
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ActionBindingPlannerWidget(
                        state: state,
                        onSelectAction: (action) {
                          _bloc.add(SelectActionEvent(action));
                        },
                        onSelectTrigger: (trigger) {
                          _bloc.add(SelectTriggerEvent(trigger));
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 280,
                      child: ActionBindingInspectorWidget(
                        state: state,
                        isSaving:
                            state.status == FormActionBindingStatus.saving,
                        onExportPreview: () {
                          _bloc.add(const RequestExportPreviewEvent());
                        },
                        onSaveSettings: () {
                          _bloc.add(const SaveActionSettingsEvent());
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
