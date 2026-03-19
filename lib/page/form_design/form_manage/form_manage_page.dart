import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_design/form_manage/bloc/form_manage_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_manage/bloc/form_manage_event.dart';
import 'package:flutter_application_ai/page/form_design/form_manage/bloc/form_manage_state.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/service/form_manage_service.dart';

class FormManagePage extends StatefulWidget {
  const FormManagePage({super.key});

  @override
  State<FormManagePage> createState() => _FormManagePageState();
}

class _FormManagePageState extends State<FormManagePage> {
  late final FormManageBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FormManageBloc(sl<FormManageService>());
    _bloc.add(const LoadFormsEvent());
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
          BlocListener<FormManageBloc, FormManageState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FormManageStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<FormManageBloc, FormManageState>(
          builder: (context, state) {
            return Scaffold(
              body: _buildBody(context, state),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => context.go(RouteName.formCreatePage),
                icon: const Icon(Icons.add),
                label: const Text('新增表單'),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FormManageState state) {
    if (state.status == FormManageStatus.loading ||
        state.status == FormManageStatus.init) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.forms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '目前尚無表單',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '點擊右下角「新增表單」按鈕開始建立',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '表單列表 (${state.forms.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: state.forms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final form = state.forms[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(form.name),
                    subtitle: Text('尺寸：${form.size}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: '刪除',
                      onPressed: () {
                        showMessageDialog(
                          context: context,
                          title: '刪除表單',
                          content: Text('確定要刪除「${form.name}」嗎？'),
                          leftText: '取消',
                          rightText: '刪除',
                          onConfirm: () {
                            _bloc.add(DeleteFormEvent(form.id));
                          },
                          onCancel: () {},
                        );
                      },
                    ),
                    onTap: () {
                      // Phase 2: Navigate to FormDesignPage with formId
                      context.go(RouteName.formDesignPage, extra: form.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
