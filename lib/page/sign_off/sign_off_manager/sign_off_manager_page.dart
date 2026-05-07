import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_manager/bloc/sign_off_manager_bloc.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_manager/widgets/sign_off_manager_header_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_manager/widgets/sign_off_manager_list_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffManagerPage extends StatefulWidget {
  const SignOffManagerPage({super.key});

  @override
  State<SignOffManagerPage> createState() => _SignOffManagerPageState();
}

class _SignOffManagerPageState extends State<SignOffManagerPage> {
  late final SignOffManagerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = SignOffManagerBloc(sl<SignOffService>());
    _bloc.add(const InitSignOffManagerEvent());
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
          BlocListener<SignOffManagerBloc, SignOffManagerState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<SignOffManagerBloc, SignOffManagerState>(
            listenWhen: (previous, current) =>
                previous.exportDialogRequestId !=
                    current.exportDialogRequestId &&
                current.exportJson.isNotEmpty,
            listener: (context, state) {
              _showExportJsonDialog(context, state.exportJson);
            },
          ),
        ],
        child: BlocBuilder<SignOffManagerBloc, SignOffManagerState>(
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
                      '簽核流程設定',
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
                      '為每張表單設定簽核流程模板，包含發起資格與簽核級別',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.faintText,
                            fontSize:
                                (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) + 2,
                          ),
                    ),
                  ],
                ),
              ),
              body: _buildBody(context, state, colors),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SignOffManagerState state,
    FormDesignThemeColors colors,
  ) {
    if (state.status == SignOffManagerStatus.init ||
        state.status == SignOffManagerStatus.loading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.pageGradient,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: colors.shellBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.shellBorder),
                boxShadow: [
                  BoxShadow(
                    color: colors.shellShadow,
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SignOffManagerHeaderWidget(
                    onExportJson: () {
                      _bloc.add(const RequestSignOffExportJsonEvent());
                    },
                    onCreateTemplate: () => _navigateToEditor(context, state),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SignOffManagerListWidget(
                      templates: state.templates,
                      onEdit: (templateId) {
                        final template = state.templates.firstWhere(
                          (t) => t.templateId == templateId,
                        );
                        _navigateToEditor(
                          context,
                          state,
                          existingTemplateId: template.templateId,
                        );
                      },
                      onDelete: (templateId) {
                        _showDeleteConfirmDialog(context, templateId);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditor(
    BuildContext context,
    SignOffManagerState state, {
    String? existingTemplateId,
  }) async {
    final existingTemplate = existingTemplateId == null
        ? null
        : state.templates.cast<SignOffTemplateModel?>().firstWhere(
              (t) => t?.templateId == existingTemplateId,
              orElse: () => null,
            );

    final result = await context.push<bool>(
      RouteName.signOffEditorPage,
      extra: {
        'forms': state.forms,
        'permissions': state.permissions,
        'departments': state.departments,
        'roles': state.roles,
        'employees': state.employees,
        'templateId': existingTemplateId,
        'existingTemplate': existingTemplate,
      },
    );

    if (result == true) {
      _bloc.add(const InitSignOffManagerEvent());
    }
  }

  Future<void> _showDeleteConfirmDialog(
      BuildContext context, String templateId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除此簽核流程嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _bloc.add(DeleteSignOffTemplateEvent(templateId));
    }
  }

  Future<void> _showExportJsonDialog(
    BuildContext context,
    String exportJson,
  ) {
    return showScrollableMessageDialog(
      context: context,
      title: '簽核流程 JSON',
      width: 860,
      rightText: '關閉',
      child: SelectableText(
        exportJson,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}
