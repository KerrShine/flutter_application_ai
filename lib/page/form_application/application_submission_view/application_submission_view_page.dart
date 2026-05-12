import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/leave_sign_off_model.dart';
import 'package:flutter_application_ai/page/form_application/application_submission_view/bloc/application_submission_view_bloc.dart';
import 'package:flutter_application_ai/page/form_application/application_submission_view/widgets/sign_off_status_widget.dart';
import 'package:flutter_application_ai/page/form_application/application_submission_view/widgets/submission_meta_card_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

class ApplicationSubmissionViewPage extends StatefulWidget {
  final String signOffId;

  const ApplicationSubmissionViewPage({super.key, required this.signOffId});

  @override
  State<ApplicationSubmissionViewPage> createState() => _ApplicationSubmissionViewPageState();
}

class _ApplicationSubmissionViewPageState extends State<ApplicationSubmissionViewPage> {
  late final ApplicationSubmissionViewBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ApplicationSubmissionViewBloc>();
    _bloc.add(InitEvent(signOffId: widget.signOffId));
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
          BlocListener<ApplicationSubmissionViewBloc, ApplicationSubmissionViewState>(
            listenWhen: (previous, current) =>
                previous.exportDialogRequestId !=
                    current.exportDialogRequestId &&
                current.exportJson.isNotEmpty,
            listener: (context, state) {
              _showExportJsonDialog(context, state.exportJson);
            },
          ),
        ],
        child: BlocBuilder<ApplicationSubmissionViewBloc, ApplicationSubmissionViewState>(
          builder: (context, state) {
            final signOff = state.signOff;
            final hasData = signOff != null;
            final canEdit = hasData &&
                signOff.status == LeaveSignOffStatus.pending;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  '申請詳情',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                actions: [
                  if (canEdit)
                    IconButton(
                      tooltip: '編輯本筆',
                      onPressed: () => context.go(
                        RouteName.formRunPage,
                        extra: {
                          'formId': signOff.formId,
                          'bindingId': '',
                          'signOffId': signOff.signOffId,
                        },
                      ),
                      icon: const Icon(Icons.edit),
                    ),
                  IconButton(
                    tooltip: '匯出此筆 JSON',
                    onPressed: hasData
                        ? () => _bloc.add(const RequestExportJsonEvent())
                        : null,
                    icon: const Icon(Icons.code),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showExportJsonDialog(
    BuildContext context,
    String exportJson,
  ) {
    return showScrollableMessageDialog(
      context: context,
      title: '此筆申請 JSON（LocalStorage）',
      width: 860,
      rightText: '關閉',
      child: SelectableText(
        exportJson,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: TextSize.body,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ApplicationSubmissionViewState state) {
    final colors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final textTheme = Theme.of(context).textTheme;

    if (state.status == ApplicationSubmissionViewStatus.init ||
        state.status == ApplicationSubmissionViewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ApplicationSubmissionViewStatus.failure ||
        state.signOff == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: colors.errorColor),
            const SizedBox(height: 16),
            Text(
              state.message.isEmpty ? '無法載入此申請' : state.message,
              style: textTheme.titleLarge?.copyWith(
                fontSize: TextSize.title,
                color: colors.errorColor,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => _bloc.add(const RefreshEvent()),
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    final signOff = state.signOff!;
    return Container(
      color: colors.pageBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubmissionMetaCardWidget(signOff: signOff),
            const SizedBox(height: 20),
            SignOffStatusWidget(
              signOff: signOff,
              resolvedChain: state.resolvedChain,
            ),
          ],
        ),
      ),
    );
  }
}
