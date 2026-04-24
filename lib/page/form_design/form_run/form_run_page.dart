import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_run/bloc/form_run_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_run/widgets/form_run_body_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_run_service.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/route/route_catalog.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormRunPage extends StatefulWidget {
  final String formId;
  final String bindingId;

  const FormRunPage({
    super.key,
    required this.formId,
    this.bindingId = '',
  });

  @override
  State<FormRunPage> createState() => _FormRunPageState();
}

class _FormRunPageState extends State<FormRunPage> {
  late final FormRunBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormRunBloc(sl<FormRunService>());
    _bloc.add(FormRunInitEvent(widget.formId, bindingId: widget.bindingId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _onBackPressed() {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteName.formManagePage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>();

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<FormRunBloc, FormRunState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == FormRunStatus.navigating) {
            final route = state.pendingNavigateRoute;
            if (route == RouteCatalog.stayPath) {
              _bloc.add(const FormRunDismissResultEvent());
            } else if (route == RouteCatalog.backPath) {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go(RouteName.formManagePage);
              }
            } else if (route != null && route.isNotEmpty) {
              try {
                context.go(route);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('無法導頁至：$route'),
                    backgroundColor: Colors.red.shade700,
                    duration: const Duration(seconds: 3),
                  ),
                );
                _bloc.add(const FormRunDismissResultEvent());
              }
            } else {
              // route 為 null 或空（未設定）→ 提示後回到 ready
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('navigate 動作未設定目標頁面'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              _bloc.add(const FormRunDismissResultEvent());
            }
            return;
          }
          if (state.status == FormRunStatus.actionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.isNotEmpty ? state.message : '執行成功'),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 2),
              ),
            );
            _bloc.add(const FormRunDismissResultEvent());
          }
          if (state.status == FormRunStatus.actionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.isNotEmpty ? state.message : '執行失敗'),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 3),
              ),
            );
            _bloc.add(const FormRunDismissResultEvent());
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: colors?.shellBackground.withValues(alpha: 0.92) ??
                  const Color(0xFF1E2431),
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _onBackPressed,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.formName.isNotEmpty ? state.formName : '表單執行',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  if (state.draft.bindingName.isNotEmpty)
                    Text(
                      state.draft.bindingName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors?.faintText ?? Colors.white54,
                          ),
                    ),
                ],
              ),
              actions: [
                if (state.status == FormRunStatus.actionSuccess ||
                    state.draft.bindingName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Chip(
                      label: const Text('已有草稿'),
                      backgroundColor:
                          colors?.actionSuccess.withValues(alpha: 0.15) ??
                              Colors.green.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: colors?.actionSuccess ?? Colors.green,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors?.pageGradient ??
                      [const Color(0xFF1E2431), const Color(0xFF2A3040)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -90,
                    left: -30,
                    child: GlowOrbWidget(
                      color: colors?.heroGlow ?? Colors.blue.withValues(alpha: 0.3),
                      size: 220,
                    ),
                  ),
                  Positioned(
                    right: -60,
                    bottom: -80,
                    child: GlowOrbWidget(
                      color: (colors?.heroGlow ?? Colors.purple)
                          .withValues(alpha: 0.15),
                      size: 240,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors?.shellBackground.withValues(alpha: 0.9) ??
                            const Color(0xFF1E2431).withValues(alpha: 0.9),
                        border: Border.all(
                          color: colors?.shellBorder ?? const Color(0xFF3A3F4E),
                        ),
                      ),
                      child: _buildBody(context, state),
                    ),
                  ),
                  if (state.status == FormRunStatus.executingAction)
                    _buildLoadingOverlay(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FormRunState state) {
    if (state.status == FormRunStatus.loading ||
        state.status == FormRunStatus.init) {
      return const Center(child: CircularProgressIndicator());
    }

    return FormRunBodyWidget(
      sections: state.sections,
      fieldValues: state.fieldValues,
      dropdownOptionsOverride: state.dropdownOptionsOverride,
      onValueChanged: (itemId, value) =>
          _bloc.add(FormRunFieldChangedEvent(itemId, value)),
      onButtonPressed: (itemId) =>
          _bloc.add(FormRunButtonPressedEvent(itemId)),
      onDropdownChanged: (itemId, value) =>
          _bloc.add(FormRunDropdownChangedEvent(itemId, value)),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF262B38),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3A3F4E)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  '執行中...',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '正在呼叫 API，請稍候',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
