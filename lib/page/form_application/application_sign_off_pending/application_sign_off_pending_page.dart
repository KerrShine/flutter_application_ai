import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/bloc/current_employee/current_employee_bloc.dart';
import 'package:flutter_application_ai/enum/submission_view_mode.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_application/application_my/widgets/application_submission_section_widget.dart';
import 'package:flutter_application_ai/page/form_application/application_sign_off_pending/bloc/application_sign_off_pending_bloc.dart';
import 'package:flutter_application_ai/page/form_application/application_sign_off_pending/widgets/pending_filter_bar_widget.dart';
import 'package:flutter_application_ai/page/form_application/widgets/application_header_widget.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

class ApplicationSignOffPendingPage extends StatefulWidget {
  const ApplicationSignOffPendingPage({super.key});

  @override
  State<ApplicationSignOffPendingPage> createState() =>
      _ApplicationSignOffPendingPageState();
}

class _ApplicationSignOffPendingPageState
    extends State<ApplicationSignOffPendingPage> {
  late final ApplicationSignOffPendingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ApplicationSignOffPendingBloc>();
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
      child: BlocListener<CurrentEmployeeBloc, CurrentEmployeeState>(
        listenWhen: (previous, current) =>
            previous.current.employeeId != current.current.employeeId,
        listener: (context, state) {
          if (state.hasIdentity) {
            _bloc.add(InitEvent(employeeId: state.current.employeeId));
          }
        },
        child: BlocBuilder<ApplicationSignOffPendingBloc,
            ApplicationSignOffPendingState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  '待我簽核',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: '重整',
                    onPressed: () => _bloc.add(const RefreshEvent()),
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

  Widget _buildBody(
    BuildContext context,
    ApplicationSignOffPendingState state,
  ) {
    final colors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final identity = context.watch<CurrentEmployeeBloc>().state;

    if (state.status == SignOffPendingStatus.init ||
        state.status == SignOffPendingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == SignOffPendingStatus.failure) {
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

    final filtered = state.filteredItems;
    final hasFilterApplied = state.searchQuery.trim().isNotEmpty ||
        state.formNameFilter.trim().isNotEmpty;

    return Container(
      color: colors.pageBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApplicationHeaderWidget(
            title: '待我簽核',
            currentEmployee: identity.current,
          ),
          const SizedBox(height: 20),
          PendingFilterBarWidget(
            searchQuery: state.searchQuery,
            sortOrder: state.sortOrder,
            formNameFilter: state.formNameFilter,
            availableFormNames: state.availableFormNames,
            onSearchChanged: (q) =>
                _bloc.add(UpdateSearchQueryEvent(q)),
            onSortChanged: (order) =>
                _bloc.add(UpdateSortOrderEvent(order)),
            onFormNameFilterChanged: (name) =>
                _bloc.add(UpdateFormNameFilterEvent(name)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
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
                          state.pendingItems.isEmpty
                              ? '目前沒有待您簽核的申請'
                              : hasFilterApplied
                                  ? '沒有符合篩選條件的申請'
                                  : '目前沒有待您簽核的申請',
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
                      signOffs: filtered,
                      title: '待我簽核',
                      mode: SubmissionViewMode.reviewer,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
