import 'package:flutter/material.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/employee/emp_dep/bloc/emp_dep_bloc.dart';
import 'package:flutter_application_ai/page/employee/emp_dep/widgets/emp_dep_department_panel_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_dep/widgets/emp_dep_employee_card_widget.dart';
import 'package:flutter_application_ai/service/emp_dep_service.dart';
import 'package:go_router/go_router.dart';

class EmpDepPage extends StatefulWidget {
  final String initialDepartmentId;
  final String focusedEmployeeId;

  const EmpDepPage({
    super.key,
    this.initialDepartmentId = '',
    this.focusedEmployeeId = '',
  });

  @override
  State<EmpDepPage> createState() => _EmpDepPageState();
}

class _EmpDepPageState extends State<EmpDepPage> {
  late final EmpDepBloc _bloc;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bloc = EmpDepBloc(sl<EmpDepService>());
    _bloc.add(
      InitEvent(
        initialDepartmentId: widget.initialDepartmentId,
        focusedEmployeeId: widget.focusedEmployeeId,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<EmpDepBloc, EmpDepState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<EmpDepBloc, EmpDepState>(
            listenWhen: (previous, current) =>
                previous.exportDialogRequestId !=
                    current.exportDialogRequestId &&
                current.exportJson.isNotEmpty,
            listener: (context, state) {
              _showExportJsonDialog(context, state.exportJson);
            },
          ),
          BlocListener<EmpDepBloc, EmpDepState>(
            listenWhen: (previous, current) =>
                previous.navigateRoute != current.navigateRoute &&
                current.navigateRoute.isNotEmpty,
            listener: (context, state) {
              context.push(state.navigateRoute);
              context.read<EmpDepBloc>().add(const NavigationHandledEvent());
            },
          ),
        ],
        child: BlocBuilder<EmpDepBloc, EmpDepState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('部門綁定'),
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
      title: '部門綁定 JSON',
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

  Widget _buildBody(BuildContext context, EmpDepState state) {
    if (state.status == EmpDepStatus.init ||
        state.status == EmpDepStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasDepartments) {
      return Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              state.message.isEmpty ? '請先前往設計組織樹' : state.message,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF424242),
                height: 1.6,
              ),
            ),
          ),
        ),
      );
    }

    if (_searchController.text != state.employeeKeyword) {
      _searchController.value = TextEditingValue(
        text: state.employeeKeyword,
        selection: TextSelection.collapsed(
          offset: state.employeeKeyword.length,
        ),
      );
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          final isCompact = constraints.maxWidth < 1080;

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopToolbar(context, compact: isNarrow),
                const SizedBox(height: 16),
                Expanded(
                  child: isCompact
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EmpDepDepartmentPanelWidget(
                                departments: state.departments,
                                departmentEmployeeCounts:
                                    state.departmentEmployeeCounts,
                                selectedDepartmentId:
                                    state.selectedDepartmentId,
                                onSelectDepartment: (departmentId) {
                                  context.read<EmpDepBloc>().add(
                                        SelectDepartmentEvent(departmentId),
                                      );
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildBindingWorkspace(
                                context,
                                state,
                                compact: true,
                              ),
                            ],
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 320,
                              child: EmpDepDepartmentPanelWidget(
                                departments: state.departments,
                                departmentEmployeeCounts:
                                    state.departmentEmployeeCounts,
                                selectedDepartmentId:
                                    state.selectedDepartmentId,
                                scrollable: true,
                                onSelectDepartment: (departmentId) {
                                  context.read<EmpDepBloc>().add(
                                        SelectDepartmentEvent(departmentId),
                                      );
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildBindingWorkspace(
                                  context,
                                  state,
                                  compact: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopToolbar(BuildContext context, {required bool compact}) {
    return Row(
      children: [
        const Spacer(),
        if (compact)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '前往代理人設定',
                onPressed: () {
                  context.read<EmpDepBloc>().add(
                        const OpenEmpAgentPageEvent(),
                      );
                },
                icon: const Icon(Icons.swap_horiz_outlined),
              ),
              IconButton(
                tooltip: '匯出 JSON',
                onPressed: () {
                  context.read<EmpDepBloc>().add(
                        const RequestExportJsonEvent(),
                      );
                },
                icon: const Icon(Icons.data_object_outlined),
              ),
            ],
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  context.read<EmpDepBloc>().add(
                        const OpenEmpAgentPageEvent(),
                      );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFBDBDBD)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.swap_horiz_outlined),
                label: const Text('前往代理人設定'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<EmpDepBloc>().add(
                        const RequestExportJsonEvent(),
                      );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFBDBDBD)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.data_object_outlined),
                label: const Text('匯出JSON'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBindingWorkspace(
    BuildContext context,
    EmpDepState state, {
    required bool compact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '全員工 (${state.filteredEmployees.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '顯示全部員工。僅未綁定且啟用中的員工可拖拉到目前部門；點選員工可切換到其所屬部門。',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 16),
              _buildEmployeeFilter(context),
              const SizedBox(height: 16),
              if (state.filteredEmployees.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '沒有符合條件的員工',
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: state.filteredEmployees
                      .map(
                        (employee) => EmpDepEmployeeCardWidget(
                          employee: employee,
                          departmentName: state.departmentDisplayNames[
                                  employee.departmentId] ??
                              '未綁定',
                          isHighlighted:
                              employee.employeeId == state.focusedEmployeeId,
                          draggable: employee.departmentId.isEmpty &&
                              employee.isActive,
                          onTap: () {
                            context.read<EmpDepBloc>().add(
                                  SelectEmployeeEvent(employee.employeeId),
                                );
                          },
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DragTarget<EmployeeModel>(
          onWillAcceptWithDetails: (details) {
            final employee = details.data;
            return state.selectedDepartmentId.isNotEmpty &&
                employee.departmentId.isEmpty &&
                employee.isActive;
          },
          onAcceptWithDetails: (details) {
            context.read<EmpDepBloc>().add(
                  BindEmployeeToDepartmentEvent(
                    employeeId: details.data.employeeId,
                    departmentId: state.selectedDepartmentId,
                  ),
                );
          },
          builder: (context, candidateData, rejectedData) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: candidateData.isNotEmpty
                      ? const Color(0xFF111111)
                      : const Color(0xFFE0E0E0),
                  width: candidateData.isNotEmpty ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedDepartmentDisplayName.isEmpty
                        ? '既有員工'
                        : '${state.selectedDepartmentDisplayName} 既有員工',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '可將下方未綁定且啟用中的職員拖拉到這裡進行綁定。',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF616161),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.selectedDepartmentEmployees.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: compact ? 12 : 72,
                      ),
                      child: Center(
                        child: Text(
                          candidateData.isNotEmpty
                              ? '放開即可綁定到目前部門'
                              : '目前部門尚未綁定任何員工',
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: state.selectedDepartmentEmployees
                          .map(
                            (employee) => EmpDepEmployeeCardWidget(
                              employee: employee,
                              departmentName: state.departmentDisplayNames[
                                      employee.departmentId] ??
                                  '未綁定',
                              isHighlighted: employee.employeeId ==
                                  state.focusedEmployeeId,
                              showManagerStyle: true,
                              showRemoveButton: true,
                              onTap: employee.departmentId.isEmpty
                                  ? null
                                  : () {
                                      context.read<EmpDepBloc>().add(
                                            SelectEmployeeEvent(
                                              employee.employeeId,
                                            ),
                                          );
                                    },
                              onRemove: () {
                                context.read<EmpDepBloc>().add(
                                      RemoveEmployeeFromDepartmentEvent(
                                        employeeId: employee.employeeId,
                                        departmentId:
                                            state.selectedDepartmentId,
                                      ),
                                    );
                              },
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmployeeFilter(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: '員工名稱篩選',
        hintText: '輸入姓名關鍵字',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        context.read<EmpDepBloc>().add(
              SearchEmployeeKeywordChangedEvent(value),
            );
      },
    );
  }
}
