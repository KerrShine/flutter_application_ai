import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/page/employee/emp_info/bloc/emp_info_bloc.dart';
import 'package:flutter_application_ai/page/employee/emp_info/widgets/emp_info_header_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_info/widgets/emp_info_list_panel_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_info/widgets/emp_info_search_bar_widget.dart';
import 'package:flutter_application_ai/service/emp_info_service.dart';

class EmpInfoPage extends StatefulWidget {
  const EmpInfoPage({super.key});

  @override
  State<EmpInfoPage> createState() => _EmpInfoPageState();
}

class _EmpInfoPageState extends State<EmpInfoPage> {
  late final EmpInfoBloc _bloc;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bloc = EmpInfoBloc(sl<EmpInfoService>());
    _bloc.add(const InitEvent());
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
          BlocListener<EmpInfoBloc, EmpInfoState>(
            listenWhen: (previous, current) =>
                previous.employeeDialogRequestId !=
                current.employeeDialogRequestId,
            listener: (context, state) {
              _showCreateEmployeeDialog(context, state);
            },
          ),
          BlocListener<EmpInfoBloc, EmpInfoState>(
            listenWhen: (previous, current) =>
                previous.deleteDialogRequestId != current.deleteDialogRequestId,
            listener: (context, state) {
              _showDeleteEmployeeDialog(context, state);
            },
          ),
          BlocListener<EmpInfoBloc, EmpInfoState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<EmpInfoBloc, EmpInfoState>(
            listenWhen: (previous, current) =>
                previous.navigateRoute != current.navigateRoute &&
                current.navigateRoute.isNotEmpty,
            listener: (context, state) {
              context.push(state.navigateRoute);
              context.read<EmpInfoBloc>().add(const NavigationHandledEvent());
            },
          ),
        ],
        child: BlocBuilder<EmpInfoBloc, EmpInfoState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('職員資料'),
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateEmployeeDialog(
    BuildContext context,
    EmpInfoState state,
  ) async {
    final employee = state.dialogEmployee;
    final employeeCodeController =
        TextEditingController(text: employee.employeeCode);
    final employeeNameController =
        TextEditingController(text: employee.employeeName);
    final accountController = TextEditingController(text: employee.account);
    final hireDateController = TextEditingController(text: employee.hireDate);
    final leaveDateController = TextEditingController(text: employee.leaveDate);
    var status = employee.status;
    var departmentId = employee.departmentId;
    String? roleId = employee.roleId.isEmpty ? null : employee.roleId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(state.isEditDialog ? '編輯職員' : '新增職員'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: employeeCodeController,
                        decoration: const InputDecoration(
                          labelText: '工號',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: employeeNameController,
                        decoration: const InputDecoration(
                          labelText: '姓名',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: accountController,
                        decoration: const InputDecoration(
                          labelText: '帳號',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: hireDateController,
                        decoration: const InputDecoration(
                          labelText: '入職日期',
                          hintText: 'YYYY-MM-DD',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: leaveDateController,
                        decoration: const InputDecoration(
                          labelText: '離職日期',
                          hintText: 'YYYY-MM-DD，可留空',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: roleId,
                        decoration: const InputDecoration(
                          labelText: '角色',
                          border: OutlineInputBorder(),
                        ),
                        items: state.roles
                            .map(
                              (role) => DropdownMenuItem<String>(
                                value: role.roleId,
                                child: Text(_resolveRoleDisplayName(role)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            roleId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: departmentId,
                        decoration: const InputDecoration(
                          labelText: '部門代碼',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('待指定'),
                          ),
                          ...state.departments.map(
                            (department) => DropdownMenuItem<String>(
                              value: department.departmentId,
                              child: Text(
                                '${department.departmentCode} - ${department.name}',
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            departmentId = value ?? departmentId;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: '狀態',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('啟用')),
                          DropdownMenuItem(value: 0, child: Text('停用')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            status = value ?? 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _bloc.add(const DismissEmployeeDialogEvent());
                  },
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _bloc.add(
                      ConfirmSaveEmployeeEvent(
                        employeeId: employee.employeeId,
                        employeeCode: employeeCodeController.text,
                        employeeName: employeeNameController.text,
                        account: accountController.text,
                        departmentId: departmentId,
                        roleId: roleId ?? '',
                        status: status,
                        hireDate: hireDateController.text,
                        leaveDate: leaveDateController.text,
                      ),
                    );
                  },
                  child: const Text('儲存'),
                ),
              ],
            );
          },
        );
      },
    );

    employeeCodeController.dispose();
    employeeNameController.dispose();
    accountController.dispose();
    hireDateController.dispose();
    leaveDateController.dispose();
  }

  Future<void> _showDeleteEmployeeDialog(
    BuildContext context,
    EmpInfoState state,
  ) async {
    final employee = state.deleteTargetEmployee;
    if (employee.employeeId.isEmpty) {
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('確定要刪除職員「${employee.employeeName}」嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
              ),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      _bloc.add(ConfirmDeleteEmployeeEvent(employee.employeeId));
      return;
    }

    _bloc.add(const DismissDeleteEmployeeDialogEvent());
  }

  Widget _buildBody(BuildContext context, EmpInfoState state) {
    if (state.status == EmpInfoStatus.init ||
        state.status == EmpInfoStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text != state.keyword) {
      _searchController.value = TextEditingValue(
        text: state.keyword,
        selection: TextSelection.collapsed(offset: state.keyword.length),
      );
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          EmpInfoHeaderWidget(
            onCreateEmployee: () {
              context.read<EmpInfoBloc>().add(
                    const OpenCreateEmployeeDialogEvent(),
                  );
            },
          ),
          const SizedBox(height: 20),
          EmpInfoSearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              context.read<EmpInfoBloc>().add(
                    SearchKeywordChangedEvent(value),
                  );
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: EmpInfoListPanelWidget(
                employees: state.filteredEmployees,
                departments: state.departments,
                onEditEmployee: (employee) {
                  context.read<EmpInfoBloc>().add(
                        OpenEditEmployeeDialogEvent(employee.employeeId),
                      );
                },
                onDeleteEmployee: (employee) {
                  context.read<EmpInfoBloc>().add(
                        OpenDeleteEmployeeDialogEvent(employee.employeeId),
                      );
                },
                onOpenDepartmentBinding: (employee) {
                  context.read<EmpInfoBloc>().add(
                        OpenEmployeeDepartmentBindingPageEvent(
                          employeeId: employee.employeeId,
                          departmentId: employee.departmentId,
                        ),
                      );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                context.read<EmpInfoBloc>().add(const OpenEmpDepPageEvent());
              },
              child: const Text('部門綁定'),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveRoleDisplayName(EmpRoleModel role) {
    if (role.roleCode.isEmpty) {
      return role.roleName;
    }

    return '${role.roleCode} - ${role.roleName}';
  }
}
