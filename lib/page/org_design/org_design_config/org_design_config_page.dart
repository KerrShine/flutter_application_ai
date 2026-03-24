import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/org_design/org_design_config/bloc/org_design_config_bloc.dart';
import 'package:flutter_application_ai/page/org_design/org_design_config/widgets/department_form_panel_widget.dart';
import 'package:flutter_application_ai/page/org_design/org_design_config/widgets/department_list_panel_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';

class OrgDesignConfigPage extends StatefulWidget {
  const OrgDesignConfigPage({super.key});

  @override
  State<OrgDesignConfigPage> createState() => _OrgDesignConfigPageState();
}

class _OrgDesignConfigPageState extends State<OrgDesignConfigPage> {
  late final OrgDesignConfigBloc _bloc;
  late final TextEditingController _departmentNameController;
  late final TextEditingController _departmentCodeController;

  @override
  void initState() {
    super.initState();
    _bloc = sl<OrgDesignConfigBloc>();
    _departmentNameController = TextEditingController();
    _departmentCodeController = TextEditingController();
    _bloc.add(const LoadOrgDesignConfigEvent());
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    _departmentCodeController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<OrgDesignConfigBloc, OrgDesignConfigState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                if (state.status == OrgDesignConfigStatus.failure &&
                    state.message.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }

                if (state.status == OrgDesignConfigStatus.saved) {
                  _departmentNameController.text = state.draftDepartmentName;
                  _departmentCodeController.text = state.draftDepartmentCode;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              }),
          BlocListener<OrgDesignConfigBloc, OrgDesignConfigState>(
            listenWhen: (previous, current) =>
                previous.selectedDepartmentId != current.selectedDepartmentId,
            listener: (context, state) {
              _departmentNameController.text = state.draftDepartmentName;
              _departmentCodeController.text = state.draftDepartmentCode;
            },
          ),
          BlocListener<OrgDesignConfigBloc, OrgDesignConfigState>(
            listenWhen: (previous, current) =>
                previous.draftDepartmentName != current.draftDepartmentName &&
                current.selectedDepartmentId.isEmpty &&
                current.draftDepartmentName.isEmpty &&
                current.draftDepartmentCode.isEmpty,
            listener: (context, state) {
              _departmentNameController.text = state.draftDepartmentName;
              _departmentCodeController.text = state.draftDepartmentCode;
            },
          ),
        ],
        child: BlocBuilder<OrgDesignConfigBloc, OrgDesignConfigState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('組織設定'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(RouteName.orgTreeDesignPage),
                ),
              ),
              body: state.status == OrgDesignConfigStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPageContent(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    OrgDesignConfigState state,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 960;

        if (isWideLayout) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: DepartmentListPanelWidget(
                    orgName: state.orgName,
                    departmentNodes: state.departmentNodes,
                    selectedDepartmentId: state.selectedDepartmentId,
                    useInnerScroll: true,
                    onSelectDepartmentNode: (departmentId) {
                      _bloc.add(SelectDepartmentNodeEvent(departmentId));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: ListView(
                    children: [
                      DepartmentFormPanelWidget(
                        departmentNameController: _departmentNameController,
                        departmentCodeController: _departmentCodeController,
                        selectedDepartmentId: state.selectedDepartmentId,
                        draftDepartmentStatus: state.draftDepartmentStatus,
                        onDepartmentNameChanged: (value) {
                          _bloc.add(DraftDepartmentNameChangedEvent(value));
                        },
                        onDepartmentCodeChanged: (value) {
                          _bloc.add(DraftDepartmentCodeChangedEvent(value));
                        },
                        onStatusChanged: (value) {
                          if (value != null) {
                            _bloc.add(DraftDepartmentStatusChangedEvent(value));
                          }
                        },
                        onSaveDepartmentNode: () {
                          _bloc.add(const SaveDepartmentNodeEvent());
                        },
                        onResetDepartmentDraft: () {
                          _bloc.add(const ResetDepartmentDraftEvent());
                        },
                      ),
                      const SizedBox(height: 8)
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DepartmentListPanelWidget(
              orgName: state.orgName,
              departmentNodes: state.departmentNodes,
              selectedDepartmentId: state.selectedDepartmentId,
              onSelectDepartmentNode: (departmentId) {
                _bloc.add(SelectDepartmentNodeEvent(departmentId));
              },
            ),
            const SizedBox(height: 16),
            DepartmentFormPanelWidget(
              departmentNameController: _departmentNameController,
              departmentCodeController: _departmentCodeController,
              selectedDepartmentId: state.selectedDepartmentId,
              draftDepartmentStatus: state.draftDepartmentStatus,
              onDepartmentNameChanged: (value) {
                _bloc.add(DraftDepartmentNameChangedEvent(value));
              },
              onDepartmentCodeChanged: (value) {
                _bloc.add(DraftDepartmentCodeChangedEvent(value));
              },
              onStatusChanged: (value) {
                if (value != null) {
                  _bloc.add(DraftDepartmentStatusChangedEvent(value));
                }
              },
              onSaveDepartmentNode: () {
                _bloc.add(const SaveDepartmentNodeEvent());
              },
              onResetDepartmentDraft: () {
                _bloc.add(const ResetDepartmentDraftEvent());
              },
            ),
            const SizedBox(height: 8)
          ],
        );
      },
    );
  }
}
