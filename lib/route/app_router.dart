import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/page/login/login_page.dart';
import 'package:flutter_application_ai/page/home/home_page.dart';
import 'package:flutter_application_ai/page/main/main_page.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/form_section_design_page.dart';
import 'package:flutter_application_ai/page/form_design/form_create/form_create_page.dart';
import 'package:flutter_application_ai/page/form_design/form_select/form_select_page.dart';
import 'package:flutter_application_ai/page/form_design/form_condition_field/form_condition_field_page.dart';
import 'package:flutter_application_ai/page/form_design/form_data_binding/form_data_binding_page.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/form_action_binding_page.dart';
import 'package:flutter_application_ai/page/form_design/form_data_manager/form_data_manager_page.dart';
import 'package:flutter_application_ai/page/form_design/form_manage/form_manage_page.dart';
import 'package:flutter_application_ai/page/form_design/form_composer/form_design_page.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/form_browse_page.dart';
import 'package:flutter_application_ai/page/org_design/org_manager/org_manager_page.dart';
import 'package:flutter_application_ai/page/org_design/org_design_config/org_design_config_page.dart';
import 'package:flutter_application_ai/page/org_design/org_tree_design/org_tree_design_page.dart';
import 'package:flutter_application_ai/page/employee/emp_agent/emp_agent_page.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/emp_manager_page.dart';
import 'package:flutter_application_ai/page/employee/emp_dep/emp_dep_page.dart';
import 'package:flutter_application_ai/page/employee/emp_info/emp_info_page.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/emp_manager_guide_page.dart';
import 'package:flutter_application_ai/page/employee/emp_role/emp_role_page.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_run/form_run_page.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission/form_launch_permission_page.dart';
import 'package:flutter_application_ai/page/form_design/form_launch_permission_editor/form_launch_permission_editor_page.dart';
import 'package:flutter_application_ai/page/form_application/application_create/application_create_page.dart';
import 'package:flutter_application_ai/page/form_application/application_my/application_my_page.dart';
import 'package:flutter_application_ai/page/form_application/application_sign_off_pending/application_sign_off_pending_page.dart';
import 'package:flutter_application_ai/page/form_application/application_submission_view/application_submission_view_page.dart';
import 'package:flutter_application_ai/enum/submission_view_mode.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_manager/sign_off_manager_page.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/sign_off_editor_page.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';

class RouteName {
  static const String loginPage = '/login';
  static const String homePage = '/home';
  static const String mainPage = '/home/main';
  static const String orgManagerPage = '/home/org-manager';
  static const String empManagerPage = '/home/emp-manager';
  static const String empManagerGuidePage = '/home/emp-manager/guide';
  static const String empAgentPage = '/home/emp-agent';
  static const String empDepPage = '/home/emp-dep';
  static const String empInfoPage = '/home/emp-info';
  static const String empRolePage = '/home/emp-role';
  static const String orgDesignConfigPage =
      '/home/org-manager/org-design-config';
  static const String orgTreeDesignPage = '/home/org-manager/org-tree-design';
  static const String formSectionDesignPage = '/home/form-section-design';
  static const String formManagePage = '/home/form-manage';
  static const String formCreatePage = '/home/form-manage/form-create';
  static const String formSelectPage = '/home/form-manage/form-select';
  static const String formDataBindingPage =
      '/home/form-manage/form-data-binding';
  static const String formConditionFieldPage =
      '/home/form-manage/form-condition-field';
  static const String formActionBindingPage =
      '/home/form-manage/form-action-binding';
  static const String formDataManagerPage =
      '/home/form-manage/form-data-manager';
  static const String formDesignPage = '/home/form-manage/form-design';
  static const String formBrowsePage = '/home/form-browse';
  static const String formRunPage = '/home/form-run';
  static const String formLaunchPermissionPage =
      '/home/form-manage/form-launch-permission';
  static const String applicationCreatePage = '/home/form-apply/new';
  static const String myApplicationPage = '/home/form-apply/my';
  static const String signOffPendingPage = '/home/sign-off-pending';
  static const String submissionViewPage = '/home/submission/:signOffId';
  static const String formLaunchPermissionEditorPage =
      '/home/form-manage/form-launch-permission/editor';
  static const String signOffManagerPage = '/home/sign-off/sign-off-manager';
  static const String signOffEditorPage =
      '/home/sign-off/sign-off-manager/editor';
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
            path: RouteName.empManagerPage,
            builder: (context, state) => const EmpManagerPage(),
            routes: [
              GoRoute(
                path: 'guide',
                builder: (context, state) => const EmpManagerGuidePage(),
              ),
            ],
          ),
          GoRoute(
            path: RouteName.empRolePage,
            builder: (context, state) => const EmpRolePage(),
          ),
          GoRoute(
            path: RouteName.empAgentPage,
            builder: (context, state) => const EmpAgentPage(),
          ),
          GoRoute(
            path: RouteName.empDepPage,
            builder: (context, state) => EmpDepPage(
              initialDepartmentId:
                  state.uri.queryParameters['departmentId'] ?? '',
              focusedEmployeeId: state.uri.queryParameters['employeeId'] ?? '',
            ),
          ),
          GoRoute(
            path: RouteName.empInfoPage,
            builder: (context, state) => const EmpInfoPage(),
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
            path: RouteName.formRunPage,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return FormRunPage(
                formId: extra?['formId'] as String? ?? '',
                bindingId: extra?['bindingId'] as String? ?? '',
                signOffId: extra?['signOffId'] as String? ?? '',
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
                path: 'form-select',
                builder: (context, state) => const FormSelectPage(),
              ),
              GoRoute(
                path: 'form-data-binding',
                builder: (context, state) {
                  final extra = state.extra;
                  if (extra is Map<String, dynamic>) {
                    return FormDataBindingPage(
                      formId: extra['formId'] as String? ?? '',
                      bindingId: extra['bindingId'] as String? ?? '',
                    );
                  }

                  return FormDataBindingPage(
                    formId: extra as String? ?? '',
                  );
                },
              ),
              GoRoute(
                path: 'form-condition-field',
                builder: (context, state) {
                  final extra = state.extra;
                  if (extra is Map<String, dynamic>) {
                    return FormConditionFieldPage(
                      formId: extra['formId'] as String? ?? '',
                      formName: extra['formName'] as String? ?? '',
                    );
                  }
                  return FormConditionFieldPage(
                    formId: extra as String? ?? '',
                  );
                },
              ),
              GoRoute(
                path: 'form-action-binding',
                builder: (context, state) {
                  final extra = state.extra;
                  if (extra is Map<String, dynamic>) {
                    return FormActionBindingPage(
                      formId: extra['formId'] as String? ?? '',
                      bindingId: extra['bindingId'] as String? ?? '',
                      initialSourceItemId:
                          extra['sourceItemId'] as String? ?? '',
                    );
                  }

                  return FormActionBindingPage(
                    formId: extra as String? ?? '',
                  );
                },
              ),
              GoRoute(
                path: 'form-data-manager',
                builder: (context, state) => FormDataManagerPage(
                  formId: state.extra as String? ?? '',
                ),
              ),
              GoRoute(
                path: 'form-design',
                builder: (context, state) {
                  final formId = state.extra as String? ?? '';
                  return FormDesignPage(formId: formId);
                },
              ),
              GoRoute(
                path: 'form-launch-permission',
                builder: (context, state) =>
                    const FormLaunchPermissionPage(),
                routes: [
                  GoRoute(
                    path: 'editor',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return FormLaunchPermissionEditorPage(
                        forms: extra['forms'] as List<FormModel>,
                        roles: extra['roles'] as List<EmpRoleModel>,
                        departments: extra['departments']
                            as List<OrgDepartmentNode>,
                        existingPermission: extra['permission']
                            as FormLaunchPermissionModel?,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteName.applicationCreatePage,
            builder: (context, state) => const ApplicationCreatePage(),
          ),
          GoRoute(
            path: RouteName.myApplicationPage,
            builder: (context, state) => const ApplicationMyPage(),
          ),
          GoRoute(
            path: RouteName.signOffPendingPage,
            builder: (context, state) => const ApplicationSignOffPendingPage(),
          ),
          GoRoute(
            path: RouteName.submissionViewPage,
            builder: (context, state) {
              final signOffId =
                  state.pathParameters['signOffId'] ?? '';
              final extra = state.extra as Map<String, dynamic>?;
              final mode = SubmissionViewModeX.fromCode(
                extra?['mode'] as String?,
              );
              return ApplicationSubmissionViewPage(
                signOffId: signOffId,
                mode: mode,
              );
            },
          ),
          GoRoute(
            path: RouteName.signOffManagerPage,
            builder: (context, state) => const SignOffManagerPage(),
            routes: [
              GoRoute(
                path: 'editor',
                builder: (context, state) {
                  final extra =
                      (state.extra as Map<String, dynamic>?) ?? const {};
                  final templateId = extra['templateId'] as String?;
                  // 注意：列表頁傳入的是已載入的清單（forms/permissions/depts/roles/employees）
                  // 由編輯器自行從 SignOffService 重新載入也可，但此處沿用 form_launch_permission 的模式
                  // 直接從 extra 拿。若是編輯模式，先在 args 裡帶 templateId，編輯器可由 service 重新載入找出 model。
                  // 為簡化 v1，此處不單獨重載，editor 在 InitEvent 接收完整資料。
                  return SignOffEditorPage(
                    args: SignOffEditorPageArgs(
                      forms: (extra['forms'] as List?)?.cast<FormModel>() ??
                          const [],
                      permissions: (extra['permissions'] as List?)
                              ?.cast<FormLaunchPermissionModel>() ??
                          const [],
                      departments: (extra['departments'] as List?)
                              ?.cast<OrgDepartmentNode>() ??
                          const [],
                      roles: (extra['roles'] as List?)?.cast<EmpRoleModel>() ??
                          const [],
                      employees: (extra['employees'] as List?)
                              ?.cast<EmployeeModel>() ??
                          const [],
                      existingTemplate: templateId == null
                          ? null
                          : (extra['existingTemplate']
                              as SignOffTemplateModel?),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
