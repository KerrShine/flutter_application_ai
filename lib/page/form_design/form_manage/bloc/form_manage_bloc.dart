import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/service/form_manage_service.dart';
import 'form_manage_event.dart';
import 'form_manage_state.dart';

class FormManageBloc extends Bloc<FormManageEvent, FormManageState> {
  final FormManageService _formManageService;

  FormManageBloc(this._formManageService) : super(const FormManageState()) {
    on<LoadFormsEvent>(_onLoadForms);
    on<DeleteFormEvent>(_onDeleteForm);
  }

  Future<void> _onLoadForms(
    LoadFormsEvent event,
    Emitter<FormManageState> emit,
  ) async {
    emit(state.copyWith(status: FormManageStatus.loading));
    final result = await _formManageService.loadForms();
    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormManageStatus.success,
        forms: result.data ?? [],
      ));
    } else {
      emit(state.copyWith(
        status: FormManageStatus.failure,
        message: result.error ?? '讀取失敗',
      ));
    }
  }

  Future<void> _onDeleteForm(
    DeleteFormEvent event,
    Emitter<FormManageState> emit,
  ) async {
    emit(state.copyWith(status: FormManageStatus.loading));
    final result = await _formManageService.deleteForm(event.formId);
    if (result.isSuccess) {
      // Reload list after delete
      add(const LoadFormsEvent());
    } else {
      emit(state.copyWith(
        status: FormManageStatus.failure,
        message: result.error ?? '刪除失敗',
      ));
    }
  }
}
