import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/org_design/org_manager/bloc/org_manager_bloc.dart';
import 'package:flutter_application_ai/route/app_router.dart';

class OrgManagerPage extends StatefulWidget {
  const OrgManagerPage({super.key});

  @override
  State<OrgManagerPage> createState() => _OrgManagerPageState();
}

class _OrgManagerPageState extends State<OrgManagerPage> {
  late final OrgManagerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<OrgManagerBloc>();
    _bloc.add(const InitEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _showDeleteOrganizationDialog(
    BuildContext context,
    OrgManagerState state,
  ) async {
    await showMessageDialog(
      context: context,
      title: '確認刪除',
      content: Text('確認刪除「${state.pendingDeleteOrgName}」與其組織樹設定？'),
      rightText: '確認刪除',
      onConfirm: () {
        _bloc.add(const ConfirmDeleteOrganizationEvent());
      },
      onCancel: () {
        _bloc.add(const DismissDeleteOrganizationDialogEvent());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<OrgManagerBloc, OrgManagerState>(
            listenWhen: (previous, current) =>
                previous.deleteDialogRequestId !=
                    current.deleteDialogRequestId &&
                current.pendingDeleteOrgName.isNotEmpty,
            listener: (context, state) {
              _showDeleteOrganizationDialog(context, state);
            },
          ),
          BlocListener<OrgManagerBloc, OrgManagerState>(
            listenWhen: (previous, current) =>
                previous.navigateRoute != current.navigateRoute &&
                current.navigateRoute != null,
            listener: (context, state) {
              if (state.navigateRoute != null) {
                context.go(state.navigateRoute!);
              }
            },
          ),
        ],
        child: BlocBuilder<OrgManagerBloc, OrgManagerState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('編輯組織'),
              ),
              floatingActionButton: state.status == OrgManagerStatus.success &&
                      !state.hasOrganization
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        _bloc.add(const NavigateToOrgDesignConfigEvent());
                      },
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('組織管理'),
                    )
                  : null,
              body: switch (state.status) {
                OrgManagerStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
                OrgManagerStatus.failure => Center(
                    child: Text(state.message.isEmpty ? '載入失敗' : state.message),
                  ),
                _ => state.hasOrganization
                    ? ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: InkWell(
                              onTap: () {
                                _bloc.add(const NavigateToOrgTreeDesignEvent());
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      child: const Icon(
                                        Icons.device_hub_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state.orgName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '目前儲存的組織樹設定，共 ${state.departmentCount} 個部門節點',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          if (state.updatedAt.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '最後更新：${state.updatedAt}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: '刪除組織',
                                      onPressed: () {
                                        _bloc.add(
                                          const RequestDeleteOrganizationEvent(),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_tree_outlined,
                                size: 56,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '目前尚未建立組織',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '請前往組織管理維護部門與組織資料，完成後即可進入組織樹設計。',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () {
                                  context.go(RouteName.orgDesignConfigPage);
                                },
                                icon: const Icon(Icons.settings_outlined),
                                label: const Text('前往組織管理'),
                              ),
                            ],
                          ),
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
