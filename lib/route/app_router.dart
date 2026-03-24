import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/page/login/login_page.dart';
import 'package:flutter_application_ai/page/home/home_page.dart';
import 'package:flutter_application_ai/page/main/main_page.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/form_section_design_page.dart';
import 'package:flutter_application_ai/page/form_design/form_create/form_create_page.dart';
import 'package:flutter_application_ai/page/form_design/form_manage/form_manage_page.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/form_design_page.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/form_browse_page.dart';
import 'package:flutter_application_ai/page/org_design/org_manager/org_manager_page.dart';
import 'package:flutter_application_ai/page/org_design/org_design_config/org_design_config_page.dart';
import 'package:flutter_application_ai/page/org_design/org_tree_design/org_tree_design_page.dart';
import 'package:flutter_application_ai/model/section_model.dart';

class RouteName {
  static const String loginPage = '/login';
  static const String homePage = '/home';
  static const String mainPage = '/home/main';
  static const String orgManagerPage = '/home/org-manager';
  static const String orgDesignConfigPage =
      '/home/org-manager/org-design-config';
  static const String orgTreeDesignPage = '/home/org-manager/org-tree-design';
  static const String formSectionDesignPage = '/home/form-section-design';
  static const String formManagePage = '/home/form-manage';
  static const String formCreatePage = '/home/form-manage/form-create';
  static const String formDesignPage = '/home/form-manage/form-design';
  static const String formBrowsePage = '/home/form-browse';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteName.loginPage,
    routes: [
      // 登入頁面
      GoRoute(
        path: RouteName.loginPage,
        builder: (context, state) => const LoginPage(),
      ),
      // HomePage 使用 ShellRoute 包覆內部子頁面
      ShellRoute(
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          GoRoute(
            path: RouteName.mainPage,
            builder: (context, state) => const MainPage(),
          ),
          GoRoute(
            path: RouteName.orgManagerPage,
            builder: (context, state) => const OrgManagerPage(),
            routes: [
              GoRoute(
                path: 'org-design-config',
                builder: (context, state) => const OrgDesignConfigPage(),
              ),
              GoRoute(
                path: 'org-tree-design',
                builder: (context, state) => const OrgTreeDesignPage(),
              ),
            ],
          ),
          GoRoute(
            path: RouteName.formSectionDesignPage,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final returnFormId = extra?['returnFormId'] as String? ?? '';
              final editSectionId = extra?['editSectionId'] as String? ?? '';
              return FormSectionDesignPage(
                returnFormId: returnFormId,
                editSectionId: editSectionId,
              );
            },
          ),
          GoRoute(
            path: RouteName.formBrowsePage,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is Map<String, dynamic>) {
                final formId = extra['formId'] as String? ?? '';
                final sections =
                    extra['sections'] as List<dynamic>? ?? const [];
                return FormBrowsePage(
                  formId: formId,
                  initialSections: sections.whereType<SectionModel>().toList(),
                );
              }

              final formId = extra as String? ?? '';
              return FormBrowsePage(formId: formId);
            },
          ),
          GoRoute(
            path: RouteName.formManagePage,
            builder: (context, state) => const FormManagePage(),
            routes: [
              GoRoute(
                path: 'form-create',
                builder: (context, state) =>
                    FormCreatePage(formModel: state.extra as dynamic),
              ),
              GoRoute(
                path: 'form-design',
                builder: (context, state) {
                  final formId = state.extra as String? ?? '';
                  return FormDesignPage(formId: formId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
