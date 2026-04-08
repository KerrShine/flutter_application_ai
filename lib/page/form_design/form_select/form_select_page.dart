import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/composables/glow_orb_widget.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_select/bloc/form_select_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_select/widgets/form_select_form_card_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_select/widgets/form_select_overview_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_select_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormSelectPage extends StatefulWidget {
  const FormSelectPage({super.key});

  @override
  State<FormSelectPage> createState() => _FormSelectPageState();
}

class _FormSelectPageState extends State<FormSelectPage> {
  late final FormSelectBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormSelectBloc(sl<FormSelectService>());
    _bloc.add(const InitEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<FormSelectBloc, FormSelectState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FormSelectStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state.status == FormSelectStatus.navigateToBinding) {
                context.push(
                  RouteName.formDataManagerPage,
                  extra: state.navigateFormId,
                );
                _bloc.add(const CompleteNavigationEvent());
              }
            },
          ),
        ],
        child: BlocBuilder<FormSelectBloc, FormSelectState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: colors.shellBackground.withValues(alpha: 0.92),
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('表單綁定資料管理入口'),
                    Text(
                      '先選擇要管理綁定資料的表單模板',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.faintText,
                          ),
                    ),
                  ],
                ),
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FormSelectState state) {
    if (state.status == FormSelectStatus.init ||
        state.status == FormSelectStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

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
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.shellBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormSelectOverviewWidget(
                      totalForms: state.forms.length,
                      visibleForms: state.filteredForms.length,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.sectionPanelBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.panelBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '選擇要進行綁定資料管理的表單',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '每一張表單都可以建立多份綁定管理設定，供不同資料來源與不同匯出介面重複使用。',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colors.subtleText,
                                ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: '搜尋表單名稱或 ID',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _bloc.add(UpdateSearchQueryEvent(value));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.filteredForms.isEmpty
                          ? Center(
                              child: Text(
                                state.searchQuery.isEmpty
                                    ? '目前沒有表單可供綁定'
                                    : '找不到符合條件的表單',
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount =
                                    constraints.maxWidth >= 1400
                                        ? 3
                                        : constraints.maxWidth >= 760
                                            ? 2
                                            : 1;
                                final childAspectRatio =
                                    constraints.maxWidth >= 1400
                                        ? 1.9
                                        : constraints.maxWidth >= 760
                                            ? 1.72
                                            : 2.05;

                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: childAspectRatio,
                                  ),
                                  itemCount: state.filteredForms.length,
                                  itemBuilder: (context, index) {
                                    final form = state.filteredForms[index];
                                    return FormSelectFormCardWidget(
                                      form: form,
                                      onTap: () {
                                        _bloc.add(
                                            NavigateToBindingEvent(form.id));
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
