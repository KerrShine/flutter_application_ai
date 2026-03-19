import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/service/form_create_service.dart';
import 'form_create_event.dart';
import 'form_create_state.dart';

class FormCreateBloc extends Bloc<FormCreateEvent, FormCreateState> {
  final FormCreateService formCreateService;

  FormCreateBloc(this.formCreateService) : super(const FormCreateState()) {
    on<InitEvent>(_onInitEvent);
    on<SubmitFormCreateEvent>(_onSubmitFormCreateEvent);
  }

  FutureOr<void> _onInitEvent(
    InitEvent event,
    Emitter<FormCreateState> emit,
  ) {
    emit(state.copyWith(status: FormCreateStatus.init, message: ''));
  }

  FutureOr<void> _onSubmitFormCreateEvent(
    SubmitFormCreateEvent event,
    Emitter<FormCreateState> emit,
  ) async {
    emit(state.copyWith(status: FormCreateStatus.loading));

    if (event.formName.trim().isEmpty) {
      emit(state.copyWith(
        status: FormCreateStatus.failure,
        message: '表單名稱不可為空',
      ));
      return;
    }

    final result = await formCreateService.createDraftForm(
      event.formName,
      event.formSize,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormCreateStatus.success,
        createdForm: result.data,
      ));
    } else {
      emit(state.copyWith(
        status: FormCreateStatus.failure,
        message: result.error ?? '建立失敗',
      ));
    }
  }
}
