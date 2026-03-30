import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/employee/emp_agent/bloc/emp_agent_bloc.dart';
import 'package:flutter_application_ai/page/employee/emp_agent/widgets/emp_agent_agent_section_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_agent/widgets/emp_agent_assignment_list_panel_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_agent/widgets/emp_agent_principal_section_widget.dart';
import 'package:flutter_application_ai/service/emp_agent_service.dart';
import 'package:flutter_application_ai/theme/emp_agent_theme_colors.dart';

class EmpAgentPage extends StatefulWidget {
  const EmpAgentPage({super.key});

  @override
  State<EmpAgentPage> createState() => _EmpAgentPageState();
}

class _EmpAgentPageState extends State<EmpAgentPage> {
  late final EmpAgentBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = EmpAgentBloc(sl<EmpAgentService>());
    _bloc.add(const InitEvent());
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
          BlocListener<EmpAgentBloc, EmpAgentState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
        ],
        child: BlocBuilder<EmpAgentBloc, EmpAgentState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('代理人設定'),
              ),
              body: _buildBody(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(EmpAgentState state) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    if (state.status == EmpAgentStatus.init ||
        state.status == EmpAgentStatus.loading) {
      return ColoredBox(
        color: themeColors.pageBackground,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.hasDepartments) {
      return Container(
        color: themeColors.pageBackground,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 760),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: themeColors.panelBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: themeColors.divider),
            ),
            child: Text(
              '請先建立部門與完整職員資料，才可設定代理人。',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: themeColors.mutedText,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: themeColors.pageBackground,
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1180;

          final principalCard = _buildPanel(
            child: EmpAgentPrincipalSectionWidget(
              departments: state.departments,
              principalDepartmentId: state.principalDepartmentId,
              principalEmployees: state.principalEmployees,
              principalEmployeeId: state.principalEmployeeId,
              selectedPrincipalEmployee: state.selectedPrincipalEmployee,
              onSelectDepartment: (value) {
                context.read<EmpAgentBloc>().add(
                      SelectPrincipalDepartmentEvent(value),
                    );
              },
              onSelectEmployee: (value) {
                context.read<EmpAgentBloc>().add(
                      SelectPrincipalEmployeeEvent(value),
                    );
              },
            ),
          );

          final agentCard = _buildPanel(
            child: EmpAgentAgentSectionWidget(
              departments: state.departments,
              agentDepartmentId: state.agentDepartmentId,
              agentCandidates: state.agentCandidates,
              agentEmployeeId: state.agentEmployeeId,
              selectedAgentEmployee: state.selectedAgentEmployee,
              onSelectDepartment: (value) {
                context.read<EmpAgentBloc>().add(
                      SelectAgentDepartmentEvent(value),
                    );
              },
              onSelectEmployee: (value) {
                context.read<EmpAgentBloc>().add(
                      SelectAgentEmployeeEvent(value),
                    );
              },
              onSubmitAssignment: () {
                context.read<EmpAgentBloc>().add(
                      const SubmitAssignmentEvent(),
                    );
              },
            ),
          );

          final assignmentPanel = EmpAgentAssignmentListPanelWidget(
            assignmentRows: state.assignmentRows,
            onDeleteAssignment: (assignmentId) {
              context.read<EmpAgentBloc>().add(
                    DeleteAssignmentEvent(assignmentId),
                  );
            },
          );

          if (isCompact) {
            return ListView(
              children: [
                principalCard,
                const SizedBox(height: 20),
                agentCard,
                const SizedBox(height: 20),
                SizedBox(
                  height: 560,
                  child: assignmentPanel,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      principalCard,
                      const SizedBox(height: 20),
                      agentCard,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: assignmentPanel,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPanel({required Widget child}) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.panelBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: themeColors.panelShadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
