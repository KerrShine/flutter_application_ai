import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_event.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_state.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/widgets/form_browse_body_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_browse_service.dart';
import 'package:flutter_application_ai/theme/form_browse_theme_colors.dart';

class FormBrowsePage extends StatefulWidget {
  final String formId;
  final List<SectionModel> initialSections;

  const FormBrowsePage({
    super.key,
    this.formId = '',
    this.initialSections = const [],
  });

  @override
  State<FormBrowsePage> createState() => _FormBrowsePageState();
}

class _FormBrowsePageState extends State<FormBrowsePage> {
  late final FormBrowseBloc _bloc;

  void _onBackPressed() {
    if (GoRouter.of(context).canPop()) {
      context.pop();
      return;
    }

    if (widget.formId.isNotEmpty) {
      context.go(RouteName.formDesignPage, extra: widget.formId);
      return;
    }

    context.go(RouteName.formManagePage);
  }

  @override
  void initState() {
    super.initState();
    _bloc = FormBrowseBloc(sl<FormBrowseService>());
    _bloc.add(
      InitEvent(
        widget.formId,
        initialSections: widget.initialSections,
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormBrowseThemeColors>()!;

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<FormBrowseBloc, FormBrowseState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: colors.shellBackground.withValues(alpha: 0.92),
              surfaceTintColor: Colors.transparent,
              title: const Text('表單瀏覽'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _onBackPressed,
              ),
            ),
            body: Container(
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
                    child: _GlowOrb(color: colors.heroGlow, size: 220),
                  ),
                  Positioned(
                    right: -60,
                    bottom: -80,
                    child: _GlowOrb(
                      color: colors.heroGlow.withValues(alpha: 0.18),
                      size: 240,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.shellBackground.withValues(alpha: 0.9),
                        border: Border.all(color: colors.shellBorder),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shellShadow,
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: FormBrowseBodyWidget(state: state),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
