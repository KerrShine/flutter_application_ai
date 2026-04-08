import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/service/form_select_service.dart';

part 'form_select_event.dart';
part 'form_select_state.dart';

class FormSelectBloc extends Bloc<FormSelectEvent, FormSelectState> {
  final FormSelectService formSelectService;

  FormSelectBloc(this.formSelectService) : super(const FormSelectState()) {
    on<CompleteNavigationEvent>(_onCompleteNavigationEvent);
    on<InitEvent>(_onInitEvent);
    on<NavigateToBindingEvent>(_onNavigateToBindingEvent);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQueryEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<FormSelectState> emit,
  ) async {
    emit(state.copyWith(status: FormSelectStatus.loading));

    final result = await formSelectService.loadForms();
    if (result.isSuccess) {
      final forms = result.data ?? const <FormModel>[];
      emit(state.copyWith(
        status: FormSelectStatus.success,
        forms: forms,
        filteredForms: _filterForms(forms, state.searchQuery),
      ));
      return;
    }

    emit(state.copyWith(
      status: FormSelectStatus.failure,
      message: result.error ?? '讀取表單清單失敗',
    ));
  }

  void _onNavigateToBindingEvent(
    NavigateToBindingEvent event,
    Emitter<FormSelectState> emit,
  ) {
    emit(state.copyWith(
      status: FormSelectStatus.navigateToBinding,
      navigateFormId: event.formId,
    ));
  }

  void _onUpdateSearchQueryEvent(
    UpdateSearchQueryEvent event,
    Emitter<FormSelectState> emit,
  ) {
    emit(state.copyWith(
      status: FormSelectStatus.success,
      searchQuery: event.searchQuery,
      filteredForms: _filterForms(state.forms, event.searchQuery),
    ));
  }

  void _onCompleteNavigationEvent(
    CompleteNavigationEvent event,
    Emitter<FormSelectState> emit,
  ) {
    emit(state.copyWith(
      status: FormSelectStatus.success,
      navigateFormId: '',
    ));
  }

  List<FormModel> _filterForms(List<FormModel> forms, String searchQuery) {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return forms;
    }

    return forms.where((form) {
      return form.name.toLowerCase().contains(normalizedQuery) ||
          form.id.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}
