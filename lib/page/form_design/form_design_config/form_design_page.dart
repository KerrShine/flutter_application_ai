import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/service/form_design_service.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/bloc/form_design_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/widgets/available_section_panel_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/widgets/form_design_info_panel_widget.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/widgets/form_section_canvas_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormDesignPage extends StatefulWidget {
  final String formId;
  const FormDesignPage({super.key, required this.formId});

  @override
  State<FormDesignPage> createState() => _FormDesignPageState();
}

class _FormDesignPageState extends State<FormDesignPage> {
  late final FormDesignBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormDesignBloc(sl<FormDesignService>());
    _bloc.add(InitFormDesignEvent(widget.formId));
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
          BlocListener<FormDesignBloc, FormDesignState>(
            listenWhen: (p, c) => p.status != c.status,
            listener: (context, state) {
              if (state.status == FormDesignStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state.status == FormDesignStatus.saved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('表單已儲存！')),
                );
              } else if (state.status == FormDesignStatus.draftSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('表單暫存成功！')),
                );
              } else if (state.status == FormDesignStatus.showJsonPreview) {
                showScrollableMessageDialog(
                  context: context,
                  title: '目前表單 JSON',
                  child: SelectableText(state.jsonPreview),
                );
              } else if (state.status == FormDesignStatus.navigateToSection) {
                context.go(
                  RouteName.formSectionDesignPage,
                  extra: {
                    'returnFormId': widget.formId,
                    'editSectionId': state.editingSectionId,
                  },
                );
              } else if (state.status == FormDesignStatus.navigateToBrowse) {
                context.push(
                  RouteName.formBrowsePage,
                  extra: {
                    'formId': state.formId,
                    'sections': state.browseSections,
                  },
                );
              } else if (state.status ==
                  FormDesignStatus.confirmDeleteSection) {
                final sectionId = state.pendingDeleteSectionId;
                final inUse = state.isDeleteSectionInUse;
                final matchedSections =
                    state.availableSections.where((s) => s.id == sectionId);
                if (matchedSections.isEmpty) {
                  _bloc.add(const CancelConfirmDeleteSectionEvent());
                  return;
                }
                final sectionName = matchedSections.first.name;
                showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('刪除 Section'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('確定要刪除「$sectionName」?操作無法復原。'),
                        if (inUse) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Theme.of(context).colorScheme.error,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '此 Section 目前已加入表單，刪除後將同步從畫布移除。',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(
                          '刪除',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).then((confirmed) {
                  if (!mounted) return;
                  if (confirmed == true) {
                    _bloc.add(ConfirmDeleteAvailableSectionEvent(sectionId));
                  } else {
                    _bloc.add(const CancelConfirmDeleteSectionEvent());
                  }
                });
              }
            },
          ),
        ],
        child: BlocBuilder<FormDesignBloc, FormDesignState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: colors.shellBackground.withValues(alpha: 0.92),
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.formName.isEmpty ? '表單設計' : state.formName),
                    Text(
                      '編排 Section 順序、檢視結構並維持草稿狀態',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.faintText,
                          ),
                    ),
                  ],
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(RouteName.formManagePage),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilledButton.icon(
                      onPressed: () => _bloc.add(const SaveFormDesignEvent()),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('儲存表單'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: state.status == FormDesignStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
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
                                color: colors.shellBackground.withValues(
                                  alpha: 0.9,
                                ),
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
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AvailableSectionPanelWidget(
                                      state: state,
                                      onAddSection: (section) {
                                        _bloc.add(
                                          AddSectionToFormEvent(section),
                                        );
                                      },
                                      onEditSection: (section) {
                                        _bloc.add(
                                          NavigateToEditSectionEvent(
                                              section.id),
                                        );
                                      },
                                      onCreateSection: () {
                                        _bloc.add(
                                          const NavigateToCreateSectionEvent(),
                                        );
                                      },
                                      onDeleteSection: (section) {
                                        _bloc.add(
                                          RequestDeleteAvailableSectionEvent(
                                            section.id,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FormSectionCanvasWidget(
                                        state: state,
                                        onReorder: (oldIndex, newIndex) {
                                          _bloc.add(
                                            ReorderSectionEvent(
                                              oldIndex,
                                              newIndex,
                                            ),
                                          );
                                        },
                                        onRemoveSection: (sectionId) {
                                          _bloc.add(
                                            RemoveSectionFromFormEvent(
                                                sectionId),
                                          );
                                        },
                                        onBrowseSection: (section) {
                                          _bloc.add(
                                            NavigateToBrowseSectionEvent(
                                                section),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    FormDesignInfoPanelWidget(
                                      state: state,
                                      onSaveDraft: () {
                                        _bloc.add(const SaveFormDraftEvent());
                                      },
                                      onPreviewJson: () {
                                        _bloc.add(const PreviewFormJsonEvent());
                                      },
                                      onBrowse: () {
                                        _bloc
                                            .add(const NavigateToBrowseEvent());
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
