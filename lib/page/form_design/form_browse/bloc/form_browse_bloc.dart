import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_event.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_state.dart';
import 'package:flutter_application_ai/service/form_browse_service.dart';

class FormBrowseBloc extends Bloc<FormBrowseEvent, FormBrowseState> {
  final FormBrowseService _formBrowseService;

  FormBrowseBloc(this._formBrowseService) : super(const FormBrowseState()) {
    on<InitEvent>(_onInitEvent);
    on<SelectSectionEvent>(_onSelectSectionEvent);
    on<SelectFieldEvent>(_onSelectFieldEvent);
    on<ToggleFieldExpandEvent>(_onToggleFieldExpandEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<FormBrowseState> emit,
  ) async {
    if (event.initialSections.isNotEmpty) {
      emit(state.copyWith(
        status: FormBrowseStatus.success,
        sections: event.initialSections,
        selectedSectionId: null,
        selectedFieldKey: null,
        expandedFieldKey: null,
      ));
      return;
    }

    emit(state.copyWith(status: FormBrowseStatus.loading));

    final result = await _formBrowseService.loadSections(event.formId);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormBrowseStatus.success,
        sections: result.data ?? [],
        selectedSectionId: null,
        selectedFieldKey: null,
        expandedFieldKey: null,
      ));
    } else {
      emit(state.copyWith(
        status: FormBrowseStatus.failure,
        message: result.error ?? '讀取資料失敗',
      ));
    }
  }

  void _onSelectSectionEvent(
    SelectSectionEvent event,
    Emitter<FormBrowseState> emit,
  ) {
    emit(state.copyWith(
      selectedSectionId: event.sectionId,
      selectedFieldKey: null,
      expandedFieldKey: null,
    ));
  }

  void _onSelectFieldEvent(
    SelectFieldEvent event,
    Emitter<FormBrowseState> emit,
  ) {
    final fieldKey = _buildFieldKey(event.sectionId, event.itemId);
    emit(state.copyWith(
      selectedFieldKey: fieldKey,
      expandedFieldKey: fieldKey,
    ));
  }

  void _onToggleFieldExpandEvent(
    ToggleFieldExpandEvent event,
    Emitter<FormBrowseState> emit,
  ) {
    final fieldKey = _buildFieldKey(event.sectionId, event.itemId);
    final isExpanded = state.expandedFieldKey == fieldKey;

    emit(state.copyWith(
      selectedFieldKey: fieldKey,
      expandedFieldKey: isExpanded ? null : fieldKey,
    ));
  }

  String _buildFieldKey(String sectionId, String itemId) {
    return '$sectionId::$itemId';
  }
}
