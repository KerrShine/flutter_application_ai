import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/enum/sign_off_condition_field_status.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/bloc/sign_off_editor_bloc.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_canvas_panel_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_editor_launch_permission_tab_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_node_property_panel_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_org_source_panel_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/units/sign_off_preview_chain_dialog.dart';
import 'package:flutter_application_ai/route/app_router.dart';
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
                          _showCurrentTemplateJsonDialog(context, state),
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
                                  _buildHeaderRow(context, state, colors),
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
                                        _buildLevelsTab(context, state),
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

  Widget _buildHeaderRow(
    BuildContext context,
    SignOffEditorState state,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colors.headerAccentBackground.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: TextFormField(
              initialValue: state.template.name,
              style: labelStyle,
              decoration: const InputDecoration(
                labelText: '流程名稱',
                isDense: true,
              ),
              onChanged: (value) =>
                  _bloc.add(UpdateTemplateNameEvent(value)),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 240,
            child: DropdownButtonFormField<String>(
              value:
                  state.template.formId.isEmpty ? null : state.template.formId,
              style: labelStyle,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: '對應表單',
                isDense: true,
              ),
              items: state.availableForms.map((f) {
                final summary = state.conditionFieldStatuses[f.id];
                final status =
                    summary?.status ?? SignOffConditionFieldStatus.none;
                return DropdownMenuItem(
                  value: f.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon,
                          size: 14,
                          color:
                              _conditionFieldStatusColor(theme, colors, status)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          f.name,
                          style: labelStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _bloc.add(SelectFormForTemplateEvent(value));
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          if (state.template.formId.isNotEmpty)
            _buildConditionFieldStatusChip(context, state, colors),
          const SizedBox(width: 16),
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              value: state.template.status,
              style: labelStyle,
              decoration: const InputDecoration(
                labelText: '狀態',
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: 'draft', child: Text('草稿', style: labelStyle)),
                DropdownMenuItem(value: 'active', child: Text('啟用中', style: labelStyle)),
                DropdownMenuItem(value: 'disabled', child: Text('已停用', style: labelStyle)),
              ],
              onChanged: (value) {
                if (value != null) {
                  _bloc.add(UpdateTemplateStatusEvent(value));
                }
              },
            ),
          ),
          const Spacer(),
          _buildSimulationControls(context, state, colors),
          const SizedBox(width: 8),
          _buildRulePreviewControls(context, state, colors),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => showSignOffPreviewChainDialog(
              context: context,
              template: state.template,
              employees: state.employees,
              formFields: state.formFields,
              service: sl<SignOffService>(),
            ),
            icon: const Icon(Icons.preview_outlined, size: 16),
            label: Text(
              '預覽簽核鏈',
              style: TextStyle(
                fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.headerChipBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.linear_scale, size: 16, color: colors.headerChipText),
                const SizedBox(width: 4),
                Text(
                  '節點數 ${state.template.canvasNodes.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                    color: colors.headerChipText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _conditionFieldStatusColor(
    ThemeData theme,
    FormDesignThemeColors colors,
    SignOffConditionFieldStatus status,
  ) {
    switch (status) {
      case SignOffConditionFieldStatus.ready:
        return colors.actionSuccess;
      case SignOffConditionFieldStatus.none:
        return theme.colorScheme.error;
    }
  }

  Widget _buildConditionFieldStatusChip(
    BuildContext context,
    SignOffEditorState state,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);
    final summary = state.currentConditionFieldSummary;
    final color = _conditionFieldStatusColor(theme, colors, summary.status);
    final label = summary.status.fullLabel(summary.definitionCount);

    return Tooltip(
      message: '點擊前往表單條件欄位編輯器',
      child: ActionChip(
        avatar: Icon(summary.status.icon, color: color, size: 16),
        label: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 1,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        visualDensity: VisualDensity.compact,
        onPressed: () =>
            _openConditionFieldCenter(context, state),
      ),
    );
  }

  /// 跳轉至 form_condition_field（per-form 條件欄位定義）編輯器。
  ///
  /// 一個 form 對應一筆 ConditionFieldDraft；route 用 Map extra 傳 formId + formName。
  void _openConditionFieldCenter(
      BuildContext context, SignOffEditorState state) {
    final formId = state.template.formId;
    if (formId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先選擇對應表單')),
      );
      return;
    }
    context
        .push(
          RouteName.formConditionFieldPage,
          extra: <String, dynamic>{
            'formId': formId,
            'formName': state.template.formName,
          },
        )
        .then((_) {
      // 返回時刷新該表單的條件欄位狀態，chip 即時更新
      _bloc.add(RefreshConditionFieldStatusEvent(formId));
      _bloc.add(LoadFormFieldsEvent(formId));
    });
  }

  Widget _buildSimulationControls(
    BuildContext context,
    SignOffEditorState state,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
      fontWeight: FontWeight.w700,
      color: colors.headerChipText,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.headerChipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: colors.headerChipText),
          const SizedBox(width: 4),
          Text('過期預覽', style: labelStyle),
          const SizedBox(width: 4),
          Switch.adaptive(
            value: state.simulationMode,
            onChanged: (value) {
              _bloc.add(value
                  ? const EnterSimulationEvent()
                  : const ExitSimulationEvent());
            },
          ),
          if (state.simulationMode) ...[
            const SizedBox(width: 4),
            SizedBox(
              width: 110,
              child: TextFormField(
                key: ValueKey('sim_days_${state.simulationMode}'),
                initialValue: '${state.simulationDaysAgo}',
                keyboardType: TextInputType.number,
                style: labelStyle,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '0',
                  suffixText: '天前',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value.trim()) ?? 0;
                  _bloc.add(UpdateSimulationDaysEvent(parsed));
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRulePreviewControls(
    BuildContext context,
    SignOffEditorState state,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
      fontWeight: FontWeight.w700,
      color: colors.headerChipText,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.headerChipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alt_route, size: 16, color: colors.headerChipText),
          const SizedBox(width: 4),
          Text('規則預覽', style: labelStyle),
          const SizedBox(width: 4),
          Switch.adaptive(
            value: state.rulePreviewMode,
            onChanged: (value) {
              _bloc.add(value
                  ? const EnterRulePreviewEvent()
                  : const ExitRulePreviewEvent());
            },
          ),
          if (state.rulePreviewMode) ...[
            const SizedBox(width: 6),
            if (state.formFieldsLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (state.formFields.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '此表單無可比對欄位',
                  style: labelStyle?.copyWith(color: colors.actionWarning),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final field in state.formFields) ...[
                        SizedBox(
                          width: 160,
                          child: TextFormField(
                            key: ValueKey('preview_${field.outputKey}'),
                            initialValue:
                                state.rulePreviewValues[field.outputKey] ?? '',
                            style: labelStyle,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: field.label,
                              helperText: field.outputKey,
                              helperMaxLines: 1,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            ),
                            onChanged: (value) => _bloc.add(
                                UpdateRulePreviewValueEvent(
                                    field.outputKey, value)),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelsTab(BuildContext context, SignOffEditorState state) {
    final placedDeptIds = state.template.canvasNodes
        .map((n) => n.departmentId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final hasOrigin =
        state.template.canvasNodes.any((n) => n.isApplicantOrigin);

    return Row(
      children: [
        SignOffOrgSourcePanelWidget(
          departments: state.departments,
          placedDepartmentIds: placedDeptIds,
          highlightedId: state.availableHighlightId,
          hasApplicantOrigin: hasOrigin,
          onSelectAvailable: (id) =>
              _bloc.add(SelectAvailableDepartmentEvent(id)),
          onAddApplicantOrigin: () =>
              _bloc.add(const AddApplicantOriginNodeEvent()),
          onAddApplicantSelf: () =>
              _bloc.add(const AddApplicantSelfNodeEvent()),
          onAddApplicantAncestorManager: () =>
              _bloc.add(const AddApplicantAncestorManagerNodeEvent()),
          onAddApplicantManagerAtDepth: (depth) =>
              _bloc.add(AddApplicantManagerAtDepthNodeEvent(depth)),
        ),
        SignOffCanvasPanelWidget(
          nodes: state.template.canvasNodes,
          departments: state.departments,
          selectedNodeId: state.selectedNodeId,
          transformationController: _transformationController,
          currentScale: state.canvasScale,
          showHierarchyConnections: state.showHierarchyConnections,
          simulationStatusByNodeId: state.simulationStatusByNodeId,
          simulationOffsetForNode: state.simulationOffsetDaysFor,
          rulePreviewMode: state.rulePreviewMode,
          rulePreviewActivatedNodeIds: state.activatedNodeIdsByPreview,
          onDropDepartment: (id, dx, dy) =>
              _bloc.add(DropDepartmentToCanvasEvent(id, dx, dy)),
          onSelectNode: (id) => _bloc.add(SelectCanvasNodeEvent(id)),
          onMoveNode: (id, dx, dy) =>
              _bloc.add(MoveCanvasNodeEvent(id, dx, dy)),
          onSyncTransform: (values) =>
              _bloc.add(SyncCanvasTransformEvent(values)),
          onViewportChanged: (w, h) =>
              _bloc.add(UpdateCanvasViewportEvent(w, h)),
          onZoomIn: () => _bloc.add(const ZoomInCanvasEvent()),
          onZoomOut: () => _bloc.add(const ZoomOutCanvasEvent()),
          onCenterCanvas: () => _bloc.add(const CenterCanvasEvent()),
          onToggleHierarchy: () =>
              _bloc.add(const ToggleHierarchyConnectionsEvent()),
        ),
        SignOffNodePropertyPanelWidget(
          selectedNode: state.selectedNode,
          allNodes: state.template.canvasNodes,
          departments: state.departments,
          roles: state.roles,
          employees: state.employees,
          onTypeChanged: (t) => _bloc.add(UpdateNodeTypeEvent(t)),
          onModeChanged: (m) => _bloc.add(UpdateApproverModeEvent(m)),
          onCrossLevelTargetChanged: (id) =>
              _bloc.add(SetCrossLevelTargetEvent(id)),
          onDesignatedRoleChanged: (id) =>
              _bloc.add(SetDesignatedRoleEvent(id)),
          onDesignatedEmployeeChanged: (id) =>
              _bloc.add(SetDesignatedEmployeeEvent(id)),
          onMultiStrategyChanged: (s) =>
              _bloc.add(UpdateMultiStrategyEvent(s)),
          onReturnPolicyChanged: (p) =>
              _bloc.add(UpdateReturnPolicyEvent(p)),
          onSlaDaysChanged: (days) => _bloc.add(UpdateSlaDaysEvent(days)),
          onApplicantAncestorOffsetChanged: (offset) =>
              _bloc.add(UpdateApplicantAncestorOffsetEvent(offset)),
          onApplicantTargetDepthLevelChanged: (depth) =>
              _bloc.add(UpdateApplicantTargetDepthLevelEvent(depth)),
          pathRules: state.template.pathRules,
          formFields: state.formFields,
          onAddPathRule: () => _bloc.add(const AddPathRuleEvent()),
          onRemovePathRule: (id) => _bloc.add(RemovePathRuleEvent(id)),
          onUpdatePathRule: (rule) => _bloc.add(UpdatePathRuleEvent(rule)),
          onMovePathRule: (id, isUp) =>
              _bloc.add(MovePathRuleOrderEvent(id, isUp)),
          onGoToBinding: () => _openConditionFieldCenter(context, state),
          onMoveOrderUp: () {
            if (state.selectedNodeId != null) {
              _bloc.add(MoveNodeOrderUpEvent(state.selectedNodeId!));
            }
          },
          onMoveOrderDown: () {
            if (state.selectedNodeId != null) {
              _bloc.add(MoveNodeOrderDownEvent(state.selectedNodeId!));
            }
          },
          onDelete: () {
            if (state.selectedNodeId != null) {
              _bloc.add(RemoveCanvasNodeEvent(state.selectedNodeId!));
            }
          },
        ),
      ],
    );
  }

  Future<void> _showCurrentTemplateJsonDialog(
    BuildContext context,
    SignOffEditorState state,
  ) {
    final template = state.template;
    final sortedNodes =
        List<SignOffCanvasNode>.from(template.canvasNodes)
          ..sort((a, b) {
            if (a.isApplicantOrigin && !b.isApplicantOrigin) return -1;
            if (!a.isApplicantOrigin && b.isApplicantOrigin) return 1;
            return a.sortOrder.compareTo(b.sortOrder);
          });

    final payload = {
      'snapshot': '簽核流程編輯器當前狀態（未必已儲存）',
      'templateId': template.templateId.isEmpty ? '(尚未儲存)' : template.templateId,
      'formId': template.formId,
      'formName': template.formName,
      'permissionId':
          template.permissionId.isEmpty ? '(無對應權限)' : template.permissionId,
      'name': template.name,
      'status': template.status,
      'version': template.version,
      'createdAt': template.createdAt.isEmpty ? '(尚未儲存)' : template.createdAt,
      'updatedAt': template.updatedAt.isEmpty ? '(尚未儲存)' : template.updatedAt,
      'totalNodes': sortedNodes.length,
      'approverNodeCount':
          sortedNodes.where((n) => !n.isApplicantOrigin).length,
      'hasApplicantOrigin':
          sortedNodes.any((n) => n.isApplicantOrigin),
      'canvasNodes': sortedNodes.map((n) => n.toMap()).toList(),
      'canvasTransformValues': template.canvasTransform,
    };

    final json = const JsonEncoder.withIndent('  ').convert(payload);

    return showScrollableMessageDialog(
      context: context,
      title: '當前簽核流程資料（${template.name.isEmpty ? "未命名" : template.name}）',
      width: 860,
      rightText: '關閉',
      child: SelectableText(
        json,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}
