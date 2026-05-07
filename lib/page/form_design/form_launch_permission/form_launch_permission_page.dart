import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission/bloc/form_launch_permission_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission/widgets/permission_header_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission/widgets/permission_list_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_launch_permission_service.dart';
import 'package:flutter_application_ai/theme/form_launch_permission_theme_colors.dart';

class FormLaunchPermissionPage extends StatefulWidget {
  const FormLaunchPermissionPage({super.key});

  @override
  State<FormLaunchPermissionPage> createState() =>
      _FormLaunchPermissionPageState();
}

class _FormLaunchPermissionPageState extends State<FormLaunchPermissionPage> {
  late final FormLaunchPermissionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormLaunchPermissionBloc(sl<FormLaunchPermissionService>());
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
          BlocListener<FormLaunchPermissionBloc, FormLaunchPermissionState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<FormLaunchPermissionBloc, FormLaunchPermissionState>(
            listenWhen: (previous, current) =>
                previous.exportDialogRequestId !=
                    current.exportDialogRequestId &&
                current.exportJson.isNotEmpty,
            listener: (context, state) {
              _showExportJsonDialog(context, state.exportJson);
            },
          ),
        ],
        child: BlocBuilder<FormLaunchPermissionBloc,
            FormLaunchPermissionState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: const Text('表單發起權限設定')),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FormLaunchPermissionState state) {
    final themeColors =
        Theme.of(context).extension<FormLaunchPermissionThemeColors>()!;

    if (state.status == FormLaunchPermissionStatus.init ||
        state.status == FormLaunchPermissionStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: themeColors.pageBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PermissionHeaderWidget(
            onExportJson: () {
              _bloc.add(const RequestExportJsonEvent());
            },
            onCreatePermission: () => _navigateToEditor(context, state),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: PermissionListWidget(
              permissions: state.permissions,
              roles: state.roles,
              departments: state.departments,
              onEdit: (permissionId) {
                final perm = state.permissions.firstWhere(
                  (p) => p.permissionId == permissionId,
                );
                _navigateToEditor(context, state, existingPermission: perm);
              },
              onDelete: (permissionId) {
                _showDeleteConfirmDialog(context, permissionId);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditor(
    BuildContext context,
    FormLaunchPermissionState state, {
    dynamic existingPermission,
  }) async {
    final result = await context.push<bool>(
      RouteName.formLaunchPermissionEditorPage,
      extra: {
        'forms': state.forms,
        'roles': state.roles,
        'departments': state.departments,
        'permission': existingPermission,
      },
    );

    if (result == true) {
      _bloc.add(const InitEvent());
    }
  }

  Future<void> _showDeleteConfirmDialog(
      BuildContext context, String permissionId) async {
    final themeColors =
        Theme.of(context).extension<FormLaunchPermissionThemeColors>()!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除此權限設定嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: themeColors.errorColor),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _bloc.add(DeletePermissionEvent(permissionId));
    }
  }

  Future<void> _showExportJsonDialog(
    BuildContext context,
    String exportJson,
  ) {
    return showScrollableMessageDialog(
      context: context,
      title: '發起權限 JSON',
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
