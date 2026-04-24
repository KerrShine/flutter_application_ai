import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/bloc/form_data_binding_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/widgets/binding_execution_body_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';
import 'package:flutter_application_ai/theme/form_design_page_theme.dart';
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
    final baseTheme = Theme.of(context);
    final colors = baseTheme.extension<FormDesignThemeColors>()!;

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
                context.read<FormDataBindingBloc>().add(
                      const CompleteStatusEvent(),
                    );
              } else if (state.status ==
                  FormDataBindingStatus.confirmBindingName) {
                _showBindingNameDialog(context, state.pendingBindingName);
              } else if (state.status ==
                  FormDataBindingStatus.exportJsonPreview) {
                showScrollableMessageDialog(
                  context: context,
                  title: '目前表單 JSON 架構',
                  child: SelectableText(state.exportedJson),
                );
                context.read<FormDataBindingBloc>().add(
                      const CompleteStatusEvent(),
                    );
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
                  context.read<FormDataBindingBloc>().add(
                        InitEvent(
                          state.formId,
                          bindingId: state.bindingId,
                        ),
                      );
                });
                context.read<FormDataBindingBloc>().add(
                      const CompleteNavigationEvent(),
                    );
              } else if (state.status == FormDataBindingStatus.saveSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                context.read<FormDataBindingBloc>().add(
                      const CompleteStatusEvent(),
                    );
              }
            },
          ),
        ],
        child: BlocBuilder<FormDataBindingBloc, FormDataBindingState>(
          builder: (context, state) {
            return Theme(
              data: FormDesignPageTheme.resolve(baseTheme),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: colors.shellBackground.withValues(
                    alpha: 0.92,
                  ),
                  surfaceTintColor: Colors.transparent,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.formName.isEmpty ? '資料綁定執行' : state.formName,
                      ),
                    ],
                  ),
                ),
                body: BindingExecutionBodyWidget(
                  state: state,
                  onSave: () {
                    context.read<FormDataBindingBloc>().add(
                          const RequestSaveDraftEvent(),
                        );
                  },
                  onBindingEnabledChanged: (isEnabled) {
                    context.read<FormDataBindingBloc>().add(
                          UpdateBindingEnabledEvent(isEnabled),
                        );
                  },
                  actionSummaryBuilder: state.actionSummaryForItem,
                  onOpenActionBinding: (sectionId, itemId) {
                    context.read<FormDataBindingBloc>().add(
                          RequestNavigateToActionBindingEvent(itemId),
                        );
                  },
                  onOutputKeyChanged: (sectionId, itemId, outputKey) {
                    context.read<FormDataBindingBloc>().add(
                          UpdateOutputKeyEvent(
                            sectionId: sectionId,
                            itemId: itemId,
                            outputKey: outputKey,
                          ),
                        );
                  },
                  onNullStrategyChanged: (sectionId, itemId, nullStrategy) {
                    context.read<FormDataBindingBloc>().add(
                          UpdateNullStrategyEvent(
                            sectionId: sectionId,
                            itemId: itemId,
                            nullStrategy: nullStrategy,
                          ),
                        );
                  },
                  onCustomDefaultChanged: (sectionId, itemId, value) {
                    context.read<FormDataBindingBloc>().add(
                          UpdateCustomDefaultValueEvent(
                            sectionId: sectionId,
                            itemId: itemId,
                            value: value,
                          ),
                        );
                  },
                  onExportJson: () {
                    context.read<FormDataBindingBloc>().add(
                          const ExportJsonPreviewEvent(),
                        );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showBindingNameDialog(
    BuildContext context,
    String pendingBindingName,
  ) async {
    final controller = TextEditingController(text: pendingBindingName);
    final bindingName = await showDialog<String>(
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
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('儲存'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!context.mounted) {
      return;
    }

    if (bindingName == null) {
      context.read<FormDataBindingBloc>().add(const CompleteStatusEvent());
      return;
    }

    context.read<FormDataBindingBloc>().add(ConfirmSaveDraftEvent(bindingName));
  }
}
