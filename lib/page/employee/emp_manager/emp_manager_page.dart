import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/bloc/emp_manager_bloc.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/widgets/emp_manager_feature_entry_card_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/widgets/emp_manager_section_title_widget.dart';
import 'package:flutter_application_ai/service/emp_manager_service.dart';

class EmpManagerPage extends StatefulWidget {
  const EmpManagerPage({super.key});

  @override
  State<EmpManagerPage> createState() => _EmpManagerPageState();
}

class _EmpManagerPageState extends State<EmpManagerPage> {
  late final EmpManagerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = EmpManagerBloc(sl<EmpManagerService>());
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
          BlocListener<EmpManagerBloc, EmpManagerState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == EmpManagerStatus.failure &&
                  state.message.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          BlocListener<EmpManagerBloc, EmpManagerState>(
            listenWhen: (previous, current) =>
                previous.navigateRoute != current.navigateRoute &&
                current.navigateRoute.isNotEmpty,
            listener: (context, state) {
              context.push(state.navigateRoute);
              context
                  .read<EmpManagerBloc>()
                  .add(const NavigationHandledEvent());
            },
          ),
        ],
        child: BlocBuilder<EmpManagerBloc, EmpManagerState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('職員設定'),
                actions: [
                  IconButton(
                    tooltip: '教學頁',
                    onPressed: () {
                      context.read<EmpManagerBloc>().add(
                            const OpenGuidePageEvent(),
                          );
                    },
                    icon: const Icon(Icons.school_outlined),
                  ),
                ],
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, EmpManagerState state) {
    if (state.status == EmpManagerStatus.init ||
        state.status == EmpManagerStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 1100;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EmpManagerSectionTitleWidget(
                title: '功能入口',
                subtitle: '選擇欲進入的職員管理功能。',
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: isWideLayout ? 2 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isWideLayout ? 2.3 : 2.0,
                children: [
                  EmpManagerFeatureEntryCardWidget(
                    title: '角色設定',
                    description: '管理角色類型、角色代碼、角色名稱與是否為管理職。',
                    icon: Icons.badge_outlined,
                    onTap: () {
                      context.read<EmpManagerBloc>().add(
                            const OpenEmpRolePageEvent(),
                          );
                    },
                  ),
                  EmpManagerFeatureEntryCardWidget(
                    title: '職員資料',
                    description: '維護工號、姓名、帳號、狀態與所屬部門。',
                    icon: Icons.people_alt_outlined,
                    onTap: () {
                      context.read<EmpManagerBloc>().add(
                            const OpenEmpInfoPageEvent(),
                          );
                    },
                  ),
                  EmpManagerFeatureEntryCardWidget(
                    title: '部門綁定',
                    description: '職員與組織部門關聯，依組織架構資料進行選擇。',
                    icon: Icons.account_tree_outlined,
                    onTap: () {
                      context.read<EmpManagerBloc>().add(
                            const OpenEmpDepPageEvent(),
                          );
                    },
                  ),
                  EmpManagerFeatureEntryCardWidget(
                    title: '代理人設定',
                    description: '設定代理開始與結束時間，並限制不可選擇離職職員。',
                    icon: Icons.swap_horiz_outlined,
                    onTap: () {
                      context.read<EmpManagerBloc>().add(
                            const OpenEmpAgentPageEvent(),
                          );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
