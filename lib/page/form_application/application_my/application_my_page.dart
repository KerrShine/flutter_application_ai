import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/bloc/current_employee/current_employee_bloc.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_application/application_my/bloc/application_my_bloc.dart';
import 'package:flutter_application_ai/page/form_application/application_my/widgets/application_submission_section_widget.dart';
import 'package:flutter_application_ai/page/form_application/widgets/application_header_widget.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

class ApplicationMyPage extends StatefulWidget {
  const ApplicationMyPage({super.key});

  @override
  State<ApplicationMyPage> createState() => _ApplicationMyPageState();
}

class _ApplicationMyPageState extends State<ApplicationMyPage> {
  late final ApplicationMyBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ApplicationMyBloc>();
    final identity = context.read<CurrentEmployeeBloc>().state;
    if (identity.hasIdentity) {
      _bloc.add(InitEvent(employeeId: identity.current.employeeId));
    }
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
          BlocListener<CurrentEmployeeBloc, CurrentEmployeeState>(
            listenWhen: (previous, current) =>
                previous.current.employeeId != current.current.employeeId,
            listener: (context, state) {
              if (state.hasIdentity) {
                _bloc.add(InitEvent(employeeId: state.current.employeeId));
              }
            },
          ),
          BlocListener<ApplicationMyBloc, ApplicationMyState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<ApplicationMyBloc, ApplicationMyState>(
            listenWhen: (previous, current) =>
                previous.exportDialogRequestId !=
                    current.exportDialogRequestId &&
                current.exportJson.isNotEmpty,
            listener: (context, state) {
              _showExportJsonDialog(context, state.exportJson);
            },
          ),
        ],
        child: BlocBuilder<ApplicationMyBloc, ApplicationMyState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  '我的申請',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ApplicationMyState state) {
    final colors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final identity = context.watch<CurrentEmployeeBloc>().state;

    if (state.status == ApplicationMyStatus.init ||
        state.status == ApplicationMyStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ApplicationMyStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: colors.errorColor),
            const SizedBox(height: 16),
            Text(
              state.message,
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

    return Container(
      color: colors.pageBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApplicationHeaderWidget(
            title: '我的申請',
            currentEmployee: identity.current,
            actions: [
              OutlinedButton.icon(
                icon: const Icon(Icons.download, size: 20),
                label: const Text(
                  '匯出申請紀錄',
                  style: TextStyle(fontSize: TextSize.body),
                ),
                onPressed: () =>
                    _bloc.add(const RequestExportJsonEvent()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: state.mySignOffs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 56,
                          color: colors.emptyText,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '目前沒有送出過的申請',
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: TextSize.title,
                            color: colors.emptyText,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: ApplicationSubmissionSectionWidget(
                      signOffs: state.mySignOffs,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExportJsonDialog(
    BuildContext context,
    String exportJson,
  ) {
    return showScrollableMessageDialog(
      context: context,
      title: '申請紀錄 JSON',
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
}
