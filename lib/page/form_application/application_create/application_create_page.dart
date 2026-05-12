import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/bloc/current_employee/current_employee_bloc.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_application/application_create/bloc/application_create_bloc.dart';
import 'package:flutter_application_ai/page/form_application/application_create/widgets/application_form_grid_widget.dart';
import 'package:flutter_application_ai/page/form_application/application_create/widgets/application_search_bar_widget.dart';
import 'package:flutter_application_ai/page/form_application/widgets/application_header_widget.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';

class ApplicationCreatePage extends StatefulWidget {
  const ApplicationCreatePage({super.key});

  @override
  State<ApplicationCreatePage> createState() => _ApplicationCreatePageState();
}

class _ApplicationCreatePageState extends State<ApplicationCreatePage> {
  late final ApplicationCreateBloc _bloc;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<ApplicationCreateBloc>();
    final identity = context.read<CurrentEmployeeBloc>().state;
    if (identity.hasIdentity) {
      _bloc.add(InitEvent(employeeId: identity.current.employeeId));
    }
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
          BlocListener<CurrentEmployeeBloc, CurrentEmployeeState>(
            listenWhen: (previous, current) =>
                previous.current.employeeId != current.current.employeeId,
            listener: (context, state) {
              if (state.hasIdentity) {
                _bloc.add(InitEvent(employeeId: state.current.employeeId));
              }
            },
          ),
          BlocListener<ApplicationCreateBloc, ApplicationCreateState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<ApplicationCreateBloc, ApplicationCreateState>(
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
                  .read<ApplicationCreateBloc>()
                  .add(const NavigationHandledEvent());
            },
          ),
        ],
        child: BlocBuilder<ApplicationCreateBloc, ApplicationCreateState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: const Text('新增申請')),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ApplicationCreateState state) {
    final themeColors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final identity = context.watch<CurrentEmployeeBloc>().state;

    if (state.status == ApplicationCreateStatus.init ||
        state.status == ApplicationCreateStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ApplicationCreateStatus.failure) {
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
              onPressed: () => _bloc.add(const RefreshEvent()),
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
            title: '新增申請',
            currentEmployee: identity.current,
          ),
          const SizedBox(height: 16),
          ApplicationSearchBarWidget(
            controller: _searchController,
            onChanged: (value) =>
                _bloc.add(UpdateSearchQueryEvent(value)),
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
        ],
      ),
    );
  }
}
