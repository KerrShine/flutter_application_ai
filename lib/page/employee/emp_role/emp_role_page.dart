import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/employee/emp_role/bloc/emp_role_bloc.dart';
import 'package:flutter_application_ai/page/employee/emp_role/widgets/emp_role_header_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_role/widgets/emp_role_list_panel_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_role/widgets/emp_role_next_step_widget.dart';
import 'package:flutter_application_ai/service/emp_role_service.dart';

class EmpRolePage extends StatefulWidget {
  const EmpRolePage({super.key});

  @override
  State<EmpRolePage> createState() => _EmpRolePageState();
}

class _EmpRolePageState extends State<EmpRolePage> {
  late final EmpRoleBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = EmpRoleBloc(sl<EmpRoleService>());
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
          BlocListener<EmpRoleBloc, EmpRoleState>(
            listenWhen: (previous, current) =>
                previous.roleDialogRequestId != current.roleDialogRequestId,
            listener: (context, state) {
              _showRoleDialog(context, state);
            },
          ),
          BlocListener<EmpRoleBloc, EmpRoleState>(
            listenWhen: (previous, current) =>
                previous.infoDialogRequestId != current.infoDialogRequestId &&
                current.infoMessage.isNotEmpty,
            listener: (context, state) {
              showMessageDialog(
                context: context,
                title: '提示',
                rightText: '關閉',
                content: Text(state.infoMessage),
              );
            },
          ),
          BlocListener<EmpRoleBloc, EmpRoleState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<EmpRoleBloc, EmpRoleState>(
            listenWhen: (previous, current) =>
                previous.navigateRoute != current.navigateRoute &&
                current.navigateRoute.isNotEmpty,
            listener: (context, state) {
              context.push(state.navigateRoute);
              context.read<EmpRoleBloc>().add(const NavigationHandledEvent());
            },
          ),
          BlocListener<EmpRoleBloc, EmpRoleState>(
            listenWhen: (previous, current) =>
                previous.exportDialogRequestId !=
                    current.exportDialogRequestId &&
                current.exportJson.isNotEmpty,
            listener: (context, state) {
              _showExportJsonDialog(context, state.exportJson);
            },
          ),
        ],
        child: BlocBuilder<EmpRoleBloc, EmpRoleState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('角色設定'),
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
      title: '角色資料 JSON',
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

  Future<void> _showRoleDialog(
    BuildContext context,
    EmpRoleState state,
  ) async {
    final role = state.dialogRole;
    final codeController = TextEditingController(text: role.roleCode);
    final nameController = TextEditingController(text: role.roleName);
    var roleType = role.roleType;
    var status = role.status;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(state.isEditDialog ? '編輯角色' : '新增角色'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '角色名稱',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: '職務代碼',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: roleType,
                        decoration: const InputDecoration(
                          labelText: '類型',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('管理職')),
                          DropdownMenuItem(value: 0, child: Text('一般職')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            roleType = value ?? 0;
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
                    _bloc.add(const DismissRoleDialogEvent());
                  },
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _bloc.add(
                      ConfirmSaveRoleEvent(
                        roleId: role.roleId,
                        roleCode: codeController.text,
                        roleName: nameController.text,
                        roleType: roleType,
                        status: status,
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

    codeController.dispose();
    nameController.dispose();
  }

  Widget _buildBody(BuildContext context, EmpRoleState state) {
    if (state.status == EmpRoleStatus.init ||
        state.status == EmpRoleStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          EmpRoleHeaderWidget(
            onExportJson: () {
              context.read<EmpRoleBloc>().add(const RequestExportJsonEvent());
            },
            onCreateRole: () {
              context.read<EmpRoleBloc>().add(
                    const OpenCreateRoleDialogEvent(),
                  );
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmpRoleListPanelWidget(
                    roles: state.roles,
                    onEditRole: (role) {
                      context.read<EmpRoleBloc>().add(
                            OpenEditRoleDialogEvent(role.roleId),
                          );
                    },
                  ),
                  const SizedBox(height: 18),
                  EmpRoleNextStepWidget(
                    onPressed: () {
                      context.read<EmpRoleBloc>().add(
                            const OpenEmpInfoPageEvent(),
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
