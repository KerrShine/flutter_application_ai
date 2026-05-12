import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/bloc/current_employee/current_employee_bloc.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_application/application_sign_off_pending/bloc/application_sign_off_pending_bloc.dart';
import 'package:flutter_application_ai/page/form_application/application_sign_off_pending/widgets/sign_off_pending_empty_state_widget.dart';
import 'package:flutter_application_ai/page/form_application/widgets/application_header_widget.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';

class ApplicationSignOffPendingPage extends StatefulWidget {
  const ApplicationSignOffPendingPage({super.key});

  @override
  State<ApplicationSignOffPendingPage> createState() => _ApplicationSignOffPendingPageState();
}

class _ApplicationSignOffPendingPageState extends State<ApplicationSignOffPendingPage> {
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
        child: BlocBuilder<ApplicationSignOffPendingBloc, ApplicationSignOffPendingState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: const Text('待我簽核')),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ApplicationSignOffPendingState state) {
    final themeColors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final identity = context.watch<CurrentEmployeeBloc>().state;

    return Container(
      color: themeColors.pageBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApplicationHeaderWidget(
            title: '待我簽核',
            currentEmployee: identity.current,
          ),
          const SizedBox(height: 16),
          const Expanded(child: SignOffPendingEmptyStateWidget()),
        ],
      ),
    );
  }
}
