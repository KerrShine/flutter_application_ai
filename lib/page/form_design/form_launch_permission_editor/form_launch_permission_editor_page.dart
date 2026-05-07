import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission_editor/bloc/form_launch_permission_editor_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission_editor/widgets/editor_form_section_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission_editor/widgets/editor_role_section_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission_editor/widgets/editor_department_section_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission_editor/widgets/editor_options_section_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission_editor/widgets/editor_summary_sidebar_widget.dart';
import 'package:flutter_application_ai/service/form_launch_permission_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormLaunchPermissionEditorPage extends StatefulWidget {
  final List<FormModel> forms;
  final List<EmpRoleModel> roles;
  final List<OrgDepartmentNode> departments;
  final FormLaunchPermissionModel? existingPermission;

  const FormLaunchPermissionEditorPage({
    super.key,
    required this.forms,
    required this.roles,
    required this.departments,
    this.existingPermission,
  });

  @override
  State<FormLaunchPermissionEditorPage> createState() =>
      _FormLaunchPermissionEditorPageState();
}

class _FormLaunchPermissionEditorPageState
    extends State<FormLaunchPermissionEditorPage> {
  late final FormLaunchPermissionEditorBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormLaunchPermissionEditorBloc(sl<FormLaunchPermissionService>());
    _bloc.add(InitEditorEvent(
      forms: widget.forms,
      roles: widget.roles,
      departments: widget.departments,
      existingPermission: widget.existingPermission,
    ));
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
          BlocListener<FormLaunchPermissionEditorBloc,
              FormLaunchPermissionEditorState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<FormLaunchPermissionEditorBloc,
              FormLaunchPermissionEditorState>(
            listenWhen: (previous, current) =>
                current.status == PermissionEditorPageStatus.saved,
            listener: (context, state) {
              Navigator.of(context).pop(true);
            },
          ),
          BlocListener<FormLaunchPermissionEditorBloc,
              FormLaunchPermissionEditorState>(
            listenWhen: (previous, current) =>
                previous.eligiblePreviewRequestId !=
                    current.eligiblePreviewRequestId,
            listener: (context, state) {
              _showEligiblePreviewDialog(context, state);
            },
          ),
        ],
        child: BlocBuilder<FormLaunchPermissionEditorBloc,
            FormLaunchPermissionEditorState>(
          builder: (context, state) {
            final colors =
                Theme.of(context).extension<FormDesignThemeColors>()!;
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(context, state, colors),
              body: _buildBody(context, state, colors),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, FormLaunchPermissionEditorState state,
      FormDesignThemeColors colors) {
    final textTheme = Theme.of(context).textTheme;
    final isEdit = state.isEditMode;

    return AppBar(
      backgroundColor: colors.shellBackground.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEdit ? '編輯發起權限' : '新增發起權限',
            style: textTheme.titleMedium?.copyWith(fontSize: 21),
          ),
          Text(
            '設定表單發起條件：角色、部門與其他限制',
            style: textTheme.bodySmall?.copyWith(
              color: colors.faintText,
              fontSize: 17,
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.visibility, size: 18),
          label: const Text('預覽符合人員'),
          style: OutlinedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 18),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () {
            _bloc.add(const PreviewEligibleEmployeesEvent());
          },
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: state.status == PermissionEditorPageStatus.saving
              ? null
              : () {
                  _bloc.add(const SavePermissionEvent());
                },
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('儲存變更'),
          style: FilledButton.styleFrom(
            textStyle: const TextStyle(fontSize: 18),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBody(
      BuildContext context, FormLaunchPermissionEditorState state,
      FormDesignThemeColors colors) {
    if (state.status == PermissionEditorPageStatus.init) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PermissionEditorPageStatus.saving) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('儲存中...'),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.pageGradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -30,
            child: GlowOrbWidget(color: colors.heroGlow, size: 220),
          ),
          Positioned(
            right: -60,
            bottom: -80,
            child: GlowOrbWidget(
              color: colors.heroGlow.withValues(alpha: 0.18),
              size: 240,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.shellBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.shellBorder),
                boxShadow: [
                  BoxShadow(
                    color: colors.shellShadow,
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: summary sidebar
                    SizedBox(
                      width: 240,
                      child: EditorSummarySidebarWidget(
                        selectedFormName: state.selectedFormName,
                        allowedRoleIds: state.allowedRoleIds,
                        roles: state.roles,
                        allowedDepartmentIds: state.allowedDepartmentIds,
                        departments: state.departments,
                        eligibleEmployees: state.eligibleEmployees,
                        onPreviewEmployees: () {
                          _bloc.add(const PreviewEligibleEmployeesEvent());
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right: editor sections
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Form selection
                          EditorFormSectionWidget(
                            forms: state.forms,
                            selectedFormId: state.selectedFormId,
                            onSelectForm: (formId, formName) {
                              _bloc.add(SelectFormEvent(
                                  formId: formId, formName: formName));
                            },
                          ),
                          const SizedBox(height: 12),

                          // Roles
                          EditorRoleSectionWidget(
                            roles: state.roles,
                            selectedRoleIds: state.allowedRoleIds,
                            onToggleRole: (roleId) {
                              _bloc.add(ToggleRoleEvent(roleId));
                            },
                            onClearAll: () {
                              _bloc.add(const ClearAllRolesEvent());
                            },
                          ),
                          const SizedBox(height: 12),

                          // Departments
                          EditorDepartmentSectionWidget(
                            departments: state.departments,
                            selectedDepartmentIds: state.allowedDepartmentIds,
                            onToggleDepartment: (departmentId) {
                              _bloc.add(ToggleDepartmentEvent(departmentId));
                            },
                            onToggleDepartmentTree: (departmentId) {
                              _bloc.add(
                                  ToggleDepartmentTreeEvent(departmentId));
                            },
                            onSelectAll: () {
                              _bloc.add(const SelectAllDepartmentsEvent());
                            },
                            onClearAll: () {
                              _bloc.add(const ClearAllDepartmentsEvent());
                            },
                          ),
                          const SizedBox(height: 12),

                          // Collapsible options
                          EditorOptionsSectionWidget(
                            requireActiveStatus: state.requireActiveStatus,
                            requireManagerRole: state.requireManagerRole,
                            isEnabled: state.isEnabled,
                            onRequireActiveStatusChanged: (value) {
                              _bloc
                                  .add(UpdateRequireActiveStatusEvent(value));
                            },
                            onRequireManagerRoleChanged: (value) {
                              _bloc
                                  .add(UpdateRequireManagerRoleEvent(value));
                            },
                            onIsEnabledChanged: (value) {
                              _bloc.add(UpdateIsEnabledEvent(value));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEligiblePreviewDialog(
      BuildContext context, FormLaunchPermissionEditorState state) async {
    final employees = state.eligibleEmployees;

    await showScrollableMessageDialog(
      context: context,
      title: '符合發起資格的員工（${employees.length} 人）',
      width: 500,
      rightText: '關閉',
      child: employees.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('沒有符合條件的員工'),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: employees.map((emp) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.person, size: 20),
                  title: Text(emp.employeeName),
                  subtitle: Text(emp.roleName),
                );
              }).toList(),
            ),
    );
  }
}
