import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/bloc/sign_off_editor_bloc.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_editor_header_row_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_editor_launch_permission_tab_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_editor_levels_tab_widget.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffEditorPageArgs {
  final List<FormModel> forms;
  final List<FormLaunchPermissionModel> permissions;
  final List<OrgDepartmentNode> departments;
  final List<EmpRoleModel> roles;
  final List<EmployeeModel> employees;
  final SignOffTemplateModel? existingTemplate;

  const SignOffEditorPageArgs({
    required this.forms,
    required this.permissions,
    required this.departments,
    required this.roles,
    required this.employees,
    this.existingTemplate,
  });
}

class SignOffEditorPage extends StatefulWidget {
  final SignOffEditorPageArgs args;

  const SignOffEditorPage({super.key, required this.args});

  @override
  State<SignOffEditorPage> createState() => _SignOffEditorPageState();
}

class _SignOffEditorPageState extends State<SignOffEditorPage>
    with SingleTickerProviderStateMixin {
  late final SignOffEditorBloc _bloc;
  late final TabController _tabController;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _bloc = SignOffEditorBloc(sl<SignOffService>());
    _bloc.add(InitSignOffEditorEvent(
      forms: widget.args.forms,
      permissions: widget.args.permissions,
      departments: widget.args.departments,
      roles: widget.args.roles,
      employees: widget.args.employees,
      existingTemplate: widget.args.existingTemplate,
    ));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transformationController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<SignOffEditorBloc, SignOffEditorState>(
            listenWhen: (prev, curr) =>
                prev.messageRequestId != curr.messageRequestId &&
                curr.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              if (state.status == SignOffEditorStatus.saved) {
                Navigator.of(context).pop(true);
              }
            },
          ),
          BlocListener<SignOffEditorBloc, SignOffEditorState>(
            listenWhen: (prev, curr) =>
                prev.canvasTransformRequestId !=
                curr.canvasTransformRequestId,
            listener: (context, state) {
              _transformationController.value =
                  Matrix4.fromList(state.canvasTransformValues);
            },
          ),
          BlocListener<SignOffEditorBloc, SignOffEditorState>(
            listenWhen: (prev, curr) =>
                prev.exportDialogRequestId != curr.exportDialogRequestId &&
                curr.exportJson.isNotEmpty,
            listener: (context, state) =>
                _showCurrentTemplateJsonDialog(context, state),
          ),
          BlocListener<SignOffEditorBloc, SignOffEditorState>(
            listenWhen: (prev, curr) =>
                prev.navigateRoute != curr.navigateRoute &&
                curr.navigateRoute.isNotEmpty,
            listener: (context, state) async {
              final route = state.navigateRoute;
              final extra = state.navigateExtra;
              final formId = extra['formId'] as String? ?? '';
              final bloc = context.read<SignOffEditorBloc>();
              bloc.add(const NavigationHandledEvent());
              await context.push(route, extra: extra);
              if (!mounted || formId.isEmpty) return;
              bloc
                ..add(RefreshConditionFieldStatusEvent(formId))
                ..add(LoadFormFieldsEvent(formId));
            },
          ),
        ],
        child: BlocBuilder<SignOffEditorBloc, SignOffEditorState>(
          builder: (context, state) {
            final colors =
                Theme.of(context).extension<FormDesignThemeColors>()!;
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor:
                    colors.shellBackground.withValues(alpha: 0.92),
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.template.templateId.isEmpty ? '新增簽核流程' : '編輯簽核流程',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontSize:
                                (Theme.of(context).textTheme.titleLarge?.fontSize ?? 22) + 2,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '從左側拖曳部門到畫布、設定簽核順序與簽核人',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.faintText,
                            fontSize:
                                (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) + 2,
                          ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _bloc.add(const RequestExportJsonEvent()),
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: Text(
                        '匯出 JSON',
                        style: TextStyle(
                          fontSize:
                              (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) + 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilledButton.icon(
                      onPressed: state.status == SignOffEditorStatus.saving
                          ? null
                          : () => _bloc.add(const SaveTemplateEvent()),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        '儲存',
                        style: TextStyle(
                          fontSize:
                              (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) + 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize:
                            (Theme.of(context).textTheme.titleSmall?.fontSize ?? 14) + 2,
                        fontWeight: FontWeight.w700,
                      ),
                  unselectedLabelStyle:
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize:
                                (Theme.of(context).textTheme.titleSmall?.fontSize ?? 14) + 2,
                          ),
                  tabs: const [
                    Tab(icon: Icon(Icons.shield_outlined), text: '發起設定'),
                    Tab(icon: Icon(Icons.account_tree_outlined), text: '簽核級別'),
                  ],
                ),
              ),
              body: state.status == SignOffEditorStatus.init
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: colors.pageGradient,
                        ),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : Container(
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
                            child: GlowOrbWidget(
                                color: colors.heroGlow, size: 220),
                          ),
                          Positioned(
                            right: -60,
                            bottom: -80,
                            child: GlowOrbWidget(
                              color:
                                  colors.heroGlow.withValues(alpha: 0.18),
                              size: 240,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors.shellBackground
                                    .withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: colors.shellBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.shellShadow,
                                    blurRadius: 28,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  SignOffEditorHeaderRowWidget(state: state),
                                  Divider(
                                    height: 1,
                                    color: colors.panelBorder,
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        SignOffEditorLaunchPermissionTabWidget(
                                          permission: state.currentPermission,
                                          departments: state.departments,
                                          formName: state.template.formName,
                                        ),
                                        SignOffEditorLevelsTabWidget(
                                          state: state,
                                          transformationController:
                                              _transformationController,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCurrentTemplateJsonDialog(
    BuildContext context,
    SignOffEditorState state,
  ) {
    return showScrollableMessageDialog(
      context: context,
      title:
          '當前簽核流程資料（${state.template.name.isEmpty ? "未命名" : state.template.name}）',
      width: 860,
      rightText: '關閉',
      child: SelectableText(
        state.exportJson,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}
