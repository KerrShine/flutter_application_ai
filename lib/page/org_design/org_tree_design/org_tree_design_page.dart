import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/org_design_config_model.dart';
import 'package:flutter_application_ai/page/org_design/org_tree_design/bloc/org_tree_design_bloc.dart';
import 'package:flutter_application_ai/page/org_design/org_tree_design/widgets/org_tree_canvas_panel_widget.dart';
import 'package:flutter_application_ai/page/org_design/org_tree_design/widgets/org_tree_property_panel_widget.dart';
import 'package:flutter_application_ai/page/org_design/org_tree_design/widgets/org_tree_source_panel_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';

class OrgTreeDesignPage extends StatefulWidget {
  const OrgTreeDesignPage({super.key});

  @override
  State<OrgTreeDesignPage> createState() => _OrgTreeDesignPageState();
}

class _OrgTreeDesignPageState extends State<OrgTreeDesignPage> {
  late final OrgTreeDesignBloc _bloc;
  late final TransformationController _canvasTransformationController;

  @override
  void initState() {
    super.initState();
    _bloc = sl<OrgTreeDesignBloc>();
    _canvasTransformationController = TransformationController();
    _canvasTransformationController.addListener(_handleCanvasTransformChanged);
    _bloc.add(const InitEvent());
  }

  void _handleCanvasTransformChanged() {
    _bloc.add(
      SyncCanvasTransformEvent(
        _canvasTransformationController.value.storage.toList(growable: false),
      ),
    );
  }

  Future<void> _showRemoveCanvasNodeDialog(
    BuildContext context,
    OrgTreeDesignState state,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text(
            '確認刪除「${state.pendingRemovalDepartmentName}」與其所有子節點？',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('確認刪除'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (shouldDelete == true) {
      _bloc.add(RemoveCanvasNodeEvent(state.pendingRemovalDepartmentId));
      return;
    }

    _bloc.add(const DismissRemoveCanvasNodeDialogEvent());
  }

  Future<void> _showSaveOrgNameDialog(
    BuildContext context,
    OrgTreeDesignState state,
  ) async {
    final controller = TextEditingController(text: state.pendingSaveOrgName);

    await showTextInputDialog(
      context: context,
      title: '輸入組織名稱',
      controller: controller,
      labelText: '組織名稱',
      onConfirm: (value) {
        _bloc.add(ConfirmSaveOrgTreeDesignEvent(value));
      },
      onCancel: () {
        _bloc.add(const DismissSaveOrgTreeDesignDialogEvent());
      },
      rightText: '儲存',
    );

    controller.dispose();
  }

  String _buildExportJson(OrgTreeDesignState state) {
    final exportUpdatedAt = state.updatedAt.isEmpty || state.hasUnsavedChanges
        ? DateTime.now().toIso8601String()
        : state.updatedAt;
    final exportModel = OrgDesignConfigModel(
      orgId: state.orgId,
      orgName: state.orgName,
      schemaVersion: state.schemaVersion,
      updatedAt: exportUpdatedAt,
      departmentNodes: List.of(state.availableDepartments),
      treeCanvasNodes: List.of(state.canvasNodes),
    );

    return const JsonEncoder.withIndent('  ').convert(exportModel.toMap());
  }

  Future<void> _showExportJsonDialog(
    BuildContext context,
    OrgTreeDesignState state,
  ) {
    return showScrollableMessageDialog(
      context: context,
      title: '組織圖 JSON',
      width: 860,
      rightText: '關閉',
      child: SelectableText(
        _buildExportJson(state),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _canvasTransformationController
        .removeListener(_handleCanvasTransformChanged);
    _canvasTransformationController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<OrgTreeDesignBloc, OrgTreeDesignState>(
            listenWhen: (previous, current) =>
                previous.canvasTransformRequestId !=
                current.canvasTransformRequestId,
            listener: (context, state) {
              _canvasTransformationController.value =
                  Matrix4.fromList(state.canvasTransformValues);
            },
          ),
          BlocListener<OrgTreeDesignBloc, OrgTreeDesignState>(
            listenWhen: (previous, current) =>
                previous.removeDialogRequestId !=
                    current.removeDialogRequestId &&
                current.pendingRemovalDepartmentId.isNotEmpty,
            listener: (context, state) {
              _showRemoveCanvasNodeDialog(context, state);
            },
          ),
          BlocListener<OrgTreeDesignBloc, OrgTreeDesignState>(
            listenWhen: (previous, current) =>
                previous.saveDialogRequestId != current.saveDialogRequestId,
            listener: (context, state) {
              _showSaveOrgNameDialog(context, state);
            },
          ),
          BlocListener<OrgTreeDesignBloc, OrgTreeDesignState>(
            listenWhen: (previous, current) =>
                previous.noticeId != current.noticeId &&
                current.noticeMessage.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.noticeMessage)),
              );
            },
          ),
        ],
        child: BlocBuilder<OrgTreeDesignBloc, OrgTreeDesignState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('組織樹設計'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(RouteName.orgManagerPage),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilledButton.icon(
                      onPressed: state.hasUnsavedChanges
                          ? () {
                              _bloc.add(const RequestSaveOrgTreeDesignEvent());
                            }
                          : null,
                      icon: state.status == OrgTreeDesignStatus.saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('存檔'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _bloc.add(const ImportSampleOrgTreeDesignEvent());
                      },
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('匯入Json'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showExportJsonDialog(context, state);
                      },
                      icon: const Icon(Icons.data_object_outlined),
                      label: const Text('匯出Json'),
                    ),
                  ),
                ],
              ),
              body: switch (state.status) {
                OrgTreeDesignStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
                OrgTreeDesignStatus.failure => Center(
                    child: Text(state.message.isEmpty ? '載入失敗' : state.message),
                  ),
                _ => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: OrgTreeSourcePanelWidget(
                            orgName: state.orgName,
                            departments: state.availableDepartments,
                            placedDepartmentIds: state.canvasNodes
                                .map((node) => node.departmentId)
                                .toSet(),
                            selectedDepartmentId: state.selectedDepartmentId,
                            onSelectDepartment: (departmentId) {
                              _bloc.add(
                                SelectAvailableDepartmentEvent(departmentId),
                              );
                            },
                            onDragStarted: (departmentId) {
                              _bloc.add(
                                SelectAvailableDepartmentEvent(departmentId),
                              );
                            },
                            onAddOrganization: () {
                              context.go(RouteName.orgDesignConfigPage);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: OrgTreeCanvasPanelWidget(
                            transformationController:
                                _canvasTransformationController,
                            currentScale: state.canvasScale,
                            departments: state.availableDepartments,
                            canvasNodes: state.canvasNodes,
                            selectedDepartmentId: state.selectedDepartmentId,
                            onCenterCanvas: () {
                              _bloc.add(const CenterCanvasEvent());
                            },
                            onViewportChanged: (viewportWidth, viewportHeight) {
                              _bloc.add(
                                UpdateCanvasViewportEvent(
                                  viewportWidth: viewportWidth,
                                  viewportHeight: viewportHeight,
                                ),
                              );
                            },
                            onZoomIn: () {
                              _bloc.add(const ZoomInCanvasEvent());
                            },
                            onZoomOut: () {
                              _bloc.add(const ZoomOutCanvasEvent());
                            },
                            onDropDepartment:
                                (departmentId, offsetDx, offsetDy) {
                              _bloc.add(
                                DropDepartmentToCanvasEvent(
                                  departmentId: departmentId,
                                  offsetDx: offsetDx,
                                  offsetDy: offsetDy,
                                ),
                              );
                            },
                            onSelectNode: (departmentId) {
                              _bloc.add(SelectCanvasNodeEvent(departmentId));
                            },
                            onMoveNode: (departmentId, deltaDx, deltaDy) {
                              _bloc.add(
                                MoveCanvasNodeEvent(
                                  departmentId: departmentId,
                                  deltaDx: deltaDx,
                                  deltaDy: deltaDy,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: OrgTreePropertyPanelWidget(
                            department: state.selectedDepartment,
                            isOnCanvas: state.isSelectedDepartmentOnCanvas,
                            draftParentDepartmentId:
                                state.draftParentDepartmentId,
                            parentDepartments: state.availableParentDepartments,
                            onParentChanged: (value) {
                              _bloc.add(
                                DraftParentDepartmentChangedEvent(value ?? ''),
                              );
                            },
                            onApplyParentDepartment: () {
                              _bloc.add(
                                ApplyParentDepartmentEvent(
                                  state.selectedDepartmentId,
                                ),
                              );
                            },
                            onRemoveCanvasNode: () {
                              _bloc.add(
                                RequestRemoveCanvasNodeEvent(
                                  state.selectedDepartmentId,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              },
            );
          },
        ),
      ),
    );
  }
}
