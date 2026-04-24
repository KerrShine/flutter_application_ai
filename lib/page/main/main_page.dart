import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/dialog/route_picker_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/home/bloc/home_bloc.dart';
import 'package:flutter_application_ai/page/main/bloc/main_bloc.dart';
import 'package:flutter_application_ai/page/main/widgets/main_quick_shortcut_section_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/main_service.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

/// 可直接導頁（不需 extra 參數）且對應 Drawer 入口的路徑白名單。
const _kShortcutAllowedPaths = <String>{
  RouteName.mainPage,
  RouteName.formManagePage,
  RouteName.formSelectPage,
  RouteName.orgManagerPage,
  RouteName.orgDesignConfigPage,
  RouteName.orgTreeDesignPage,
  RouteName.empManagerPage,
  RouteName.empAgentPage,
  RouteName.empDepPage,
  RouteName.empInfoPage,
  RouteName.empRolePage,
};

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final MainBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MainBloc(sl<MainService>());
    _bloc.add(const InitEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _onAddShortcut(BuildContext context) async {
    final current = _bloc.state.shortcuts;
    final messenger = ScaffoldMessenger.of(context);
    final def = await showRoutePickerDialog(
      context: context,
      allowedPaths: _kShortcutAllowedPaths,
    );
    if (def == null) return;
    if (!mounted) return;
    if (current.contains(def.path)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('此路徑已在快捷列表中'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    _bloc.add(MainAddShortcutEvent(def.path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<MainBloc, MainState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == MainStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MainState state) {
    if (state.status == MainStatus.init ||
        state.status == MainStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeHeader(),
          const SizedBox(height: 32),
          MainQuickShortcutSectionWidget(
            shortcuts: state.shortcuts,
            isEditing: state.isEditingShortcuts,
            onAdd: () => _onAddShortcut(context),
            onRemove: (path) =>
                _bloc.add(MainRemoveShortcutEvent(path)),
            onToggleEdit: () =>
                _bloc.add(const MainToggleShortcutEditEvent()),
            onNavigate: (path) =>
                context.read<HomeBloc>().add(HomeNavigateEvent(path)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome Header
// ---------------------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.home_rounded, size: 24, color: cs.primary),
        ),
        const SizedBox(width: 14),
        Text(
          '首頁',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: TextSize.h2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
