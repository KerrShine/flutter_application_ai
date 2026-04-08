import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/widgets/binding_mapping_table_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/widgets/binding_sidebar_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/widgets/binding_summary_panel_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_data_manager_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormDataManagerPage extends StatefulWidget {
  final String formId;

  const FormDataManagerPage({
    super.key,
    required this.formId,
  });

  @override
  State<FormDataManagerPage> createState() => _FormDataManagerPageState();
}

class _FormDataManagerPageState extends State<FormDataManagerPage> {
  late final FormDataManagerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormDataManagerBloc(sl<FormDataManagerService>());
    _bloc.add(InitEvent(widget.formId));
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
          BlocListener<FormDataManagerBloc, FormDataManagerState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FormDataManagerStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state.status ==
                  FormDataManagerStatus.navigateToDataBinding) {
                context.push(
                  RouteName.formDataBindingPage,
                  extra: {
                    'formId': state.navigateFormId,
                    'bindingId': state.navigateBindingId,
                  },
                ).then((_) {
                  if (!context.mounted) {
                    return;
                  }
                  _bloc.add(InitEvent(widget.formId));
                });
                _bloc.add(const CompleteNavigationEvent());
              } else if (state.status ==
                  FormDataManagerStatus.exportJsonPreview) {
                showScrollableMessageDialog(
                  context: context,
                  title: '匯出Json',
                  child: SelectableText(state.exportedJson),
                );
                _bloc.add(const CompleteExportJsonPreviewEvent());
              } else if (state.status ==
                  FormDataManagerStatus.exportApiPreview) {
                showScrollableMessageDialog(
                  context: context,
                  title: '預覽API匯出',
                  child: SelectableText(state.exportedJson),
                );
                _bloc.add(const CompleteExportJsonPreviewEvent());
              }
            },
          ),
        ],
        child: BlocBuilder<FormDataManagerBloc, FormDataManagerState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: colors.shellBackground.withValues(alpha: 0.92),
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.formName.isEmpty ? '表單綁定資料管理' : state.formName),
                    Text(
                      '管理同模板下的多份綁定資料、版本與匯出設定',
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

  Widget _buildBody(BuildContext context, FormDataManagerState state) {
    if (state.status == FormDataManagerStatus.init ||
        state.status == FormDataManagerStatus.loading) {
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
                            onAddBinding: () {
                              _bloc.add(
                                NavigateToDataBindingEvent(state.formId),
                              );
                            },
                            onSelectBinding: (bindingId) {
                              _bloc.add(SelectBindingEvent(bindingId));
                            },
                            onEditBinding: (bindingId) {
                              _bloc.add(
                                NavigateToDataBindingEvent(
                                  state.formId,
                                  bindingId: bindingId,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BindingMappingTableWidget(
                            state: state,
                            onPreviewApiExport: () {
                              _bloc.add(const PreviewApiExportEvent());
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: summaryWidth,
                          child: BindingSummaryPanelWidget(
                            state: state,
                            onExportJson: () {
                              _bloc.add(const ExportJsonEvent());
                            },
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
