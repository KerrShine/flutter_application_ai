import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_application_center/bloc/form_application_center_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_application_center/widgets/application_header_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_application_center/widgets/application_search_bar_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_application_center/widgets/application_form_grid_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_application_center/widgets/application_submission_section_widget.dart';
import 'package:flutter_application_ai/service/form_application_service.dart';
import 'package:flutter_application_ai/theme/form_application_center_theme_colors.dart';

class FormApplicationCenterPage extends StatefulWidget {
  final String employeeId;

  const FormApplicationCenterPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<FormApplicationCenterPage> createState() =>
      _FormApplicationCenterPageState();
}

class _FormApplicationCenterPageState extends State<FormApplicationCenterPage> {
  late final FormApplicationCenterBloc _bloc;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = FormApplicationCenterBloc(sl<FormApplicationService>());
    _bloc.add(InitEvent(employeeId: widget.employeeId));
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<FormApplicationCenterBloc, FormApplicationCenterState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<FormApplicationCenterBloc, FormApplicationCenterState>(
            listenWhen: (previous, current) =>
                previous.navigateRoute != current.navigateRoute &&
                current.navigateRoute.isNotEmpty,
            listener: (context, state) {
              context.push(
                state.navigateRoute,
                extra: state.navigateExtra.isNotEmpty
                    ? state.navigateExtra
                    : null,
              );
              context
                  .read<FormApplicationCenterBloc>()
                  .add(const NavigationHandledEvent());
            },
          ),
          BlocListener<FormApplicationCenterBloc, FormApplicationCenterState>(
            listenWhen: (previous, current) =>
                previous.exportDialogRequestId !=
                    current.exportDialogRequestId &&
                current.exportJson.isNotEmpty,
            listener: (context, state) {
              _showExportJsonDialog(context, state.exportJson);
            },
          ),
        ],
        child: BlocBuilder<FormApplicationCenterBloc,
            FormApplicationCenterState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: const Text('申請中心')),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FormApplicationCenterState state) {
    final themeColors =
        Theme.of(context).extension<FormApplicationCenterThemeColors>()!;

    if (state.status == FormApplicationCenterStatus.init ||
        state.status == FormApplicationCenterStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == FormApplicationCenterStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: themeColors.errorColor),
            const SizedBox(height: 16),
            Text(state.message,
                style: TextStyle(fontSize: 16, color: themeColors.errorColor)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                _bloc.add(InitEvent(employeeId: widget.employeeId));
              },
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: themeColors.pageBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApplicationHeaderWidget(
            currentEmployee: state.currentEmployee,
            onExportJson: () {
              _bloc.add(const RequestExportJsonEvent());
            },
          ),
          const SizedBox(height: 16),
          ApplicationSearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              _bloc.add(UpdateSearchQueryEvent(value));
            },
            onClear: () {
              _searchController.clear();
              _bloc.add(const UpdateSearchQueryEvent(''));
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ApplicationFormGridWidget(
              forms: state.filteredForms,
              onSelectForm: (formId, bindingId) {
                _bloc.add(SelectFormToApplyEvent(
                  formId: formId,
                  bindingId: bindingId,
                ));
              },
            ),
          ),
          if (state.mySubmissions.isNotEmpty) ...[
            const SizedBox(height: 24),
            ApplicationSubmissionSectionWidget(
              submissions: state.mySubmissions,
            ),
          ],
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
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}
