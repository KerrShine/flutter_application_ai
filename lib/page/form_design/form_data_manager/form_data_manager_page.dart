import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/bloc/form_data_manager_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/widgets/form_data_manager_app_bar_title_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/widgets/form_data_manager_body_widget.dart';
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
                  FormDataManagerStatus.confirmDeleteBinding) {
                showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('刪除綁定資料'),
                      content: Text(
                        '確定要刪除「${state.pendingDeleteBindingName}」嗎？此操作會移除這份表單綁定暫存資料。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          child: const Text('刪除'),
                        ),
                      ],
                    );
                  },
                ).then((confirmed) {
                  if (!context.mounted) {
                    return;
                  }

                  if (confirmed == true) {
                    _bloc.add(DeleteBindingEvent(state.pendingDeleteBindingId));
                    return;
                  }

                  _bloc.add(const CompleteDeleteDialogEvent());
                });
              } else if (state.status == FormDataManagerStatus.deleteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                _bloc.add(const CompleteDeleteDialogEvent());
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
                title: FormDataManagerAppBarTitleWidget(
                  formName: state.formName,
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

    return FormDataManagerBodyWidget(
      state: state,
      onAddBinding: () {
        _bloc.add(NavigateToDataBindingEvent(state.formId));
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
      onDeleteBinding: (bindingId) {
        _bloc.add(RequestDeleteBindingEvent(bindingId));
      },
      onPreviewApiExport: () {
        _bloc.add(const PreviewApiExportEvent());
      },
      onExportJson: () {
        _bloc.add(const ExportJsonEvent());
      },
    );
  }
}
