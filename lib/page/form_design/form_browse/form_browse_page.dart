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
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<FormBrowseBloc, FormBrowseState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('表單瀏覽'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _onBackPressed,
              ),
            ),
            body: FormBrowseBodyWidget(state: state),
          );
        },
      ),
    );
  }
}
