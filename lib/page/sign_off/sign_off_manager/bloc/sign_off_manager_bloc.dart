import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';

part 'sign_off_manager_event.dart';
part 'sign_off_manager_state.dart';

class SignOffManagerBloc
    extends Bloc<SignOffManagerEvent, SignOffManagerState> {
  final SignOffService _service;

  SignOffManagerBloc(this._service) : super(const SignOffManagerState()) {
    on<InitSignOffManagerEvent>(_onInit);
    on<DeleteSignOffTemplateEvent>(_onDelete);
    on<RequestSignOffExportJsonEvent>(_onExport);
    on<DismissSignOffMessageEvent>(_onDismissMessage);
  }

  Future<void> _onInit(
    InitSignOffManagerEvent event,
    Emitter<SignOffManagerState> emit,
  ) async {
    emit(state.copyWith(status: SignOffManagerStatus.loading));

    final result = await _service.initialize();

    if (result.isSuccess) {
      final data = result.data!;
      emit(state.copyWith(
        status: SignOffManagerStatus.success,
        forms: data.forms,
        templates: data.templates,
        permissions: data.permissions,
        roles: data.roles,
        departments: data.departments,
        employees: data.employees,
      ));
      return;
    }

    emit(state.copyWith(
      status: SignOffManagerStatus.failure,
      message: result.error ?? '初始化失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onDelete(
    DeleteSignOffTemplateEvent event,
    Emitter<SignOffManagerState> emit,
  ) async {
    emit(state.copyWith(status: SignOffManagerStatus.loading));

    final result = await _service.deleteTemplate(event.templateId);

    if (result.isSuccess) {
      emit(state.copyWith(
        status: SignOffManagerStatus.success,
        templates: result.data ?? state.templates,
        message: '刪除成功',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      status: SignOffManagerStatus.failure,
      message: result.error ?? '刪除失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onExport(
    RequestSignOffExportJsonEvent event,
    Emitter<SignOffManagerState> emit,
  ) async {
    final result = await _service.buildExportJson();
    if (result.isSuccess) {
      emit(state.copyWith(
        exportJson: result.data ?? '',
        exportDialogRequestId: state.exportDialogRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      message: result.error ?? '匯出失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onDismissMessage(
    DismissSignOffMessageEvent event,
    Emitter<SignOffManagerState> emit,
  ) {
    emit(state.copyWith(message: ''));
  }
}
