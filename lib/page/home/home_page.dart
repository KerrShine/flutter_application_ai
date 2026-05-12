import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/bloc/current_employee/current_employee_bloc.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/home/bloc/home_bloc.dart';
import 'package:flutter_application_ai/page/home/widgets/identity_card_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';

class HomePage extends StatefulWidget {
  final Widget child;
  const HomePage({super.key, required this.child});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _bloc;
  late final CurrentEmployeeBloc _identityBloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<HomeBloc>();
    _identityBloc = sl<CurrentEmployeeBloc>()..add(const LoadInitialEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    _identityBloc.close();
    super.dispose();
  }

  /// 取得目前的路由路徑，用來判斷 Drawer 選單狀態
  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = _currentPath(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>.value(value: _bloc),
        BlocProvider<CurrentEmployeeBloc>.value(value: _identityBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeBloc, HomeState>(
            listenWhen: (previous, current) =>
                previous.navigateRoute != current.navigateRoute &&
                current.navigateRoute != null,
            listener: (context, state) {
              if (state.navigateRoute != null) {
                context.go(state.navigateRoute!);
              }
            },
          ),
          BlocListener<CurrentEmployeeBloc, CurrentEmployeeState>(
            listenWhen: (previous, current) =>
                previous.message != current.message && current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context
                  .read<CurrentEmployeeBloc>()
                  .add(const DismissMessageEvent());
            },
          ),
        ],
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: GestureDetector(
                  onTap: () {
                    context.go(RouteName.mainPage);
                  },
                  child: const Text('Home'),
                ),
              ),
              body: widget.child,
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const IdentityCardWidget(),
                    // 第一層：WEB管理系統
                    ExpansionTile(
                      initiallyExpanded: currentPath ==
                              RouteName.formSectionDesignPage ||
                          currentPath.startsWith(RouteName.formManagePage) ||
                          currentPath == RouteName.orgManagerPage ||
                          currentPath.startsWith(RouteName.empManagerPage),
                      leading: const Icon(Icons.web),
                      title: const Text('簽核管理系統'),
                      children: [
                        // 第二層：表單管理
                        ExpansionTile(
                          initiallyExpanded:
                              currentPath.startsWith(RouteName.formManagePage),
                          title: const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text('表單管理'),
                          ),
                          children: [
                            // 第三層：表單管理 ( Form Manage List )
                            ListTile(
                              selected: currentPath
                                  .startsWith(RouteName.formManagePage),
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('表單編輯'),
                              onTap: () {
                                Navigator.pop(context); // 關閉 Drawer
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.formManagePage));
                              },
                            ),
                            ListTile(
                              selected: currentPath ==
                                      RouteName.formSelectPage ||
                                  currentPath == RouteName.formDataManagerPage,
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('綁定資料管理'),
                              onTap: () {
                                Navigator.pop(context); // 關閉 Drawer
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.formSelectPage));
                              },
                            ),
                            // 第三層：權限設定
                            ListTile(
                              selected: currentPath ==
                                  RouteName.formLaunchPermissionPage,
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('表單權限設定'),
                              onTap: () {
                                Navigator.pop(context); // 關閉 Drawer
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.formLaunchPermissionPage));
                              },
                            ),
                          ],
                        ),
                        // 第二層：基本資料
                        ExpansionTile(
                          initiallyExpanded: currentPath ==
                                  RouteName.orgManagerPage ||
                              currentPath.startsWith(RouteName.empManagerPage),
                          title: const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text('基本資料'),
                          ),
                          children: [
                            ListTile(
                              selected: currentPath == RouteName.orgManagerPage,
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('組織架構管理'),
                              onTap: () {
                                Navigator.pop(context);
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.orgManagerPage));
                              },
                            ),
                            ListTile(
                              selected: currentPath
                                  .startsWith(RouteName.empManagerPage),
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('職員設定'),
                              onTap: () {
                                Navigator.pop(context);
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.empManagerPage));
                              },
                            ),
                          ],
                        ),
                        // 第二層：簽核設定
                        ExpansionTile(
                          initiallyExpanded: currentPath
                              .startsWith(RouteName.signOffManagerPage),
                          title: const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text('簽核設定'),
                          ),
                          children: [
                            ListTile(
                              selected:
                                  currentPath == RouteName.signOffManagerPage,
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('簽核流程'),
                              onTap: () {
                                Navigator.pop(context);
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.signOffManagerPage));
                              },
                            ),
                          ],
                        ),
                        // 第二層：待辦事項
                        ExpansionTile(
                          initiallyExpanded: currentPath ==
                                  RouteName.applicationCreatePage ||
                              currentPath == RouteName.myApplicationPage ||
                              currentPath == RouteName.signOffPendingPage,
                          title: const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text('待辦事項'),
                          ),
                          children: [
                            ListTile(
                              selected: currentPath ==
                                  RouteName.applicationCreatePage,
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('新增申請'),
                              onTap: () {
                                Navigator.pop(context);
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.applicationCreatePage));
                              },
                            ),
                            ListTile(
                              selected: currentPath ==
                                  RouteName.myApplicationPage,
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('我的申請'),
                              onTap: () {
                                Navigator.pop(context);
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.myApplicationPage));
                              },
                            ),
                            ListTile(
                              selected: currentPath ==
                                  RouteName.signOffPendingPage,
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('待我簽核'),
                              onTap: () {
                                Navigator.pop(context);
                                _bloc.add(const HomeNavigateEvent(
                                    RouteName.signOffPendingPage));
                              },
                            ),
                          ],
                        ),
                        // 第二層：管理資料
                        ExpansionTile(
                          title: const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text('歷史查詢'),
                          ),
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 48.0),
                              title: const Text('項目'),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        // 登出
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 32.0),
                          leading: const Icon(Icons.logout),
                          title: const Text('登出'),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('登出'),
                                content: const Text('確定要登出嗎？'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('取消'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: const Text('登出'),
                                  ),
                                ],
                              ),
                            ).then((confirmed) {
                              if (confirmed == true && context.mounted) {
                                context.go(RouteName.loginPage);
                              }
                            });
                          },
                        ),
                      ],
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
}
